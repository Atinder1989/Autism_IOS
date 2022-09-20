//
//  LearningVocalImitationsViewController.swift
//  Autism
//
//  Created by Savleen on 30/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

class LearningVocalImitationsViewController: UIViewController {
    private let verbalViewModal: LearningVocalImitationsViewModel = LearningVocalImitationsViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    
    private var videoItem: VideoItem?
    private var bufferLoaderTimer: Timer?

    @IBOutlet weak var pauseButton: UIButton!
    
    private var isChildActionCompleted = false {
        didSet {
            if isChildActionCompleted {
                DispatchQueue.main.async {
                    self.verbalViewModal.calculateChildAction(state: self.isChildActionCompleted)
                }
            }
        }
    }
    
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var questionImageView: ScriptCommandImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var userAnswer: UILabel!
    
    @IBOutlet weak var bufferLoaderView: UIView!

    var questionId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        
        if self.command_array.count == 0 {
            self.verbalViewModal.fetchLearningQuestion(skillDomainId: self.skillDomainId, program: self.program)

            if(UIDevice.current.userInterfaceIdiom != .pad) {
                thumnailImageView.contentMode = .scaleAspectFit
            }
        } else {
            self.verbalViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
        self.verbalViewModal.stopAllCommands()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.verbalViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.verbalViewModal.pausePlayer()
        self.verbalViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipLearningClicked(_ sender: Any) {
        self.verbalViewModal.stopAllCommands()
        self.verbalViewModal.skipLearningSubmitLearningMatchingAnswer()
    }
}

//MARK:- Public Methods
extension LearningVocalImitationsViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.questionId = questionId
        self.skillDomainId = skillDomainId
        self.command_array = command_array
    }
}

