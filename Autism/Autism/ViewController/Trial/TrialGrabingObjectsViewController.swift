//
//  TrialGrabingObjectsViewController.swift
//  Autism
//
//  Created by Dilip Technology on 25/06/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import Foundation
import AVFoundation
import FLAnimatedImage

class TrialGrabingObjectsViewController: UIViewController {
    
    private weak var delegate: TrialSubmitDelegate?
    
    private let grabingObjectViewModel: TrialGrabingViewModel = TrialGrabingViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!

    private var isTouch = false
    private var isImagesDownloaded = false
    private var isChildAction = false
    private var videoItem: VideoItem?
//    private var isChildActionCompleted = false {
//        didSet {
//            if isChildActionCompleted {
//                DispatchQueue.main.async {
//                    self.grabingObjectViewModel.calculateChildAction(state: self.isChildActionCompleted)
//
//                }
//            }
//        }
//    }
    private var dragImageCount = 0
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0
    private var bufferLoaderTimer: Timer?
    private var initialFrame: CGRect?
    private var selectedObject:FillContainerImageView!
    var objectImagesCount:Int = 0
    private var demoCount = 0

    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bufferLoaderView: UIView!
    @IBOutlet weak var bucketView: BucketView!
    @IBOutlet weak var filledImageView1: FillContainerImageView!
    @IBOutlet weak var filledImageView2: FillContainerImageView!
    @IBOutlet weak var filledImageView3: FillContainerImageView!
    @IBOutlet weak var filledImageView4: FillContainerImageView!
    @IBOutlet weak var filledImageView5: FillContainerImageView!
    
//    @IBOutlet weak var imgH1: FillContainerImageView!
//    @IBOutlet weak var imgH2: FillContainerImageView!
//    @IBOutlet weak var imgH3: FillContainerImageView!
//    @IBOutlet weak var imgH4: FillContainerImageView!
//    @IBOutlet weak var imgH5: FillContainerImageView!
    
    @IBOutlet weak var handImageview: UIImageView!

    @IBOutlet weak var avatarBottomImageView: FLAnimatedImageView!

    var mazeInfo:MazesInfo?
    
    private var apiDataState: APIDataState = .notCall
    var isFromLearning:Bool = false
    private var completeRate = 0

    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0
    private var timeTakenToSolve = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addPanGesture()
        self.customSetting()
        self.initializeFilledImageView()
        self.listenModelClosures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
//        self.grabingObjectViewModel.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        if !skipQuestion {
//            self.imageView.layer.removeAllAnimations()
            self.skipQuestion = true
            self.moveToNextQuestion()
        }
        //self.moveToNextCommand()
    }

    @IBAction func exitAssessmentClicked(_ sender: Any) {
//        self.grabingObjectViewModel.pausePlayer()
//        self.grabingObjectViewModel.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
//            self.imageView.layer.removeAllAnimations()
            self.skipQuestion = true
            self.moveToNextQuestion()
        }
    }
    private func moveToNextQuestion() {
          self.stopTimer()
          self.questionState = .submit
          self.completeRate = 0
          SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
}

extension TrialGrabingObjectsViewController {
    func setQuestionInfo(info:MazesInfo,delegate:TrialSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.mazeInfo = info
        self.delegate = delegate
        
//        self.initializeFilledImageView()
    }
    
    func setQuestionInfo(info:MazesInfo) {
        self.apiDataState = .dataFetched
        self.mazeInfo = info
        
//        self.initializeFilledImageView()
    }
}

extension TrialGrabingObjectsViewController {

    private func listenModelClosures() {
        
           self.grabingObjectViewModel.dataClosure = {
              DispatchQueue.main.async {
                    if let res = self.grabingObjectViewModel.trialSubmitResponseVO {
                        if res.success {
                            self.dismiss(animated: true) {
                                if let del = self.delegate {
                                    del.submitQuestionResponse(response: res)
                                }
                            }
                        }
                    }
                }
          }

        self.grabingObjectViewModel.startPracticeClosure = {
                DispatchQueue.main.async {
//                    self.isUserInteraction = true
//                    self.apiDataState = .comandFinished
//                    self.initializeTimer()
                }
            }
        //blink_all_images
        
        self.grabingObjectViewModel.blinkAllImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                self.blink(filledImageView1, count: 3)
                self.blink(filledImageView2, count: 3)
                
                self.blink(filledImageView3, count: 3)
                self.blink(filledImageView4, count: 3)
                
                self.blink(filledImageView5, count: 3)
            }
        }
        
        self.grabingObjectViewModel.blinkImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                self.blink(filledImageView1, count: 3)

