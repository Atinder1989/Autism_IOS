//
//  LearningVisualTrackingViewController.swift
//  Autism
//
//  Created by Savleen on 19/05/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class LearningVisualTrackingViewController: UIViewController {
    private let visualTrackingViewModal: LearningVisualTrackingViewModel = LearningVisualTrackingViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var isGame = false
    private var command_array: [ScriptCommandInfo] = []
    private var gameTimer: Timer? = nil
    private var videoItem: VideoItem?
    private var thumbnailImage: UIImage?
    private var bufferLoaderTimer: Timer?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var avatarCenterImageView: FLAnimatedImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var bufferLoaderView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var thumnailImageView: UIImageView!

    private var balloonTapCount = 0
    private var timerTime = 0
    private var timerMaxTime = 0
    private var noOfBalloonsAtTime = 4
    private var totalBalloonInGame = 0

    var questionId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        
        if self.command_array.count == 0 {
            self.visualTrackingViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        } else {
            self.visualTrackingViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
        }
        
//        if self.command_array.count == 0 {
//            self.visualTrackingViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
//        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGame {
           return
        }
        guard let touch = touches.first else{return}
        let touchLocation = touch.location(in: self.view)
        for ourView in self.view.subviews{
            //guard let ourView = subs as? UIView else{return}
            if ourView.layer.presentation()!.hitTest(touchLocation) != nil{
                if ourView.tag == 1001 || ourView.tag == 1002 || ourView.tag == 1003 || ourView.tag == 1004 {
                    balloonTapCount += 1
                    ourView.isHidden = true
                    print(balloonTapCount)
                } else {
                    print("Not our view")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.visualTrackingViewModal.stopAllCommands()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.visualTrackingViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.visualTrackingViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }
    
}

//MARK:- Public Methods
extension LearningVisualTrackingViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        self.questionId = questionId
        self.command_array = command_array

//        self.listenModelClosures()
//        self.program = program
//        self.skillDomainId = skillDomainId
//        if command_array.count > 0 {
//            self.command_array = command_array
//            self.visualTrackingViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
//        }
    }
}

