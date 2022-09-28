//
//  LearningQuizIntroViewController.swift
//  Autism
//
//  Created by Dilip Saket on 20/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

class LearningQuizIntroViewController: UIViewController {
    private let quizIntroViewModal: LearningQuizIntroViewModel = LearningQuizIntroViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    
    private var videoItem: VideoItem?
    private var bufferLoaderTimer: Timer?


    private var isChildActionCompleted = false {
        didSet {
            if isChildActionCompleted {
                DispatchQueue.main.async {
                    self.quizIntroViewModal.calculateChildAction(state: self.isChildActionCompleted)
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
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var bufferLoaderView: UIView!

    @IBOutlet weak var submitButton: UIButton!
    
    var questionId:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        
        if self.command_array.count == 0 {
            self.quizIntroViewModal.fetchLearningQuestion(skillDomainId: self.skillDomainId, program: self.program)

            if(UIDevice.current.userInterfaceIdiom != .pad) {
                thumnailImageView.contentMode = .scaleAspectFit
            }
        } else {
            self.quizIntroViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
        self.quizIntroViewModal.stopAllCommands()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.quizIntroViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.quizIntroViewModal.pausePlayer()
        self.quizIntroViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipLearningClicked(_ sender: Any) {
        self.quizIntroViewModal.stopAllCommands()
        self.quizIntroViewModal.skipLearningSubmitLearningMatchingAnswer()
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        self.submitButton.isUserInteractionEnabled = false
        self.quizIntroViewModal.submitLearningMatchingAnswer()
    }
}

//MARK:- Public Methods
extension LearningQuizIntroViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.questionId = questionId
        self.skillDomainId = skillDomainId
        self.command_array = command_array
    }
}

//MARK:- Private Methods
extension LearningQuizIntroViewController {
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.quizIntroViewModal.updateCurrentCommandIndex()
    }
    
    private func customSetting() {
        self.avatarImageView.isHidden = false
        
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        isChildActionCompleted = false
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.userAnswer.text = ""

        self.bufferLoaderView.isHidden = true
    }
    
    private func listenModelClosures() {
        self.quizIntroViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.quizIntroViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.quizIntroViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
       self.quizIntroViewModal.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
        
       self.quizIntroViewModal.resetDataClosure = {
            DispatchQueue.main.async {
                self.customSetting()
            }
       }
        
       self.quizIntroViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.quizIntroViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.quizIntroViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
        
    
       
       self.quizIntroViewModal.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.quizIntroViewModal.talkAvatarClosure = {
             DispatchQueue.main.async {
                self.avatarImageView.animatedImage = getTalkingGif()
             }
        }
        
        self.quizIntroViewModal.idleAvatarClosure = {
             DispatchQueue.main.async {
                self.avatarImageView.animatedImage = getIdleGif()
             }
        }
        
        self.quizIntroViewModal.showAvatarClosure = {
            DispatchQueue.main.async {
               self.avatarImageView.isHidden = false
            }
        }
        

        
        self.quizIntroViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                if state {
                    RecordingManager.shared.startRecording(delegate: self)
                } else {
                    RecordingManager.shared.stopRecording()
                }
             }
        }
    }

    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = quizIntroViewModal.playerController {
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
        quizIntroViewModal.playVideo(item: item)
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
        self.quizIntroViewModal.stopVideo()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.quizIntroViewModal.getCurrentCommandInfo(),let option = info.option {
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


extension LearningQuizIntroViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


//MARK:- RecordingManager Delegate Methods
extension LearningQuizIntroViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text.lowercased()
    }
    
    func recordingStart() {
        
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.quizIntroViewModal.handleUserAnswer(text: speechText)
    }
    
}

