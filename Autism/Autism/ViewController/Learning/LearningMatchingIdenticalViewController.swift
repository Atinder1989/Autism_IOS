//
//  LearningMatchingIdenticalViewController.swift
//  Autism
//
//  Created by Savleen on 01/01/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class LearningMatchingIdenticalViewController: UIViewController {
    private let matchingIdenticalViewModal: LearningMatchingIdenticalViewModel = LearningMatchingIdenticalViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []

    private var isTouch = false
    private var isChildAction = false
    private var isCorrectAnswerTapped = false {
        didSet{
            DispatchQueue.main.async { [self] in
                self.matchingIdenticalViewModal.calculateChildAction(state: isCorrectAnswerTapped)
            }
        }
    }
    private var videoItem: VideoItem?
    private var bufferLoaderTimer: Timer?

    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var commandImgViewTop: ScriptCommandImageView!
    @IBOutlet weak var view_Left: UIView!
    @IBOutlet weak var view_Right: UIView!
    @IBOutlet weak var view_Center: UIView!
    @IBOutlet weak var bufferLoaderView: UIView!

    var questionId:String = ""
    
    var selectedObject:UIView!
    private var initialFrame: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.addTapGesture()
        self.customSetting()
        
        if self.command_array.count == 0 {
            //self.matchingIdenticalViewModal.fetchLearningMatchingIdenticalCommands(skillDomainId: self.skillDomainId, program: self.program)
            self.matchingIdenticalViewModal.fetchScriptCommands(skillDomainId: self.skillDomainId, program: self.program)
            if(UIDevice.current.userInterfaceIdiom != .pad) {
                thumnailImageView.contentMode = .scaleAspectFit
            }
        } else {
            self.matchingIdenticalViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
        }
        
//        if self.command_array.count == 0 {
//            self.matchingIdenticalViewModal.fetchScriptCommands(skillDomainId: self.skillDomainId, program: self.program)
//        } else {
//            self.matchingIdenticalViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
        self.matchingIdenticalViewModal.stopAllCommands()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.matchingIdenticalViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.matchingIdenticalViewModal.pausePlayer()
        self.matchingIdenticalViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    @IBAction func skipLearningClicked(_ sender: Any) {
        self.matchingIdenticalViewModal.stopAllCommands()
        self.matchingIdenticalViewModal.skipLearningSubmitLearningMatchingAnswer()
    }
}
//MARK:- Public Methods
extension LearningMatchingIdenticalViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        
        self.listenModelClosures()
        self.program = program
        self.questionId = questionId
        self.skillDomainId = skillDomainId
        self.command_array = command_array

//        self.program = program
//        self.skillDomainId = skillDomainId
//        self.listenModelClosures()
//        if command_array.count > 0 {
//            self.command_array = command_array
//            self.matchingIdenticalViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
//        }
    }
}

//MARK:- Private Methods
extension LearningMatchingIdenticalViewController {
    
    private func moveToNextCommand() {
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.matchingIdenticalViewModal.updateCurrentCommandIndex()
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view_Right.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view_Left.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view_Center.addGestureRecognizer(tap2)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !isChildAction {
            return
        }
        if let gestureSender = sender {
            if let customView = gestureSender.view {
                self.calculateAnswer(customView: customView)
            }
        }
    }

