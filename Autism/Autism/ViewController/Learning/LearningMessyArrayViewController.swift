//
//  LearningMessyArrayViewController.swift
//  Autism
//
//  Created by Dilip Saket on 02/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class LearningMessyArrayViewController: UIViewController {

    private let messyArrayViewModel: LearningMessyArrayViewModel = LearningMessyArrayViewModel()
    
    @IBOutlet weak var imageViewRight:  UIImageView!
    @IBOutlet weak var imageViewCroos:  UIImageView!
    
    @IBOutlet weak var imageViewBG:  ImageViewWithID!
    
    @IBOutlet weak var imageView1:  ImageViewWithID!
    @IBOutlet weak var imageView2:  ImageViewWithID!
    @IBOutlet weak var imageView3:  ImageViewWithID!
    @IBOutlet weak var imageView4:  ImageViewWithID!
    @IBOutlet weak var imageView5:  ImageViewWithID!
    @IBOutlet weak var imageView6:  ImageViewWithID!
    @IBOutlet weak var imageView7:  ImageViewWithID!
    @IBOutlet weak var imageView8:  ImageViewWithID!
    @IBOutlet weak var imageView9:  ImageViewWithID!
    @IBOutlet weak var imageView10: ImageViewWithID!
    @IBOutlet weak var imageViewTouched: ImageViewWithID?

    
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipLearningButton: UIButton!
    @IBOutlet weak var bufferLoaderView: UIView!
    private var bufferLoaderTimer: Timer?

    
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    var questionId = ""

    private var imageList = [AnimationImageModel]() {
        didSet{
            DispatchQueue.main.async {
//                self.imagesCollectionView.reloadData()
            }
        }
    }

    private var isImagesDownloaded = false
    private var isChildAction = false
    private var videoItem: VideoItem?
    private var isChildActionCompleted = false {
        didSet {
            if isChildActionCompleted {
                DispatchQueue.main.async {
                    self.messyArrayViewModel.calculateChildAction(state: self.isChildActionCompleted, touch: self.isTouch)
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

    
    var downloaded10Images:Bool = false
    var wh:CGFloat = 160.0
    
    private var isTouch = false
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
                self.messyArrayViewModel.fetchLearningSolidQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
                if(UIDevice.current.userInterfaceIdiom != .pad) {
                    thumnailImageView.contentMode = .scaleAspectFit
                }
            } else {
                self.messyArrayViewModel.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
            }
        }
    }
    private func customSetting() {
        
        imageViewBG.alpha = 0.9
        imageViewBG.backgroundColor = .clear
        imageViewBG.isHidden = false
        
//        self.initializeFilledImageView()

//        labelTitle.text = matchingObjectInfo.question_title
//        AutismTimer.shared.initializeTimer(delegate: self)
    }

    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        self.questionId = questionId
        self.command_array = command_array
    }
    
    private func initializeFilledImageView() {
        
        self.initializeTheFrames()
        if(self.imageList.count > 0) {
            imageView1.aModel = self.imageList[0]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.imageList[0].url, imageView: imageView1, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }

        if(self.imageList.count > 1) {
            imageView2.aModel = self.imageList[1]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[1].url, imageView: imageView2, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        
        if(self.imageList.count > 2) {
            imageView3.aModel = self.imageList[2]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[2].url, imageView: imageView3, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 3) {
            imageView4.aModel = self.imageList[3]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.imageList[3].url, imageView: imageView4, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 4) {
            imageView5.aModel = self.imageList[4]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[4].url, imageView: imageView5, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 5) {
            imageView6.aModel = self.imageList[5]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[5].url, imageView: imageView6, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 6) {
            imageView7.aModel = self.imageList[6]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[6].url, imageView: imageView7, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 7) {
            imageView8.aModel = self.imageList[7]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[7].url, imageView: imageView8, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 8) {
            imageView9.aModel = self.imageList[8]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[8].url, imageView: imageView9, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 9) {
            imageView10.aModel = self.imageList[9]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[9].url, imageView: imageView10, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        
//        let type = AssessmentQuestionType.init(rawValue: self.matchingObjectInfo.screen_type)
//
//        if(type == .match_object_drag_with_messy_array) {
//            self.addPanGesture()
//        }
    }
    
    func initializeTheFrames() {
        
        let screenW:CGFloat = UIScreen.main.bounds.width
        let screenH:CGFloat = UIScreen.main.bounds.height

        
        var y:CGFloat = 300
        
        var ySpace:CGFloat = 20.0
        var xSpace:CGFloat = (screenW-(5*wh))/6.0
        var xRef:CGFloat = xSpace
        
        
        var yRef:CGFloat = y+wh+ySpace

        if(UIDevice.current.userInterfaceIdiom != .pad) {
            y = 160
            wh = 70
            
            ySpace = 10
            xSpace = (screenW-(5*wh))/6.0
            
            xRef = xSpace
            yRef = screenH-safeAreaBottom-100//y+wh+ySpace
        }

        let noOfImages:Int = self.imageList.count
        
        if(noOfImages < 4) {
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: yRef-ySpace-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace

        } else if(noOfImages == 4) {
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            //imageView5.frame = CGRect(x: xRef, y: yRef-ySpace-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView4.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace

        } else if(noOfImages > 4) {
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView4.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: yRef-ySpace-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView5.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
        }
        
        yRef = y
        xRef = xSpace
        
        if(noOfImages == 6) {
            xRef = xRef+wh+xSpace
            xRef = xRef+wh+xSpace
            
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
        } else if(noOfImages == 7) {
            imageView9.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView8.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0)+ySpace, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView10.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
        } else if(noOfImages == 9) {
            imageView8.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            //imageView8.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0)+ySpace, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView9.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace

        } else {
            imageView9.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView8.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0)+ySpace, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView10.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
        }
        
//        if(UIDevice.current.userInterfaceIdiom != .pad) {
//            self.imageViewRight.frame = CGRect(x: currectObject!.center.x+(wh/2.0)-24, y: currectObject!.center.y+(wh/2.0)-24, width: 24, height: 24)
//        } else {
//            self.imageViewRight.frame = CGRect(x: currectObject!.center.x+(wh/2.0)-34, y: currectObject!.center.y+(wh/2.0)-34, width: 34, height: 34)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touchOnEmptyScreenCount += 1
        
        if let touch = touches.first {
            let position = touch.location(in: view)
            print(position)

           if(imageView1.frame.contains(position)) {
               imageViewTouched = imageView1
           } else if(imageView2.frame.contains(position)) {
               imageViewTouched = imageView2
           } else if(imageView3.frame.contains(position)) {
               imageViewTouched = imageView3
           } else if(imageView4.frame.contains(position)) {
                imageViewTouched = imageView4
           } else if(imageView5.frame.contains(position)) {
                imageViewTouched = imageView5
           } else if(imageView6.frame.contains(position)) {
                imageViewTouched = imageView6
           } else if(imageView7.frame.contains(position)) {
                imageViewTouched = imageView7
           } else if(imageView8.frame.contains(position)) {
                imageViewTouched = imageView8
           } else if(imageView9.frame.contains(position)) {
                imageViewTouched = imageView9
           } else if(imageView10.frame.contains(position)) {
                imageViewTouched = imageView10
           } else {
                imageViewTouched = nil
           }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let type = AssessmentQuestionType.init(rawValue: self.matchingObjectInfo.screen_type)
//
//        if(type == .match_object_drag_with_messy_array) {
//            return
//        }
        
        if let touch = touches.first {
            self.isTouch = true
                let position = touch.location(in: view)
                print(position)
            if(imageViewTouched != nil) {
                if(self.imageViewTouched!.frame.contains(position)) {
                    
                    //let iMdl = self.matchingObjectInfo.image_with_text[answerIndex]
                    
                    if(self.imageViewTouched?.aModel?.correct_option == ScriptCommandOptionType.actiontrue) {
                        self.isChildActionCompleted = true
//                        self.success_count = 100
//                        self.questionState = .submit
                        imageViewRight.isHidden = false
                        imageViewCroos.isHidden = true
                        SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    } else {
                        self.isChildActionCompleted = false
                        if(UIDevice.current.userInterfaceIdiom != .pad) {
                            self.imageViewCroos.frame = CGRect(x: imageViewTouched!.center.x+(wh/2.0)-24, y: imageViewTouched!.center.y+(wh/2.0)-24, width: 24, height: 24)
                        } else {
                            self.imageViewCroos.frame = CGRect(x: imageViewTouched!.center.x+(wh/2.0)-34, y: imageViewTouched!.center.y+(wh/2.0)-34, width: 34, height: 34)
                        }

//                        self.success_count = 0
//                        self.questionState = .submit
                        imageViewRight.isHidden = false
                        imageViewCroos.isHidden = false
//                        let speechText = SpeechMessage.rectifyAnswer.getMessage()+iMdl.name
//                        self.animateTheRightImage(speechText)
                    }
                }
            }
        }
    }

}

