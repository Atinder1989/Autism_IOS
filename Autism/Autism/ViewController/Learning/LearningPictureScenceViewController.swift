//
//  LearningPictureScenceViewController.swift
//  Autism
//
//  Created by Dilip Saket on 21/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class LearningPictureScenceViewController: UIViewController {
    private let commandSolidViewModal: LearningPictureScenceViewModel = LearningPictureScenceViewModel()
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
                    self.commandSolidViewModal.calculateChildAction(state: self.isChildActionCompleted, touch: self.isTouch)
                }
            }
        }
    }
    private var selectedIndex = -1 {
        didSet {
            DispatchQueue.main.async {
//                self.imagesCollectionView.reloadData()
            }
        }
    }
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipLearningButton: UIButton!
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var bufferLoaderView: UIView!
    private var bufferLoaderTimer: Timer?

    private var imageList = [ImageModel]() {
        didSet{
            DispatchQueue.main.async {
                //self.showPictureScence()
            }
        }
    }
     
    var questionId = ""
    var isFromViewdidLoad:Bool = true

    var matrixOf:CGFloat = 4

    var w:CGFloat = 100*1.22
    var h:CGFloat = 100

    var x:CGFloat = 0.0
    var y:CGFloat = 0.0

    var allScene:[PictureSceneView] = []
    
    let imgViewPrompt = UIImageView()
    
    var touchOnEmptyScreenCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.customSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromViewdidLoad {
            isFromViewdidLoad = false
            
            if self.command_array.count == 0 {
                self.commandSolidViewModal.fetchLearningSolidQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
                if(UIDevice.current.userInterfaceIdiom != .pad) {
                    thumnailImageView.contentMode = .scaleAspectFit
                }
            } else {
                self.commandSolidViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
        self.commandSolidViewModal.stopAllCommands()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.commandSolidViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }

    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.commandSolidViewModal.pausePlayer()
        self.commandSolidViewModal.stopAllCommands()
        
        SpeechManager.shared.stopSpeech()
        FaceDetection.shared.stopFaceDetectionSession()
        AutismTimer.shared.stopTimer()
        
        if !UserManager.shared.get_isActionPerformed() {
            UserManager.shared.set_isActionPerformed(true)
            UserManager.shared.updateScreenId(screenid: ScreenRedirection.dashboard.rawValue)
                
            self.dismiss(animated: true)
        }
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(touchOnEmptyScreenCount > 0) {
            return
        }

        if let touch = touches.first {
            let position = touch.location(in: view)
            print(position)
            
            for viewSceneCorrect in self.allScene {
                if(viewSceneCorrect != nil) {
                    touchOnEmptyScreenCount += 1
                    if(viewSceneCorrect.frame.contains(position)) {
                        self.isTouch = true
                        self.isChildActionCompleted = true
                        //self.questionState = .submit
                        //SpeechManager.shared.speak(message: self.pictureSceneInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                        break
                    } else {
//                        self.success_count = 0
//                        self.questionState = .submit
//                        self.animateTheRightImage(imageView: viewSceneCorrect)
                    }
                }
            }
            if(self.isChildActionCompleted == false) {
                self.isTouch = false
                self.isChildActionCompleted = true
            }
        }
    }

}
//MARK:- Public Methods
extension LearningPictureScenceViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        self.questionId = questionId
        self.command_array = command_array
    }
}