//MARK:- Private Methods
extension LearningVisualTrackingViewController {
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.visualTrackingViewModal.updateCurrentCommandIndex()
    }
    
    private func initializeFrame()
    {
        self.imageView1.isHidden = false
        self.imageView2.isHidden = false
        self.imageView3.isHidden = false
        self.imageView4.isHidden = false
        self.handImageView.isHidden = false

        let yAxis:CGFloat = UIScreen.main.bounds.height
        let size:CGFloat = 220
        let padding:CGFloat = 50
        imageView1.frame = CGRect(x:padding, y:yAxis, width:size, height:size)
        imageView2.frame = CGRect(x:(UIScreen.main.bounds.width/2) - (size), y:yAxis, width:size, height:size)
        imageView3.frame = CGRect(x:(UIScreen.main.bounds.width/2) + (size/2), y:yAxis, width:size, height:size)
        imageView4.frame = CGRect(x:UIScreen.main.bounds.width - padding - size, y:yAxis, width:size, height:size)
        handImageView.frame = CGRect(x:(UIScreen.main.bounds.width/2) - (size/2) , y:yAxis, width:size, height:size)
    }
    
    private func customSetting() {
        self.initializeFrame()
        self.isGame = false
        self.balloonTapCount = 0
        self.timerTime = 0
        timerMaxTime = 0
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  getIdleGif()
        self.avatarCenterImageView.isHidden = true
        
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.bufferLoaderView.isHidden = true
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        
    }
    
    private func listenModelClosures() {
        self.visualTrackingViewModal.showAvatarClosure = { [weak self] in
             DispatchQueue.main.async {
                if let this = self {
                    this.avatarCenterImageView.isHidden = false
                }
             }
        }
        
        self.visualTrackingViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.visualTrackingViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.visualTrackingViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
        self.visualTrackingViewModal.waveAvatarClosure = { [weak self] in
             DispatchQueue.main.async {
                if let this = self {
                    this.avatarCenterImageView.animatedImage =  getHurrayGif()
                }
             }
        }
        
        self.visualTrackingViewModal.talkAvatarClosure = { [weak self] in
              DispatchQueue.main.async {
                if let this = self {
                    this.avatarCenterImageView.animatedImage =  getTalkingGif()
                }
              }
        }
        
        self.visualTrackingViewModal.showVideoClosure = { urlString in
            DispatchQueue.main.async {
             self.customSetting()
             self.addPlayer(urlString: urlString)
            }
        }
        
        self.visualTrackingViewModal.showSpeechTextClosure = { [weak self] text in
             DispatchQueue.main.async {
                if let this = self {
                    this.speechTitle.text = text
                }
             }
        }
        
       
        self.visualTrackingViewModal.hideAvatarClosure = { [weak self] in
               DispatchQueue.main.async {
                if let this = self {
                    this.avatarCenterImageView.isHidden = true
                    this.speechTitle.text = ""
                }
                 
               }
        }
        
        self.visualTrackingViewModal.noNetWorkClosure = { [weak self] in
            if let this = self {
                Utility.showRetryView(delegate: this)
            }
        }
            
        self.visualTrackingViewModal.clearScreenClosure = { [weak self] in
             DispatchQueue.main.async {
                if let this = self {
                    this.customSetting()
                    this.visualTrackingViewModal.updateCurrentCommandIndex()
                }
             }
        }
        
        self.visualTrackingViewModal.startBalloonGameDemoClosure = {[weak self] commandInfo in
            DispatchQueue.main.async {
                if let this = self,let option = commandInfo.option  {
                    this.timerMaxTime = Int(option.time_in_second) ?? 0
                    this.initializeTimer()
                    this.startDemo()
                }
            }
        }
        
        self.visualTrackingViewModal.startBalloonGameClosure = {[weak self] commandInfo in
            DispatchQueue.main.async {
                if let this = self,let option = commandInfo.option {
                    this.isGame = true
                    this.timerMaxTime = Int(option.time_in_second) ?? 0
                    this.initializeTimer()
                    this.startGame(info: commandInfo)
                }
            }
        }
        
   }
    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = self.visualTrackingViewModal.playerController {
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
    
    private func playVideo() {
        if let item = self.videoItem {
        visualTrackingViewModal.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    private func videoFinished() {
        self.restartButton.isHidden = false
        self.nextButton.isHidden = false
        if let image = self.thumbnailImage {
            self.thumnailImageView.image = image
            self.thumnailImageView.isHidden = false
        }
        self.initializeVideoTimer()
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
    
    private func initializeVideoTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateVideoTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateVideoTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.visualTrackingViewModal.getCurrentCommandInfo(),let option = info.option {
            let time = Int(option.switch_command_time) ?? 0
            if self.videoFinishWaitingTime >= time  {
                self.moveToNextCommand()
            }
        }
    }
    
    
    func initializeTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken() {
        self.timerTime += 1
        print("Current Time ==== \(self.timerTime)")
        if self.timerTime >= self.timerMaxTime {
            stopTimer()
        }
    }
    
    func stopTimer() {
         if let timer = self.gameTimer {
             timer.invalidate()
            self.gameTimer = nil
            self.timerTime = 0
            self.timerMaxTime = 0
         }
        
        if let timer = self.videoFinishTimer {
            print("Video Timer Stop ======== ")
            timer.invalidate()
            self.videoFinishTimer = nil
            self.videoFinishWaitingTime = 0
        }
    }
    
    private func startDemo() {
       
        UIView.animate(withDuration: 6, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                let yAxis = UIScreen.main.bounds.height / 3
                this.handImageView.frame = CGRect(x: yAxis, y: yAxis, width: this.handImageView.frame.height, height: this.handImageView.frame.height)
            }
                   
                } completion: { [weak self]  (isCompleted) in
                    if let this = self {
                        this.handImageView.isHidden = true
                    }
                }
        
        
        UIView.animate(withDuration: 3, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView1.frame = CGRect(x: this.imageView1.frame.origin.x, y: -this.imageView1.frame.height, width: this.imageView1.frame.height, height: this.imageView1.frame.height)
            }
                   
                } completion: { (isCompleted) in
                }
        
        UIView.animate(withDuration: 9, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView2.frame = CGRect(x: this.imageView2.frame.origin.x, y: -this.imageView2.frame.height, width: this.imageView2.frame.height, height: this.imageView2.frame.height)
            }
                } completion: { (isCompleted) in
                }
        
        UIView.animate(withDuration: 5, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView3.frame = CGRect(x: this.imageView3.frame.origin.x, y: -this.imageView3.frame.height, width: this.imageView3.frame.height, height: this.imageView3.frame.height)
            }
                } completion: { (isCompleted) in
                }
        
        
        UIView.animate(withDuration: 8, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView4.frame = CGRect(x: this.imageView4.frame.origin.x, y: -this.imageView4.frame.height, width: this.imageView4.frame.height, height: this.imageView4.frame.height)
            }
                } completion: {[weak self] (isCompleted) in
                    print("Animation Completed")
                    if let this = self {
                        if this.timerTime < this.timerMaxTime {
                            this.initializeFrame()
                            this.startDemo()
                        } else {
                            this.visualTrackingViewModal.updateCurrentCommandIndex()
                        }
                    }
                }
    }
    
    
    private func startGame(info:ScriptCommandInfo) {
        self.totalBalloonInGame += noOfBalloonsAtTime
        UIView.animate(withDuration: 5, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView1.frame = CGRect(x: this.imageView1.frame.origin.x, y: -this.imageView1.frame.height, width: this.imageView1.frame.height, height: this.imageView1.frame.height)
            }
                   
                } completion: { (isCompleted) in
                }
        
        UIView.animate(withDuration: 9, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView2.frame = CGRect(x: this.imageView2.frame.origin.x, y: -this.imageView2.frame.height, width: this.imageView2.frame.height, height: this.imageView2.frame.height)
            }
                } completion: { (isCompleted) in
                }
        
        UIView.animate(withDuration: 7, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView3.frame = CGRect(x: this.imageView3.frame.origin.x, y: -this.imageView3.frame.height, width: this.imageView3.frame.height, height: this.imageView3.frame.height)
            }
                } completion: { (isCompleted) in
                }
        
        
        UIView.animate(withDuration: 12, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView4.frame = CGRect(x: this.imageView4.frame.origin.x, y: -this.imageView4.frame.height, width: this.imageView4.frame.height, height: this.imageView4.frame.height)
            }
                } completion: {[weak self] (isCompleted) in
                    if let this = self {
                        if this.timerTime < this.timerMaxTime {
                            this.initializeFrame()
                            this.startGame(info: info)
                        } else {
                            print("balloonTapCount = \(this.balloonTapCount)")
                            print("totalBalloonInGame = \(this.totalBalloonInGame)")
                            let rate:Double = Double(this.balloonTapCount) / Double(this.totalBalloonInGame)
                            this.isGame = false
                            this.visualTrackingViewModal.calculateBalloonTap(info: info, completeRate: rate*100)
                        }
                    }
                    
                    
                }
    }
    
    
    
 }

extension LearningVisualTrackingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

