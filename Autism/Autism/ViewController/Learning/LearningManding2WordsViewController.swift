//
//  LearningManding2WordsViewController.swift
//  Autism
//
//  Created by Savleen on 01/03/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

class LearningManding2WordsViewController: UIViewController {
    private let manding2WordsViewModal: LearningManding2WordsViewModel = LearningManding2WordsViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    
    private var videoItem: VideoItem?
    private var bufferLoaderTimer: Timer?


//    private var isChildActionCompleted = false {
//        didSet {
//            if isChildActionCompleted {
//                DispatchQueue.main.async {
//                   // self.manding2WordsViewModal.calculateChildAction(state: self.isChildActionCompleted)
//                }
//            }
//        }
//    }
    
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var questionImageView: ScriptCommandImageView!
    //@IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var skipLearningButton: UIButton!
    
    @IBOutlet weak var bufferLoaderView: UIView!
  

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.skipLearningButton.isHidden = isSkipLearningHidden
        self.customSetting()
        if self.command_array.count == 0 {
            self.manding2WordsViewModal.fetchLearningQuestion(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
          
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()

    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.manding2WordsViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }
    
//    @IBAction func backClicked(_ sender: Any) {
//       // self.view.isUserInteractionEnabled = false
//        self.manding2WordsViewModal.stopAllCommands()
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.manding2WordsViewModal.pausePlayer()
        self.manding2WordsViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipLearningClicked(_ sender: Any) {
        self.manding2WordsViewModal.stopAllCommands()
        self.manding2WordsViewModal.skipLearningSubmitLearningMatchingAnswer()
    }
}

//MARK:- Public Methods
extension LearningManding2WordsViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.manding2WordsViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)

        }
    }
}

//MARK:- Private Methods
extension LearningManding2WordsViewController {
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.manding2WordsViewModal.updateCurrentCommandIndex()
    }
    
    private func initializeFrame()
    {
        let deviceWidth:CGFloat = UIScreen.main.bounds.width
        let size: CGFloat = 460
        let frame = CGRect.init(x: (deviceWidth/2) - (size/2), y: 154, width: size, height: size)
        questionImageView.frame = frame
        self.userAnswer.frame = CGRect.init(x: 0, y: frame.origin.y + size + 40, width: deviceWidth, height: 30)
    }
    
    private func customSetting() {
        self.initializeFrame()
        self.questionImageView.isHidden = true
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.userAnswer.text = ""
        self.bufferLoaderView.isHidden = true
    }
    
    private func listenModelClosures() {
        self.manding2WordsViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.manding2WordsViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.manding2WordsViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
       self.manding2WordsViewModal.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
        
       self.manding2WordsViewModal.resetDataClosure = {
            DispatchQueue.main.async {
                self.customSetting()
            }
       }
        
       self.manding2WordsViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.manding2WordsViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
        
       self.manding2WordsViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.manding2WordsViewModal.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
                
//        self.manding2WordsViewModal.talkAvatarClosure = {
//             DispatchQueue.main.async {
//                self.avatarImageView.isHidden = false
//                self.avatarImageView.animatedImage = talkingGif
//             }
//        }
//
//        self.manding2WordsViewModal.idleAvatarClosure = {
//             DispatchQueue.main.async {
//                self.avatarImageView.isHidden = true
//             }
//        }
        
        self.manding2WordsViewModal.showImageClosure = { questionInfo in
             DispatchQueue.main.async {
                if let option = questionInfo.option {
                     let url = ServiceHelper.baseURL.getMediaBaseUrl() + questionInfo.value
                    if option.Position == ScriptCommandOptionType.center.rawValue {
                         self.questionImageView.isHidden = false
                        self.questionImageView.commandInfo = questionInfo
                         self.questionImageView.setImageWith(urlString: url)
                     }
                }
             }
        }
        
        self.manding2WordsViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                if state {
                    RecordingManager.shared.startRecording(delegate: self)
                } else {
                    RecordingManager.shared.stopRecording()
                }
             }
        }
        
        self.manding2WordsViewModal.makeBiggerClosure = { questionInfo in
             DispatchQueue.main.async {
                self.speechTitle.text = ""
                self.userAnswer.text = ""
                Animations.makeBiggerAnimationFromCenter(imageView: self.questionImageView, questionInfo: questionInfo) { (finished) in
                    self.manding2WordsViewModal.updateSequenceCommandIndex()
                }
             }
        }
        
    }
        
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = manding2WordsViewModal.playerController {
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
        manding2WordsViewModal.playVideo(item: item)
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
        self.manding2WordsViewModal.stopVideo()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.manding2WordsViewModal.getCurrentCommandInfo(),let option = info.option {
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


extension LearningManding2WordsViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


//MARK:- RecordingManager Delegate Methods
extension LearningManding2WordsViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text
    }
    
    func recordingStart() {
        
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.manding2WordsViewModal.handleUserAnswer(text: speechText)
    }
    
}