//MARK:- Private Methods
extension LearningPictureScenceViewController {
    
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.commandSolidViewModal.updateCurrentCommandIndex()
    }
    
    private func customSetting() {
        self.imageList = []
        self.isTouch = false
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        isChildActionCompleted = false
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.isChildAction = false
        self.bufferLoaderView.isHidden = true
        selectedIndex = -1
        isImagesDownloaded = false
    }
    
    private func listenModelClosures() {
        self.commandSolidViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.commandSolidViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.commandSolidViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
       self.commandSolidViewModal.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
               
       self.commandSolidViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.commandSolidViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.commandSolidViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.commandSolidViewModal.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.commandSolidViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                //self.view.isUserInteractionEnabled = state
                self.isChildAction = state
             }
        }
       
       self.commandSolidViewModal.showImagesClosure = {commandInfo in
           
           DispatchQueue.main.async { [self] in
                
               var array : [ImageModel] = []
               if let option = commandInfo.option {
                   var correctIndexes:[Int] = []

                   let options:[String] = option.correct_options
                   for opt in options {
                       let cIndex:Int = (Int(opt) ?? 0) - 1
                       correctIndexes.append(cIndex)
                   }

                   for (index, element) in commandInfo.valueList.enumerated() {
                       var iModel = ImageModel.init()
                       iModel.image = element
                       iModel.id = commandInfo.value_idList[index]
                                                                               
                       if correctIndexes.contains(index) {
                           iModel.isCorrectAnswer = true
                       } else {
                           iModel.isCorrectAnswer = false
                       }
                       array.append(iModel)
                   }
               }
            
               self.imageList.removeAll()
               self.imageList = array
               self.showPictureScence()
               self.commandSolidViewModal.updateCurrentCommandIndex()
            }
       }
        
        self.commandSolidViewModal.showImageClosure = {commandInfo in
            
            DispatchQueue.main.async { [self] in
                 
                let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + commandInfo.value
                self.imgViewPrompt.setImageWith(urlString: urlString)
                self.imgViewPrompt.isUserInteractionEnabled = false
                self.commandSolidViewModal.updateCommandIndex()
             }
        }
        self.commandSolidViewModal.showFingerClosure = {
             DispatchQueue.main.async {
                self.selectedIndex = -1
                self.updateImageListWithShowFinger()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.resetImageList()
                }
             }
        }
        self.commandSolidViewModal.showTapFingerAnimationClosure = {
             DispatchQueue.main.async {
                self.updateImageListWithShowTapFingerAnimation()
                let deadlineTime = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.commandSolidViewModal.calculateChildAction(state: false, touch: self.isTouch)
                    self.commandSolidViewModal.updateCurrentCommandIndex()
                }
             }
        }
        
        self.commandSolidViewModal.blinkImageClosure = { questionInfo in
            
            DispatchQueue.main.async {
                for v in self.allScene {
                    if(questionInfo.value_id == v.iModel?.id) {
                        self.blinkImage(count: 2, imageView: v)
                        break;
                    }
                }
               let deadlineTime = DispatchTime.now() + .seconds(3)
               DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                   self.commandSolidViewModal.calculateChildAction(state: false, touch: self.isTouch)
                   self.commandSolidViewModal.updateCommandIndex()
               }
            }
        }
    }
    
    private func showPictureScence() {
        
        let space:CGFloat = 0.0

        if(self.imageList.count == 4) {
            matrixOf = 2
        } else if(self.imageList.count == 9) {
            matrixOf = 3
        }

        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let screenHeight:CGFloat = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        
        let screenW4:CGFloat = screenWidth/matrixOf
        let screenH4:CGFloat = screenHeight/matrixOf
        
        var cW:CGFloat = 100*1.22
        var cH:CGFloat = 100

        var xRef:CGFloat = 100.0
        var yRef:CGFloat = 220.0

        if(((screenH4*1.22)*matrixOf) > screenWidth) {
            cW = screenW4
            cH = screenW4*0.45
        } else {
            cH = screenH4
            cW = screenH4*2.22
        }

        xRef = (screenWidth-(cW*matrixOf))/2.0
        yRef = (screenHeight-(cH*matrixOf))/2.0
                
        self.x = xRef
        self.y = yRef
        self.w = cW
        self.h = cH

        var index:Int = 0

        for i in 0..<Int(matrixOf) {

            for j in 0..<Int(matrixOf) {

                let iModel:ImageModel = self.imageList[index]

                let viewScene = PictureSceneView()
                viewScene.iModel = iModel
                viewScene.tag = index
                viewScene.frame =  CGRect(x:xRef, y: yRef, width: cW, height: cH)
                viewScene.tag = Int(i*Int(matrixOf))+j
                viewScene.backgroundColor = .white
                viewScene.clipsToBounds = true
                self.view.addSubview(viewScene)
                
                
                if(iModel.isCorrectAnswer == true) {
                    self.allScene.append(viewScene)
                }
                
                let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + iModel.image
                viewScene.setImageWith(urlString: urlString)

                xRef = xRef+space+cW

                index = index+1
            }
            xRef = (screenWidth-(cW*4.0))/2.0
            yRef = yRef+cH+space
        }
        
        self.view.bringSubviewToFront(self.speechTitle)
        self.view.bringSubviewToFront(self.skipLearningButton)
        self.view.bringSubviewToFront(self.nextButton)
        self.view.bringSubviewToFront(self.restartButton)
        
        self.imgViewPrompt.frame = CGRect(x: self.x, y: self.y, width: self.w*CGFloat(self.matrixOf), height: self.h*CGFloat(self.matrixOf))
        self.imgViewPrompt.backgroundColor = .clear
        self.view.addSubview(imgViewPrompt)
    }
    
    private func blinkImage(count:Int,imageView:UIView) {
        if count == 0 {
            self.commandSolidViewModal.updateCommandIndex()
            return
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, animations: {
                    imageView.alpha = 0.5
                }) { [weak self] finished in
                    if let this = self {
                        imageView.alpha = 1
                        this.blinkImage(count: count - 1,imageView:imageView)
                    }
                }
        }
    }

