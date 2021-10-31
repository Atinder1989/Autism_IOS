//
//  LearningSpellingViewController.swift
//  Autism
//
//  Created by Savleen on 19/01/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

class LearningSpellingViewController: UIViewController {
    private let spellingViewModel: LearningSpellingViewModel = LearningSpellingViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []

    private var videoItem: VideoItem?

    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0
    private var isChildAction = false {
        didSet{
            self.txtAnswer.isUserInteractionEnabled = isChildAction
            if isChildAction {
                self.txtAnswer.isHidden = !isChildAction
                self.submitButton.isHidden = !isChildAction
                self.txtAnswer.becomeFirstResponder()
            } else {
                self.txtAnswer.resignFirstResponder()
            }
        }
    }
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var thumnailImageView: UIImageView!

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var txtAnswer: UITextField!
    @IBOutlet weak var skipLearningButton: UIButton!
    @IBOutlet weak var bufferLoaderView: UIView!
    private var bufferLoaderTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.skipLearningButton.isHidden = isSkipLearningHidden
        self.customSetting()
        if self.command_array.count == 0 {
            self.spellingViewModel.fetchLearningQuestion(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMatchSpellingViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMatchSpellingViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        self.stopPlayer()
        self.hideBufferLoader()

    }
 
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.spellingViewModel.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.spellingViewModel.pausePlayer()
        self.spellingViewModel.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipLearningClicked(_ sender: Any) {
        self.spellingViewModel.stopAllCommands()
        self.spellingViewModel.skipLearningSubmitLearningMatchingAnswer()
    }
    @IBAction func submitAnswerClicked(_ sender: Any) {
        if !isChildAction {
            return
        }
        self.spellingViewModel.handleUserAnswer(text: self.txtAnswer.text!)

    }
}

//MARK:- Public Methods
extension LearningSpellingViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.spellingViewModel.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)

        }
    }
}

//MARK:- Private Methods
extension LearningSpellingViewController {
    private func moveToNextCommand() {
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.spellingViewModel.updateCurrentCommandIndex()

    }
    
    private func customSetting() {
        Utility.setView(view: txtAnswer, cornerRadius: 5, borderWidth: 2, color: UIColor.purpleBorderColor)
        isChildAction = false
        self.questionImageView.isHidden = true
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        self.txtAnswer.text = ""
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.txtAnswer.isHidden = true
        self.submitButton.isHidden = true
        self.bufferLoaderView.isHidden = true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    private func listenModelClosures() {
        self.spellingViewModel.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.spellingViewModel.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.spellingViewModel.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
        self.spellingViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
            
        self.spellingViewModel.showVideoClosure = { urlString in
            DispatchQueue.main.async {
             self.addPlayer(urlString: urlString)
            }
        }
        
       self.spellingViewModel.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }

       self.spellingViewModel.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
         
        self.spellingViewModel.childActionStateClosure = { state in
             DispatchQueue.main.async {
                self.isChildAction = state
             }
        }
        

        self.spellingViewModel.showImageClosure = { questionInfo in
             DispatchQueue.main.async {
                if let option = questionInfo.option {
                     let url = ServiceHelper.baseURL.getMediaBaseUrl() + questionInfo.value
                    if option.Position == ScriptCommandOptionType.center.rawValue {
                         self.questionImageView.isHidden = false
                         self.questionImageView.setImageWith(urlString: url)
                     }
                }
             }
        }
    }
       
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = spellingViewModel.playerController {
            if let avplayerController = playerController.avPlayerController {
                self.playerView.isHidden = false
                self.playerView.addSubview(avplayerController.view)
                avplayerController.view.frame = self.playerView.frame
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
        spellingViewModel.playVideo(item: item)
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
        self.spellingViewModel.stopVideo()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.spellingViewModel.getCurrentCommandInfo(),let option = info.option {
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


extension LearningSpellingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