//MARK:- Private Methods
extension LearningVocalImitationsViewController {
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.verbalViewModal.updateCurrentCommandIndex()
    }
    
    private func customSetting() {
        self.questionImageView.isHidden = true
        self.avatarImageView.isHidden = true
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        isChildActionCompleted = false
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.userAnswer.text = ""
//        self.speechTitle.isHidden = true
        self.bufferLoaderView.isHidden = true
    }
    
    private func listenModelClosures() {
        self.verbalViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.verbalViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.verbalViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
       self.verbalViewModal.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
        
       self.verbalViewModal.resetDataClosure = {
            DispatchQueue.main.async {
                self.customSetting()
            }
       }
        
       self.verbalViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.verbalViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.userAnswer.text = ""
                self.speechTitle.text = ""
            }
       }
        
       self.verbalViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.verbalViewModal.showVideoClosure = { urlString in
           DispatchQueue.main.async {
               if(self.questionImageView != nil) {
                   self.customSetting()
               
                   self.addPlayer(urlString: urlString)
               }
           }
       }
        
        
        
        self.verbalViewModal.talkAvatarClosure = {
             DispatchQueue.main.async {
                self.avatarImageView.isHidden = false
                self.avatarImageView.animatedImage = getTalkingGif()
             }
        }
        
        self.verbalViewModal.idleAvatarClosure = {
             DispatchQueue.main.async {
                self.avatarImageView.isHidden = true
             }
        }
        
        
        self.verbalViewModal.showImageClosure = { questionInfo in
             DispatchQueue.main.async {
                if let option = questionInfo.option {
                     let url = ServiceHelper.baseURL.getMediaBaseUrl() + questionInfo.value
                    if option.Position == ScriptCommandOptionType.center.rawValue {
                         self.questionImageView.isHidden = false
                         self.questionImageView.commandInfo = questionInfo
                         self.questionImageView.setImageWith(urlString: url)
                        self.verbalViewModal.updateCurrentCommandIndex()
                     }
                }
             }
        }
        
        self.verbalViewModal.blinkImageClosure = { questionInfo in
            DispatchQueue.main.async {
                if let option = questionInfo.option {
                    self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration))
                }
             }
        }
        
        self.verbalViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                if state {
                    RecordingManager.shared.startRecording(delegate: self)
                } else {
                    RecordingManager.shared.stopRecordingWithDelegate()
                }
             }
        }
    }
    
    private func blinkImage(count: Int) {
        if count == 0 {
            self.verbalViewModal.updateCurrentCommandIndex()
            return
        }
                UIView.animate(withDuration: 1, animations: {
                    for subview in self.view.subviews {
                        if let cmdImageView = subview as? ScriptCommandImageView {
                            cmdImageView.alpha = 0.2
                        }
                    }
                }) { [self] finished in
                    for subview in self.view.subviews {
                        if let cmdImageView = subview as? ScriptCommandImageView {
                            cmdImageView.alpha = 1
                        }
                    }
                    self.blinkImage(count: count - 1)
                }
    }
    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = verbalViewModal.playerController {
            if let avplayerController = playerController.avPlayerController {
                self.playerView.isHidden = false
                self.playerView.addSubview(avplayerController.view)
                avplayerController.view.frame = self.playerView.bounds
                self.videoItem = VideoItem.init(url: string)
                self.playVideo()
                self.thumbnailImage = Utility.getThumbnailImage(urlString: string, time: CMTimeMake(value: 5, timescale: 2))
            }
        }
        
    }
    
    private func showBufferLoader() {
        self.playerView.bringSubviewToFront(self.bufferLoaderView)

        self.bufferLoaderView.isHidden = false
        if let timer = self.bufferLoaderTimer {
            timer.invalidate()
        }
        self.bufferLoaderTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.2),
                        target: self,
                        selector: #selector(self.startBufferLoaderAnimation),
                        userInfo: nil, repeats: true)
    }

    @objc private func startBufferLoaderAnimation () {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {() -> Void in
                self.bufferLoaderView.transform = self.bufferLoaderView.transform.rotated(by: CGFloat(Double.pi))
            }, completion: {(_ finished: Bool) -> Void in
            })
        }
    }

    private func hideBufferLoader() {
        if let timer = self.bufferLoaderTimer {
            self.bufferLoaderView.isHidden = true
            timer.invalidate()
            self.bufferLoaderTimer = nil
        }
    }
    
    private func playVideo() {
        if let item = self.videoItem {
        verbalViewModal.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    @objc private func videoFinished() {
        self.restartButton.isHidden = false
        self.nextButton.isHidden = false

        if let image = self.thumbnailImage {
            self.thumnailImageView.image = image
            self.thumnailImageView.isHidden = false
        }
        self.initializeTimer()
    }
    
    func stopPlayer() {
        self.verbalViewModal.stopVideo()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.verbalViewModal.getCurrentCommandInfo(),let option = info.option {
            let time = Int(option.switch_command_time) ?? 0
            if self.videoFinishWaitingTime >= time  {
                self.moveToNextCommand()
            }
        }
    }
    
    private func stopTimer() {
        if let timer = self.videoFinishTimer {
            print("Video Timer Stop ======== ")
            timer.invalidate()
            self.videoFinishTimer = nil
            self.videoFinishWaitingTime = 0
        }
    }

 }


extension LearningVocalImitationsViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


//MARK:- RecordingManager Delegate Methods
extension LearningVocalImitationsViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text.lowercased()
    }
    
    func recordingStart() {
        
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.verbalViewModal.handleUserAnswer(text: speechText)
    }
    
}

extension LearningVocalImitationsViewController: PauseViewDelegate {
    func didTapOnPlay() {
        Utility.hidePauseView()
        self.pauseClicked(self.pauseButton as Any)
    }
    
    @IBAction func pauseClicked(_ sender: Any) {        
        
        if AutismTimer.shared.isTimerRunning() {
//            self.stopTimer()
//            SpeechManager.shared.setDelegate(delegate: nil)
//            RecordingManager.shared.stopRecording()
            
            self.pauseButton.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
            Utility.showPauseView(delegate: self)
        } else {
//            AutismTimer.shared.initializeTimer(delegate: self)
//            SpeechManager.shared.setDelegate(delegate: self)
//            RecordingManager.shared.startRecording(delegate: self)
            
            self.pauseButton.setBackgroundImage(UIImage.init(named: "pause"), for: .normal)
        }
    }
}