//    private func blinkImage(count:Int,imageView:UIImageView) {
//        if count == 0 {
//            for (index,element) in self.imageList.enumerated() {
//                var model:AnimationImageModel = AnimationImageModel()
//                model = element
//                model.isBlink = false
//                self.imageList.remove(at: index)
//                self.imageList.insert(model, at: index)
//            }
//            return
//        }
//
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 1, animations: {
//                    imageView.alpha = 0.2
//                }) { [weak self] finished in
//                    if let this = self {
//                    imageView.alpha = 1
//                        this.blinkImage(count: count - 1,imageView:imageView)
//                    }
//                }
//        }
//    }
       
    private func updateImageListWithShowFinger() {
//        var array : [AnimationImageModel] = []
//        for element in self.imageList {
//            var scModel = element
//            if element.correct_option == ScriptCommandOptionType.actiontrue {
//                scModel.isShowFinger = true
//            } else {
//                scModel.isShowFinger = false
//            }
//            array.append(scModel)
//        }
//        self.imageList.removeAll()
//        self.imageList = array
    }
    
    private func updateImageListWithBlinkImageAnimation() {
//        var array : [AnimationImageModel] = []
//        for element in self.imageList {
//            var scModel = element
//            if element.correct_option == ScriptCommandOptionType.actiontrue {
//                scModel.isBlink = true
//            } else {
//                scModel.isBlink = false
//            }
//            array.append(scModel)
//        }
//        self.imageList.removeAll()
//        self.imageList = array
    }

    private func updateImageListWithShowTapFingerAnimation() {
//        var array : [AnimationImageModel] = []
//        for element in self.imageList {
//            var scModel = element
//            if element.correct_option == ScriptCommandOptionType.actiontrue {
//                scModel.isShowTapFingerAnimation = true
//                scModel.isShowFinger = true
//            } else {
//                scModel.isShowTapFingerAnimation = false
//                scModel.isShowFinger = false
//            }
//            array.append(scModel)
//        }
//        self.imageList.removeAll()
//        self.imageList = array
    }
    
    private func resetImageList() {
//        var array : [AnimationImageModel] = []
//        for element in self.imageList {
//            var scModel = element
//            scModel.isShowFinger = false
//            array.append(scModel)
//        }
//        self.imageList.removeAll()
//        self.imageList = array
    }
    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = commandSolidViewModal.playerController {
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
        commandSolidViewModal.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.commandSolidViewModal.stopVideo()
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
        if let info = self.commandSolidViewModal.getCurrentCommandInfo(),let option = info.option {
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

extension LearningPictureScenceViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

extension LearningPictureScenceViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
            self.commandSolidViewModal.updateCurrentCommandIndex()
        }
    }
}
