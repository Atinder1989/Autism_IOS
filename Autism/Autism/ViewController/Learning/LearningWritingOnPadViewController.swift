//
//  LearningWritingOnPadViewController.swift
//  Autism
//
//  Created by Singh, Atinderpal on 10/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation

class LearningWritingOnPadViewController: UIViewController {
    private let writingPadViewModal: LearningWritingOnPadViewModel = LearningWritingOnPadViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []

    private var isTouch = false
    private var isImagesDownloaded = false
    private var isChildAction = false
    private var videoItem: VideoItem?
    private var isChildActionCompleted = false {
        didSet {
            if isChildActionCompleted {
                DispatchQueue.main.async {
                    self.writingPadViewModal.calculateChildAction(state: self.isChildActionCompleted, touch: self.isTouch)
                }
            }
        }
    }
   
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bufferLoaderView: UIView!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var curveImageView: DrawnImageView!
    
    private var bufferLoaderTimer: Timer?
    var questionId = ""
    var isFromViewdidLoad:Bool = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromViewdidLoad {
            isFromViewdidLoad = false
            if self.command_array.count == 0 {
                self.writingPadViewModal.fetchLearningSolidQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
                if(UIDevice.current.userInterfaceIdiom != .pad) {
                    thumnailImageView.contentMode = .scaleAspectFit
                }
            } else {
                self.writingPadViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
        self.writingPadViewModal.stopAllCommands()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.writingPadViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        self.writingPadViewModal.uploadImage(image: self.curveImageView.asImage())

    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }

    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.writingPadViewModal.pausePlayer()
        self.writingPadViewModal.stopAllCommands()
        
        SpeechManager.shared.stopSpeech()
        FaceDetection.shared.stopFaceDetectionSession()
        AutismTimer.shared.stopTimer()
        
        if !UserManager.shared.get_isActionPerformed() {
            UserManager.shared.set_isActionPerformed(true)
            UserManager.shared.updateScreenId(screenid: ScreenRedirection.dashboard.rawValue)
            self.dismiss(animated: true)
        }
    }
   
}
//MARK:- Public Methods
extension LearningWritingOnPadViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        self.questionId = questionId
        self.command_array = command_array
    }
}

//MARK:- Private Methods
extension LearningWritingOnPadViewController {
    
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.writingPadViewModal.updateCurrentCommandIndex()
    }
    
    private func customSetting() {
        self.isTouch = false
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        isChildActionCompleted = false
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.isChildAction = false
        self.bufferLoaderView.isHidden = true
        isImagesDownloaded = false
        self.questionImageView.isHidden = true
        self.curveImageView.isHidden = true
        self.submitButton.isHidden = true

    }
    
    private func listenModelClosures() {
        self.writingPadViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.writingPadViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.writingPadViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
       self.writingPadViewModal.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
               
       self.writingPadViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.writingPadViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.writingPadViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.writingPadViewModal.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.writingPadViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                self.isChildAction = state

             }
        }
       
       self.writingPadViewModal.showImageClosure = { commandInfo in
           DispatchQueue.main.async { [weak self] in
               if let this = self {
                   let url = ServiceHelper.baseURL.getMediaBaseUrl() + commandInfo.value
                   this.questionImageView.setImageWith(urlString: url)
                   this.questionImageView.isHidden = false
                   this.curveImageView.isHidden = false
                   this.submitButton.isHidden = false

               }
               
            }
       }
    }
    
     private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = writingPadViewModal.playerController {
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
        writingPadViewModal.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.writingPadViewModal.stopVideo()
    }
    
    private func videoFinished() {
        self.restartButton.isHidden = false
        self.nextButton.isHidden = false
        if let image = self.thumbnailImage {
            self.thumnailImageView.image = image
            self.thumnailImageView.isHidden = false
        }
        self.initializeTimer()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.writingPadViewModal.getCurrentCommandInfo(),let option = info.option {
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


extension LearningWritingOnPadViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


extension LearningWritingOnPadViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
            self.writingPadViewModal.updateCurrentCommandIndex()
        }
    }
}