    private func addPanGesture() {

        self.commandImgViewTop.isUserInteractionEnabled = true
        let gestureRecognizer0 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.commandImgViewTop.addGestureRecognizer(gestureRecognizer0)
        
//        if(self.matchingObjectInfo.images.count > 0) {
            let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.view_Left.addGestureRecognizer(gestureRecognizer1)
//        }
//        if(self.matchingObjectInfo.images.count > 1) {
            let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.view_Right.addGestureRecognizer(gestureRecognizer2)
//        }
//        if(self.matchingObjectInfo.images.count > 2) {
            let gestureRecognizer3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.view_Center.addGestureRecognizer(gestureRecognizer3)
//        }
    }
    
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if !isChildAction {
            return
        }
        switch gestureRecognizer.state {
            
            case .began:
            if self.initialFrame == nil && selectedObject == nil {
                self.selectedObject = (gestureRecognizer.view as? UIView)!
                self.initialFrame = self.selectedObject.frame
            }
            break
        case .changed:

            let currentFilledPattern:UIView = (gestureRecognizer.view as? UIView)!
            
            if(selectedObject != currentFilledPattern) {
                return
            }
            
            if self.initialFrame == nil && selectedObject == nil {
                return
            }
            let translation = gestureRecognizer.translation(in: self.view)
            self.selectedObject.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
            
            let currentFilledImageView:UIView = (gestureRecognizer.view)!
            
            if self.initialFrame == nil && selectedObject == nil {
                return
            }
            
            if(selectedObject != currentFilledImageView) {
                return
            }
            
            let dropLocation = gestureRecognizer.location(in: view)            
            
            var isAnswer = false
            
            if(currentFilledImageView == commandImgViewTop) {
                if(commandImgViewTop.commandInfo?.option!.correct_option == "1") {
                    if view_Left.frame.contains(dropLocation) {
                        isAnswer = true
                    }
                } else if(commandImgViewTop.commandInfo?.option!.correct_option == "2") {
                    if view_Right.frame.contains(dropLocation) {
                        isAnswer = true
                    }
                } else if(commandImgViewTop.commandInfo?.option!.correct_option == "3") {
                    if view_Center.frame.contains(dropLocation) {
                        isAnswer = true
                    }
                }
            } else {
                for subview in currentFilledImageView.subviews {
                    if let scriptImageView = subview as? ScriptCommandImageView {
                        let imageViewInfo = scriptImageView.commandInfo
                        print("value_id = ", imageViewInfo?.value_id)
                        
                        if let currentCommand = self.matchingIdenticalViewModal.getCurrentCommandInfo() {
                            if imageViewInfo?.value_id == currentCommand.value_id {
                                                            
                                if(imageViewInfo?.option!.correct_option == "1") {
                                    if view_Left.frame.contains(dropLocation) {
                                        isAnswer = true
                                    }
                                } else if(imageViewInfo?.option!.correct_option == "2") {
                                    if view_Right.frame.contains(dropLocation) {
                                        isAnswer = true
                                    }
                                } else if(imageViewInfo?.option!.correct_option == "3") {
                                    if view_Center.frame.contains(dropLocation) {
                                        isAnswer = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(isAnswer == true) {
                currentFilledImageView.isHidden = true
                self.isCorrectAnswerTapped = isAnswer
            } else {
                if let frame = self.initialFrame {
                    self.selectedObject.frame = frame
                    self.initialFrame = nil
                    self.selectedObject = nil
                }
                SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
            
            break
        default:
            break
        }
    }
    
    //MARK:- Helper
//    private func handleInvalidDropLocation(currentImageView:ImageViewWithID){
//        DispatchQueue.main.async {
//            if let frame = self.initialFrame {
//                self.selectedObject.frame = frame
//                self.initialFrame = nil
//                self.selectedObject = nil
//            }
//            self.incorrectDragDropCount += 1
//            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
//        }
//    }
    
    private func calculateDropAnswer(customView:UIView) {
        var isAnswer = false
        for subview in customView.subviews {
            if let scriptImageView = subview as? ScriptCommandImageView {
                if let currentCommand = self.matchingIdenticalViewModal.getCurrentCommandInfo(), let imageViewInfo = scriptImageView.commandInfo {
                    if imageViewInfo.value_id == currentCommand.value_id {
                        isAnswer = true
                    }
                }
            }
            if let foundView:UIImageView = subview.viewWithTag(10) as? UIImageView {
                foundView.image = isAnswer ? UIImage.init(named: "greenTick") : UIImage.init(named: "cross")
            }
        }
        self.isCorrectAnswerTapped = isAnswer
    }


    private func calculateAnswer(customView:UIView) {
        var isAnswer = false
        for subview in customView.subviews {
            if let scriptImageView = subview as? ScriptCommandImageView {
                if let currentCommand = self.matchingIdenticalViewModal.getCurrentCommandInfo(), let imageViewInfo = scriptImageView.commandInfo {
                    if imageViewInfo.value_id == currentCommand.value_id {
                        isAnswer = true
                    }
                }
            }
            if let foundView:UIImageView = subview.viewWithTag(10) as? UIImageView {
                foundView.image = isAnswer ? UIImage.init(named: "greenTick") : UIImage.init(named: "cross")
            }
        }
        self.isCorrectAnswerTapped = isAnswer
    }
    
    private func setImageOnView(customView:UIView,questionInfo:ScriptCommandInfo,url:String) {
        for subview in customView.subviews {
            if let imageView = subview as? ScriptCommandImageView {
                let commandImageView = imageView
                commandImageView.commandInfo = questionInfo
                //if commandImageView.image == nil {
                    commandImageView.setImageWith(urlString: url)
               // }
            }
            if let foundView:UIImageView = subview.viewWithTag(10) as? UIImageView {
                let image = UIImage.init()
                foundView.image = image
            }
        }
    }
    
    private func findCorrectAnswerView(questionInfo:ScriptCommandInfo) -> UIView? {
        var answerView: UIView? = nil
        for subview in self.view.subviews {
            if let foundView:UIView = subview.viewWithTag(1000) {
                for tapAbleView in foundView.subviews {
                    if let imageView = tapAbleView as? ScriptCommandImageView {
                        if let imageViewInfo = imageView.commandInfo {
                            if imageViewInfo.value_id == questionInfo.value_id {
                                answerView = foundView
                            }
                        }
                    }
                }
            }
            if answerView != nil {
                break
            }
        }
        return answerView
    }
    
    private func showHandAnimationOnAnswer(customView:UIView,questionInfo:ScriptCommandInfo) {
        for subview in customView.subviews {
            if let foundView:UIImageView = subview.viewWithTag(100) as? UIImageView {
                foundView.image = UIImage.init(named: "dragHand")
            }
        }
        if let _ = questionInfo.option {
            let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            for subview in customView.subviews {
                if let foundView:UIImageView = subview.viewWithTag(100) as? UIImageView {
                    foundView.image = UIImage.init()
                }
            }
            self.matchingIdenticalViewModal.animationCompleted()
        }
        }
    }
    
    private func customSetting() {
        self.isChildAction = false
        self.isTouch = false
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.commandImgViewTop.isHidden = true
        self.view_Right.isHidden = true
        self.view_Left.isHidden = true
        self.view_Center.isHidden = true
        self.bufferLoaderView.isHidden = true
    }
    
    private func listenModelClosures() {
        
        self.matchingIdenticalViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.matchingIdenticalViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.matchingIdenticalViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
        self.matchingIdenticalViewModal.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
        
        self.matchingIdenticalViewModal.showVideoClosure = { urlString in
            DispatchQueue.main.async {
             self.customSetting()
             self.addPlayer(urlString: urlString)
            }
        }
        
        self.matchingIdenticalViewModal.showSpeechTextClosure = { text in
             DispatchQueue.main.async {
                 self.speechTitle.text = text
             }
        }
        
        self.matchingIdenticalViewModal.showImageClosure = { questionInfo in
             DispatchQueue.main.async {
                 print("showImageClosure")
                 if let option = questionInfo.option {
                     let url = ServiceHelper.baseURL.getMediaBaseUrl() + questionInfo.value
                     if option.Position == ScriptCommandOptionType.left.rawValue {
                        self.view_Left.isHidden = false
                        self.setImageOnView(customView: self.view_Left, questionInfo: questionInfo, url: url)
                     } else if option.Position == ScriptCommandOptionType.right.rawValue {
                        self.view_Right.isHidden = false
                        self.setImageOnView(customView: self.view_Right, questionInfo: questionInfo, url: url)
                     } else if option.Position == ScriptCommandOptionType.center.rawValue {
                        self.view_Center.isHidden = false
                        self.setImageOnView(customView: self.view_Center, questionInfo: questionInfo, url: url)
                     }
                     else if option.Position == ScriptCommandOptionType.top.rawValue {
                         self.commandImgViewTop.isHidden = false
                         self.commandImgViewTop.commandInfo = questionInfo
                         self.commandImgViewTop.setImageWith(urlString: url)
                     }
                 }
             }
        }
        //showImages
        self.matchingIdenticalViewModal.showImagesClosure = {commandInfo in
            DispatchQueue.main.async {
                self.addPanGesture()
                var array:[ImageModel] = []
                for (index, element) in commandInfo.valueList.enumerated() {
                    var model = ImageModel.init()
                    model.id = commandInfo.value_idList[index]
                    model.image = element
                    array.append(model)
                }
                
                if(array.count == 3) {
                                        
                    let urlL = ServiceHelper.baseURL.getMediaBaseUrl() + array[0].image
                    let urlC = ServiceHelper.baseURL.getMediaBaseUrl() + array[2].image
                    let urlR = ServiceHelper.baseURL.getMediaBaseUrl() + array[1].image
                    
                    let L_id = array[0].id
                    let C_id = array[2].id
                    let R_id = array[1].id
                    
                    var commandInfoL:ScriptCommandInfo = commandInfo
                    commandInfoL.value_id = L_id
                    self.view_Left.isHidden = false
                    self.setImageOnView(customView: self.view_Left, questionInfo: commandInfoL, url: urlL)
                    
                    var commandInfoR:ScriptCommandInfo = commandInfo
                    commandInfoR.value_id = R_id
                    self.view_Right.isHidden = false
                    self.setImageOnView(customView: self.view_Right, questionInfo: commandInfoR, url: urlR)
                    
                    var commandInfoC:ScriptCommandInfo = commandInfo
                    commandInfoC.value_id = C_id
                    self.view_Center.isHidden = false
                    self.setImageOnView(customView: self.view_Center, questionInfo: commandInfoC, url: urlC)
                    
                    if let option = commandInfo.option {
                        let cIndex = Int(option.correct_option) ?? 1

                        var commandInfoT:ScriptCommandInfo = commandInfo
                        commandInfoT.value_id = array[cIndex-1].id
                        commandInfoT.option = option
                        self.commandImgViewTop.isHidden = false
                        self.commandImgViewTop.commandInfo = commandInfoT
                    
                        self.commandImgViewTop.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + array[cIndex-1].image)
                    }
                    //self.commandImgViewTop.setImageWith(urlString: urlR)
                } else if(array.count == 2) {
                    
                    let urlL = ServiceHelper.baseURL.getMediaBaseUrl() + array[0].image
                    let urlR = ServiceHelper.baseURL.getMediaBaseUrl() + array[1].image

                    self.view_Left.isHidden = false
                    self.setImageOnView(customView: self.view_Left, questionInfo: commandInfo, url: urlL)
                    
                    self.view_Right.isHidden = false
                    self.setImageOnView(customView: self.view_Right, questionInfo: commandInfo, url: urlR)

                } else if(array.count == 1) {
                    let url = ServiceHelper.baseURL.getMediaBaseUrl() + array[0].image

                    self.view_Center.isHidden = false
                    self.setImageOnView(customView: self.view_Center, questionInfo: commandInfo, url: url)
                } else {
                    
                }
                
            }
        }
        self.matchingIdenticalViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                self.isChildAction = state
             }
        }
        
        self.matchingIdenticalViewModal.clearScreenClosure = {
              DispatchQueue.main.async {
                  self.customSetting()
              }
        }
        
        self.matchingIdenticalViewModal.showTapFingerAnimationClosure = { questionInfo in
             DispatchQueue.main.async {
                if let csView = self.findCorrectAnswerView(questionInfo: questionInfo) {
                    self.showHandAnimationOnAnswer(customView: csView, questionInfo: questionInfo)
                }
             }
        }
    }
        
    
    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = matchingIdenticalViewModal.playerController {
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
        matchingIdenticalViewModal.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.matchingIdenticalViewModal.stopVideo()
    }
    
    @objc func videoFinished() {
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
        if let info = self.matchingIdenticalViewModal.getCurrentCommandInfo(),let option = info.option {
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



extension LearningMatchingIdenticalViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


