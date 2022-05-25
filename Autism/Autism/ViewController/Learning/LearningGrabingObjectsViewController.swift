//
//  LearningGrabingObjectsViewController.swift
//  Autism
//
//  Created by Savleen on 07/06/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

class LearningGrabingObjectsViewController: UIViewController {
    private let grabingObjectViewModel: LearningGrabingObjectsViewModel = LearningGrabingObjectsViewModel()
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
                    self.grabingObjectViewModel.calculateChildAction(state: self.isChildActionCompleted)
             
                }
            }
        }
    }
    private var dragImageCount = 0
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0
    private var bufferLoaderTimer: Timer?
    private var initialFrame: CGRect?
    private var selectedObject:FillContainerImageView!
    private var objectImagesCount = 0
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
    @IBOutlet weak var handImageview: UIImageView!

    @IBOutlet weak var avatarBottomImageView: FLAnimatedImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addPanGesture()
        self.customSetting()
        if self.command_array.count == 0 {
            self.grabingObjectViewModel.fetchLearningSolidQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
        self.grabingObjectViewModel.stopAllCommands()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.grabingObjectViewModel.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }

    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.grabingObjectViewModel.pausePlayer()
        self.grabingObjectViewModel.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
}
//MARK:- Public Methods
extension LearningGrabingObjectsViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.grabingObjectViewModel.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)

        }
    }
}

//MARK:- Private Methods
extension LearningGrabingObjectsViewController {
    
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
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        isChildActionCompleted = false
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.isChildAction = false
        self.bufferLoaderView.isHidden = true
        isImagesDownloaded = false
        self.bucketView.isHidden = true
      

        self.avatarBottomImageView.isHidden = true
    }
    
    private func listenModelClosures() {
        self.grabingObjectViewModel.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.grabingObjectViewModel.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.grabingObjectViewModel.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
       self.grabingObjectViewModel.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
               
       self.grabingObjectViewModel.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.grabingObjectViewModel.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.grabingObjectViewModel.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
        
        self.grabingObjectViewModel.showAvatarClosure = { commandInfo in
            DispatchQueue.main.async {
             if let option = commandInfo.option {
                 if option.Position == ScriptCommandOptionType.bottom.rawValue {
                     self.avatarBottomImageView.isHidden = false
                 }
             }
            }
        }
        
        self.grabingObjectViewModel.talkAvatarClosure = { commandInfo in
              DispatchQueue.main.async {
                 if let _ = commandInfo.option {
                    self.avatarBottomImageView.isHidden = false
                    self.avatarBottomImageView.animatedImage =  getTalkingGif()
                 }
              }
        }
        
        self.grabingObjectViewModel.idleAvatarClosure = { commandInfo in
              DispatchQueue.main.async {
                self.avatarBottomImageView.animatedImage =  getIdleGif()
              }
        }
       
       self.grabingObjectViewModel.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.grabingObjectViewModel.dragGameDemoClosure = {[weak self]  in
            if let this = self {
                this.startDemo()
            }
        }
        
        self.grabingObjectViewModel.childActionStateClosure = { state in
             DispatchQueue.main.async {
                //self.view.isUserInteractionEnabled = state
                self.isChildAction = state

             }
        }
       
       self.grabingObjectViewModel.showImagesClosure = {commandInfo in
            DispatchQueue.main.async { [weak self] in
                if let this = self {
                    this.initializeFilledImageView(commandInfo: commandInfo)
                }
            }
       }

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
    
    
    private func initializeFilledImageView(commandInfo:ScriptCommandInfo) {
        objectImagesCount = commandInfo.valueList.count
        self.bucketView.isHidden = false
        self.filledImageView1.isHidden = false
        self.filledImageView2.isHidden = false
        self.filledImageView3.isHidden = false
        self.filledImageView4.isHidden = false
        self.filledImageView5.isHidden = false
    
        ImageDownloader.sharedInstance.downloadImage(urlString:  commandInfo.valueList[0], imageView: filledImageView1, callbackAfterNoofImages: commandInfo.valueList.count, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: commandInfo.valueList[1], imageView: filledImageView2, callbackAfterNoofImages: commandInfo.valueList.count, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: commandInfo.valueList[2], imageView: filledImageView3, callbackAfterNoofImages: commandInfo.valueList.count, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: commandInfo.valueList[3], imageView: filledImageView4, callbackAfterNoofImages: commandInfo.valueList.count, delegate: self)
        
        ImageDownloader.sharedInstance.downloadImage(urlString: commandInfo.valueList[4], imageView: filledImageView5, callbackAfterNoofImages: commandInfo.valueList.count, delegate: self)
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
        if !isChildAction {
            return
        }
        
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
                //    SpeechManager.shared.speak(message:SpeechMessage.excellentWork.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                   // self.questionState = .submit
                  //  SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    self.isChildActionCompleted = true
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
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = grabingObjectViewModel.playerController {
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
        grabingObjectViewModel.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.grabingObjectViewModel.stopVideo()
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
        if let info = self.grabingObjectViewModel.getCurrentCommandInfo(),let option = info.option {
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

extension LearningGrabingObjectsViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

extension LearningGrabingObjectsViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
            self.grabingObjectViewModel.updateCurrentCommandIndex()
        }
    }
}