//                for i in 0..<self.matchingObjectInfo.image_with_text.count {
//                    let img = self.matchingObjectInfo.image_with_text[i]
//                    if(img.id == questioninfo.value_id) {
//
//                        //Image 1
//                        if(img.name == "Left") {
//                            self.blink(commandImgViewLeft1, count: 3)
//                        } else if(img.name == "Right") {
//                            self.blink(commandImgViewRight1, count: 3)
//                        }
//
//                        //Image 2
//                        if(img.name == "Left") {
//                            self.blink(commandImgViewLeft2, count: 3)
//                        } else if(img.name == "Right") {
//                            self.blink(commandImgViewRight2, count: 3)
//                        }
//
//                        //Image 3
//                        if(img.name == "Left") {
//                            self.blink(commandImgViewLeft3, count: 3)
//                        } else if(img.name == "Right") {
//                            self.blink(commandImgViewRight3, count: 3)
//                        }
//                    }
//                }
             }
        }
                        
        //P3
        //showFingerClosure
        self.grabingObjectViewModel.showFingerOnImage = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                self.showFingerOnImage(questioninfo, count: 3)
             }
        }
               
            
//        self.grabingObjectViewModel.dragTransparentImageClosure = { questionInfo in
//            DispatchQueue.main.async {
//
//                //Image 1
//                if let option = questionInfo.option {
//                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView1.isHidden = false
//                        self.dragAnimationView1.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftTransparentAnimation(duration: duration-2)
//                        }
//                    } else {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView1.isHidden = false
//                        self.dragAnimationView1.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftTransparentAnimation(duration: duration-2)
//                        }
//                    }
//                }
//             }
//        }
                
        
        self.grabingObjectViewModel.showImageClosure = { questionInfo in
            DispatchQueue.main.async {
            }
        }
        