//MARK: - Private
extension LearningMessyArrayViewController {
    
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.messyArrayViewModel.updateCurrentCommandIndex()
    }
        
    private func listenModelClosures() {
        self.messyArrayViewModel.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.messyArrayViewModel.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.messyArrayViewModel.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
       self.messyArrayViewModel.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
               
       self.messyArrayViewModel.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.messyArrayViewModel.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.messyArrayViewModel.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.messyArrayViewModel.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.messyArrayViewModel.childActionStateClosure = { state in
             DispatchQueue.main.async {
                //self.view.isUserInteractionEnabled = state
                self.isChildAction = state
             }
        }
       
       self.messyArrayViewModel.showImagesClosure = {commandInfo in
           DispatchQueue.main.async { [self] in
                var array : [AnimationImageModel] = []
                if let option = commandInfo.option {
                    let correctOption = (Int(option.correct_option) ?? 0) - 1
                   
                    for (index, element) in commandInfo.valueList.enumerated() {
                        var scModel = AnimationImageModel.init()
                        scModel.url = element
                        scModel.value_id = commandInfo.value_idList[index]
                        
                        if index == correctOption {
                            scModel.correct_option = ScriptCommandOptionType.actiontrue
                        } else {
                            scModel.correct_option = ScriptCommandOptionType.actionfalse
                        }
                        scModel.isShowFinger = false
                        scModel.isShowTapFingerAnimation = false
                        scModel.isCircleShape = option.show_circle
                        array.append(scModel)
                    }
                }
               
                let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
                let screenHeight:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.height)

                if(UIDevice.current.userInterfaceIdiom != .pad) {
                                       
                } else {
                                      
                }

                self.imageList.removeAll()
                self.imageList = array
                self.initializeFilledImageView()
                //self.messyArrayViewModel.updateCurrentCommandIndex()
            }
       }
        self.messyArrayViewModel.showFingerClosure = {
             DispatchQueue.main.async {
                self.selectedIndex = -1
                self.updateImageListWithShowFinger()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.resetImageList()
                }
             }
        }
        self.messyArrayViewModel.showTapFingerAnimationClosure = {
             DispatchQueue.main.async {
                self.updateImageListWithShowTapFingerAnimation()
                let deadlineTime = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.messyArrayViewModel.calculateChildAction(state: false, touch: self.isTouch)
                    self.messyArrayViewModel.updateCurrentCommandIndex()
                }
             }
        }
        
        self.messyArrayViewModel.blinkImageClosure = { questionInfo in
            
            DispatchQueue.main.async {
                self.updateImageListWithBlinkImageAnimation()
               let deadlineTime = DispatchTime.now() + .seconds(3)
               DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                   self.messyArrayViewModel.calculateChildAction(state: false, touch: self.isTouch)
                   self.messyArrayViewModel.updateCommandIndex()
               }
            }
        }

    }
    
    private func blinkImage(count:Int,imageView:UIImageView) {
        if count == 0 {
            for (index,element) in self.imageList.enumerated() {
                var model:AnimationImageModel = AnimationImageModel()
                model = element
                model.isBlink = false
                self.imageList.remove(at: index)
                self.imageList.insert(model, at: index)
            }
            return
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, animations: {
                    imageView.alpha = 0.2
                }) { [weak self] finished in
                    if let this = self {
                    imageView.alpha = 1
                        this.blinkImage(count: count - 1,imageView:imageView)
                    }
                }
        }
    }
       
    private func updateImageListWithShowFinger() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isShowFinger = true
            } else {
                scModel.isShowFinger = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func updateImageListWithBlinkImageAnimation() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isBlink = true
            } else {
                scModel.isBlink = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }

    private func updateImageListWithShowTapFingerAnimation() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isShowTapFingerAnimation = true
                scModel.isShowFinger = true
            } else {
                scModel.isShowTapFingerAnimation = false
                scModel.isShowFinger = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func resetImageList() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            scModel.isShowFinger = false
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = messyArrayViewModel.playerController {
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
        messyArrayViewModel.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.messyArrayViewModel.stopVideo()
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
        if let info = self.messyArrayViewModel.getCurrentCommandInfo(),let option = info.option {
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

extension LearningMessyArrayViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


extension LearningMessyArrayViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
            self.messyArrayViewModel.updateCurrentCommandIndex()
        }
    }
}