//        self.grabingObjectViewModel.dragImageClosure = { questionInfo in
//            DispatchQueue.main.async {
//                self.dragImageRightToLeft(duration: 1)
//            }
//        }
        
                    
   }
    
    private func blink(_ imageView: UIImageView, count: Int) {
        if count == 0 {
            self.grabingObjectViewModel.updateCurrentCommandIndex()
            return
        }
        DispatchQueue.main.async {

            UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                imageView.alpha = 0.2
            }) { [self] finished in
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    imageView.alpha = 1.0
                }) { [self] finished in
                    blink(imageView, count: count - 1)
                }
            }
        }
    }
    
    private func showFingerOnImage(_ questionInfo:ScriptCommandInfo, count: Int) {
        if count == 0 {
            if(questionInfo.condition.lowercased() == "no") {
          //      self.balloonViewModel.updateCurrentCommandIndex()
            }
            return
        }
        
        DispatchQueue.main.async {
            
            if(questionInfo.value == "first_image") {
                self.handImageview.isHidden = false
                self.handImageview.frame = self.filledImageView1.frame
                self.perform(#selector(self.hideImage(_:)), with: self.handImageview, afterDelay: TimeInterval(count))
            } else if(questionInfo.value == "second_image") {
                self.handImageview.isHidden = false
                self.handImageview.frame = self.filledImageView2.frame
                self.perform(#selector(self.hideImage(_:)), with: self.handImageview, afterDelay: TimeInterval(count))
            } else if(questionInfo.value == "third_image") {
                self.handImageview.isHidden = false
                self.handImageview.frame = self.filledImageView3.frame
                self.perform(#selector(self.hideImage(_:)), with: self.handImageview, afterDelay: TimeInterval(count))
            } else if(questionInfo.value == "fourth_image") {
                self.handImageview.isHidden = false
                self.handImageview.frame = self.filledImageView4.frame
                self.perform(#selector(self.hideImage(_:)), with: self.handImageview, afterDelay: TimeInterval(count))
            } else if(questionInfo.value == "fifth_image") {
                self.handImageview.isHidden = false
                self.handImageview.frame = self.filledImageView5.frame
                self.perform(#selector(self.hideImage(_:)), with: self.handImageview, afterDelay: TimeInterval(count))
            }
        }
    }
    
    @objc func hideImage(_ imgView:UIImageView) {
        imgView.isHidden =  true
    }
}


//MARK:- Private Methods
extension TrialGrabingObjectsViewController {
    
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.grabingObjectViewModel.updateCurrentCommandIndex()
    }
    
    private func setInitialFrame()
    {
        self.filledImageView1.isHidden = true
        self.filledImageView2.isHidden = true
        self.filledImageView3.isHidden = true
        self.filledImageView4.isHidden = true
        self.filledImageView5.isHidden = true
        self.handImageview.isHidden = true
        
        let imageViewsize = 140
        let yAxis:CGFloat = 100
        let padding = 40
        filledImageView3.frame = CGRect(x:(Int(UIScreen.main.bounds.width)/2) - (imageViewsize/2), y:Int(yAxis), width:imageViewsize, height:imageViewsize)
        
        filledImageView2.frame = CGRect(x:Int(filledImageView3.frame.origin.x) - padding - imageViewsize, y:Int(yAxis), width:imageViewsize, height:imageViewsize)
        
        filledImageView1.frame = CGRect(x:Int(filledImageView2.frame.origin.x) - padding - imageViewsize, y:Int(yAxis), width:imageViewsize, height:imageViewsize)
        
        filledImageView4.frame = CGRect(x: Int(filledImageView3.frame.origin.x) + imageViewsize + padding, y:Int(yAxis), width:imageViewsize, height:imageViewsize)
        
        filledImageView5.frame = CGRect(x: Int(filledImageView4.frame.origin.x) + imageViewsize + padding, y:Int(yAxis), width:imageViewsize, height:imageViewsize)
        
        handImageview.frame = filledImageView1.frame
        
    }
    
    private func customSetting() {
        setInitialFrame()
        demoCount = 0
        objectImagesCount = 0
        dragImageCount = 0
        self.initialFrame = nil
        self.selectedObject = nil
        self.isTouch = false
        self.restartButton.isHidden = true
        self.nextButton.isHidden = false
        self.speechTitle.text = ""
//        isChildActionCompleted = false
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.isChildAction = false
        self.bufferLoaderView.isHidden = true
        isImagesDownloaded = false
        self.bucketView.isHidden = true
      
        self.avatarBottomImageView.animatedImage =  idleGif
        self.avatarBottomImageView.isHidden = false
    }
        
    
    private func startDemo() {
        demoCount = demoCount + 1
        filledImageView1.isHidden = false
        filledImageView2.isHidden = false
        filledImageView3.isHidden = false
        filledImageView4.isHidden = false
        filledImageView5.isHidden = false
        handImageview.isHidden = false

        UIView.animate(withDuration: 6, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                let frame = CGRect(x: this.avatarBottomImageView.frame.origin.x, y: this.avatarBottomImageView.frame.origin.y, width: this.filledImageView1.frame.height, height: this.filledImageView1.frame.height)
                this.filledImageView1.frame = frame
                this.handImageview.frame = frame
            }
                   
                } completion: { [weak self]  (isCompleted) in
                    if let this = self {
                        this.filledImageView1.isHidden = true
                        this.handImageview.isHidden = true
                        this.setInitialFrame()
                        if this.demoCount > 2 {
                            this.grabingObjectViewModel.updateCurrentCommandIndex()
                        } else {
                            this.startDemo()
                        }
                    }
                }
    }
    
    
    private func initializeFilledImageView() {
        
        let intCount = Int(self.mazeInfo?.goal_image ?? "0")
        
        //objectImagesCount = intCount
        
        self.bucketView.isHidden = false
        self.filledImageView1.isHidden = false
        self.filledImageView2.isHidden = false
        self.filledImageView3.isHidden = false
        self.filledImageView4.isHidden = false
        self.filledImageView5.isHidden = false
    
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.mazeInfo!.objejct_image, imageView: filledImageView1, callbackAfterNoofImages: intCount!, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: self.mazeInfo!.objejct_image, imageView: filledImageView2, callbackAfterNoofImages: intCount!, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: self.mazeInfo!.objejct_image, imageView: filledImageView3, callbackAfterNoofImages: intCount!, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: self.mazeInfo!.objejct_image, imageView: filledImageView4, callbackAfterNoofImages: intCount!, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: self.mazeInfo!.objejct_image, imageView: filledImageView5, callbackAfterNoofImages: intCount!, delegate: self)
    }
    
    
    private func addPanGesture() {
         let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
         self.filledImageView1.addGestureRecognizer(gestureRecognizer1)
        
        let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.filledImageView2.addGestureRecognizer(gestureRecognizer2)
        
        let gestureRecognizer3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.filledImageView3.addGestureRecognizer(gestureRecognizer3)
        
        let gestureRecognizer4 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.filledImageView4.addGestureRecognizer(gestureRecognizer4)
        
        let gestureRecognizer5 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.filledImageView5.addGestureRecognizer(gestureRecognizer5)
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
//        if !isChildAction {
//            return
//        }
        
        switch gestureRecognizer.state {
            
            case .began:
            if self.initialFrame == nil && selectedObject == nil {
                self.selectedObject = (gestureRecognizer.view as? FillContainerImageView)!
                self.initialFrame = self.selectedObject.frame

                let translation = gestureRecognizer.translation(in: self.view)
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            break
        case .changed:

            let currentFilledPattern:FillContainerImageView = (gestureRecognizer.view as? FillContainerImageView)!
            
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
            
            let currentFilledImageView:FillContainerImageView = (gestureRecognizer.view as? FillContainerImageView)!
            
            if self.initialFrame == nil && selectedObject == nil {
                return
            }
            
            if(selectedObject != currentFilledImageView) {
                return
            }
            
            let dropLocation = gestureRecognizer.location(in: view)
            var isLocationExist = false
            
            for view in self.view.subviews {
                if let bucket = view as? BucketView {
                    //if let bModel = bucket.iModel {
                        //if bModel.name == currentFilledImageView.iModel?.name {
                                if bucket.frame.contains(dropLocation) {
                                    for imgView in bucket.subviews {
                                        if let cImageView = imgView as? FillContainerImageView {
                                            if cImageView.image == nil {
                                                isLocationExist = true
                                                self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: cImageView)
                                                break
                                            }
                                        }
                                    }
                                }
                        //}
                   // }
                }
            }
            
            if !isLocationExist {
                self.handleInvalidDropLocation(currentImageView:currentFilledImageView)
            }
            
            break
        default:
            break
        }
    }
    
    private func handleValidDropLocation(filledImageView:FillContainerImageView,emptyImageView:FillContainerImageView){
           DispatchQueue.main.async {
            emptyImageView.image = filledImageView.image
            filledImageView.image = nil
            filledImageView.isHidden = true
            
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            
            self.dragImageCount += 1
            print("########### count is == \(self.dragImageCount)")
            if self.dragImageCount < self.objectImagesCount {
                } else {
//                    self.isChildActionCompleted = true
                }
            
        }
    }

    
    
    
    //MARK:- Helper
    private func handleInvalidDropLocation(currentImageView:FillContainerImageView){
        DispatchQueue.main.async {
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
    
    private func addPlayer(urlString:String) {
//        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
//        if let playerController = grabingObjectViewModel.playerController {
//            if let avplayerController = playerController.avPlayerController {
//                self.playerView.isHidden = false
//                self.playerView.addSubview(avplayerController.view)
//                avplayerController.view.frame = self.playerView.frame
//                self.videoItem = VideoItem.init(url: string)
//                self.playVideo()
//                self.thumbnailImage = Utility.getThumbnailImage(urlString: string, time: CMTimeMake(value: 5, timescale: 2))
//            }
//        }
        
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
//        if let item = self.videoItem {
//        grabingObjectViewModel.playVideo(item: item)
//        self.nextButton.isHidden = true
//        self.restartButton.isHidden = true
//        self.thumnailImageView.isHidden = true
//        }
    }
    
    func stopPlayer() {
//        self.grabingObjectViewModel.stopVideo()
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
//        videoFinishWaitingTime += 1
//        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
//        if let info = self.grabingObjectViewModel.getCurrentCommandInfo(),let option = info.option {
//            let time = Int(option.switch_command_time) ?? 0
//            if self.videoFinishWaitingTime >= time  {
//                self.moveToNextCommand()
//            }
//        }
    }
    
    private func stopTimer() {
        if let timer = self.videoFinishTimer {
            print("Video Timer Stop ======== ")
            timer.invalidate()
            self.videoFinishTimer = nil
            self.videoFinishWaitingTime = 0
        }
    }
    
    func submitTrialMatchingAnswer(info:BalloonGameQuestionInfo) {
//        if !Utility.isNetworkAvailable() {
//            if let noNetwork = self.noNetWorkClosure {
//                noNetwork()
//            }
//            return
//        }

        if let user = UserManager.shared.getUserInfo() {

            let parameters: [String : Any] = [
               ServiceParsingKeys.user_id.rawValue :user.id,
               ServiceParsingKeys.question_type.rawValue :info.question_type,
               ServiceParsingKeys.time_taken.rawValue :self.timeTakenToSolve,
               ServiceParsingKeys.complete_rate.rawValue :completeRate,
               ServiceParsingKeys.success_count.rawValue : completeRate,
               ServiceParsingKeys.question_id.rawValue :info.id,
               ServiceParsingKeys.language.rawValue:user.languageCode,
               ServiceParsingKeys.req_no.rawValue:info.req_no,
               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
               ServiceParsingKeys.level.rawValue:info.level,
               ServiceParsingKeys.skip.rawValue:skipQuestion,
                ServiceParsingKeys.program_id.rawValue:info.program_id,

                ServiceParsingKeys.course_type.rawValue:"Trial",
                ServiceParsingKeys.prompt_type.rawValue:info.prompt_type,

                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
            ]
            LearningManager.submitTrialMatchingAnswer(parameters: parameters)
        }
    }
 }

extension TrialGrabingObjectsViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

extension TrialGrabingObjectsViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            SpeechManager.shared.speak(message: self.mazeInfo!.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            self.isImagesDownloaded = true
            //self.grabingObjectViewModel.updateCurrentCommandIndex()
        }
    }
}
extension TrialGrabingObjectsViewController: SpeechManagerDelegate {
    
    func speechDidFinish(speechText:String) {
        self.avatarBottomImageView.isHidden = true
        self.speechTitle.isHidden = true
        
        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob {
                self.avatarBottomImageView.animatedImage =  idleGif
            }
        }
        else {
            self.avatarBottomImageView.animatedImage =  idleGif
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
//            self.stopSpeechAndRecorder()
            if(self.isFromLearning == false) {
                self.grabingObjectViewModel.submitMazesQuestionDetails(info: self.mazeInfo!, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
//                self.submitTrialMatchingAnswer(info: self.balloonGameQuestionInfo)
            }
            break
        default:
            
            if(apiDataState == .dataFetched) {
                if self.mazeInfo!.prompt_detail.count > 0 {
                    apiDataState = .comandRunning
                    self.grabingObjectViewModel.setQuestionInfo(info:self.mazeInfo!)
                } else {
//                    self.startRec()
                    self.grabingObjectViewModel.setQuestionInfo(info:self.mazeInfo!)
                }
            } else if(apiDataState == .comandRunning) {
                DispatchQueue.main.async {
                    self.grabingObjectViewModel.updateCurrentCommandIndex()
                }
            } else if(apiDataState == .comandFinished) {
                //self.startRec()
            }
            
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        //self.isUserInteraction = true
        self.avatarBottomImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .hurrayGoodJob:
                self.avatarBottomImageView.animatedImage =  hurrayGif
                return
            case .wrongAnswer:
                self.avatarBottomImageView.animatedImage =  wrongAnswerGif
                return
            default:
                break
            }
        }
        self.avatarBottomImageView.animatedImage =  talkingGif
    }
}
