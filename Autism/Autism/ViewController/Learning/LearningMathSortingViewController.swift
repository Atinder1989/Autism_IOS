//
//  LearningMathSortingViewController.swift
//  Autism
//
//  Created by Dilip Saket on 02/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class LearningMathSortingViewController: UIViewController {
    
    private let mathSortingViewModel: LearningMathSortingViewModel = LearningMathSortingViewModel()
        
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

    private var foilImageList = [ImageModel]() {
        didSet{
            DispatchQueue.main.async {
//                self.imagesCollectionView.reloadData()
            }
        }
    }
    private var imageList = [ImageModel]() 

    private var isImagesDownloaded = false
    private var isChildAction = false
    private var videoItem: VideoItem?
    private var isChildActionCompleted = false {
        didSet {
            if isChildActionCompleted {
                DispatchQueue.main.async {
                    self.mathSortingViewModel.calculateChildAction(state: self.isChildActionCompleted, touch: self.isTouch)
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

    private var arrImages:[CopyPatternView] = []
    private var initialFrame: CGRect?
    var selectedPattern:CopyPatternView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromViewdidLoad {
            isFromViewdidLoad = false
            
            if self.command_array.count == 0 {
                self.mathSortingViewModel.fetchLearningSolidQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
                if(UIDevice.current.userInterfaceIdiom != .pad) {
                    thumnailImageView.contentMode = .scaleAspectFit
                }
            } else {
                self.mathSortingViewModel.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
            }
        }
    }
    private func customSetting() {
                
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
    
}

//MARK: - Private
extension LearningMathSortingViewController {
    
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.mathSortingViewModel.updateCurrentCommandIndex()
    }
        
    private func listenModelClosures() {
        self.mathSortingViewModel.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.mathSortingViewModel.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.mathSortingViewModel.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
       self.mathSortingViewModel.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
               
       self.mathSortingViewModel.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.mathSortingViewModel.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.mathSortingViewModel.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.mathSortingViewModel.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.mathSortingViewModel.childActionStateClosure = { state in
             DispatchQueue.main.async {
                //self.view.isUserInteractionEnabled = state
                self.isChildAction = state
             }
        }
       
        self.mathSortingViewModel.showImageClosure = { commandInfo in
             DispatchQueue.main.async {
                 if let option = commandInfo.option {
                     //let url = ServiceHelper.baseURL.getMediaBaseUrl() + commandInfo.value
                     var scModel = ImageModel.init()
                     scModel.image = commandInfo.value
                     scModel.id = commandInfo.value_id
                     scModel.index = Int(option.index) ?? 0
                     self.imageList.append(scModel)
                     self.showImage(imageModel: scModel)
                     self.mathSortingViewModel.updateCurrentCommandIndex()
                 }
             }
        }

       self.mathSortingViewModel.showFoilImageClosure = {commandInfo in
           DispatchQueue.main.async { [self] in
                var array : [ImageModel] = []
                if let option = commandInfo.option {
                    let image_count = (Int(option.image_count) ?? 0)
                   
                    for i in 0..<image_count {
                        
                        var scModel = ImageModel.init()
                        scModel.image = commandInfo.value
                        scModel.id = commandInfo.value_id
                        scModel.index = i
                        array.append(scModel)
                    }
                }
               
                self.foilImageList.removeAll()
                self.foilImageList = array
                self.showFoilSpaceForPattern()
                self.mathSortingViewModel.updateCurrentCommandIndex()
            }
       }
    }
    
    private func showFoilSpaceForPattern() {
        let space:CGFloat = 20.0
        var ySpace:CGFloat = 30.0
        var cWH:CGFloat = 150.0
        
        var xRef:CGFloat = 100.0
        var yRef:CGFloat = 200.0
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            xRef = 50.0
            yRef = 90.0
            cWH = 70
            ySpace = 10.0
        }
        
        let totalInPattern:Int = foilImageList.count
        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        
        xRef = (screenWidth-(CGFloat(totalInPattern-1)*space)-(CGFloat(totalInPattern)*cWH))/2.0
        
        let widthHeight:CGFloat = cWH

        xRef = (screenWidth-(CGFloat(totalInPattern-1)*space)-(CGFloat(totalInPattern)*widthHeight))/2.0
        
        for i in 0..<totalInPattern {
            
            let index = i%totalInPattern
            let img = foilImageList[index]
            let strImage = foilImageList[index].image
            let strName = "foil"

            let cpBucketView: CopyPatternBucketView = CopyPatternBucketView()
            cpBucketView.iModel = img
            cpBucketView.tag = i
            cpBucketView.frame = CGRect(x:xRef, y:yRef, width:widthHeight, height:widthHeight)
            cpBucketView.backgroundColor = .white
            cpBucketView.layer.borderWidth = 2.0
            cpBucketView.layer.cornerRadius = widthHeight/2.0
            cpBucketView.clipsToBounds = true
            cpBucketView.layer.borderColor = UIColor.purpleBorderColor.cgColor
            cpBucketView.contentMode = .scaleToFill
            self.view.addSubview(cpBucketView)
            
            if(strName != "foil") {
                let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + strImage
                cpBucketView.setImageWith(urlString: urlString)
            }
            xRef = xRef+widthHeight+space
        }
    }

    private func showImage(imageModel:ImageModel) {
        
        var xRef:CGFloat = 40.90
        var yRef:CGFloat = 580.90
        let space:CGFloat = 20.0
        
        var widthHeight:CGFloat = 150
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            
            widthHeight = 70
            yRef = 250
        }
        
        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        xRef = (screenWidth-(CGFloat(self.foilImageList.count-1)*space)-(CGFloat(self.foilImageList.count)*widthHeight))/2.0

        //self.arrImages.removeAll()

        xRef = (screenWidth-(CGFloat(self.foilImageList.count-1)*space)-(CGFloat(self.foilImageList.count)*widthHeight))/2.0
        
        let idxNo:Int = imageList.count-1
        xRef = xRef+((widthHeight+space)*CGFloat(idxNo))
        
//        for imageModel in imagesToDrag {

            let cpView: CopyPatternView = CopyPatternView()
            cpView.frame = CGRect(x:xRef, y:yRef, width:widthHeight, height:widthHeight)
            cpView.backgroundColor = .white
            cpView.layer.borderWidth = 2.0
            cpView.layer.cornerRadius = widthHeight/2.0
            cpView.layer.borderColor = UIColor.white.cgColor
            cpView.clipsToBounds = true
            cpView.iModel = imageModel
            self.view.addSubview(cpView)
            cpView.isUserInteractionEnabled = true

            let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + imageModel.image
            cpView.setImageWith(urlString: urlString)
            
            xRef = xRef+widthHeight+space

            arrImages.append(cpView)

            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            cpView.addGestureRecognizer(gestureRecognizer)

//        }
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if self.initialFrame == nil && selectedPattern == nil {
                self.selectedPattern = (gestureRecognizer.view as? CopyPatternView)!
                self.initialFrame = self.selectedPattern.frame

                let translation = gestureRecognizer.translation(in: self.view)
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            break
            
        case .changed:
            let currentFilledPattern:CopyPatternView = (gestureRecognizer.view as? CopyPatternView)!
            
            if(selectedPattern != currentFilledPattern) {
                return
            }
            
            if self.initialFrame == nil && selectedPattern == nil {
                return
            }
            let translation = gestureRecognizer.translation(in: self.view)
            self.selectedPattern.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
            
        case .ended:
            print("Ended")
            if self.initialFrame == nil && selectedPattern == nil {
                return
            }
            let currentFilledPattern:CopyPatternView = (gestureRecognizer.view as? CopyPatternView)!
            
            if(selectedPattern != currentFilledPattern) {
                return
            }
            
            let dropLocation = gestureRecognizer.location(in: view)
            var isLocationExist = false

            for view in self.view.subviews {
                if let bucket = view as? CopyPatternBucketView {
                    if bucket.iModel!.name == "foil" {
                        if bucket.frame.contains(dropLocation) {
                            if(bucket.image == nil) {
                                if(currentFilledPattern.iModel!.index == bucket.iModel!.index) {
                                    isLocationExist = true
                                    bucket.image = currentFilledPattern.image
//                                    self.success_count = 100
//                                    self.questionState = .submit
//                                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.copyPatternInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                                } else {
//                                    bucket.image = currentFilledPattern.image
//                                    self.success_count = 0
//                                    self.questionState = .submit
//                                    SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(self.copyPatternInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                                }
                                currentFilledPattern.removeFromSuperview()
                                if let frame = self.initialFrame {
                                    self.selectedPattern.frame = frame
                                    self.initialFrame = nil
                                    self.selectedPattern = nil
                                }
                                return
                            }
                            break
                        }
                    }
                }
            }
            
            if !isLocationExist {
//                self.handleInvalidDropLocation(currentImageView:self.selectedPattern)
            }
            
            break
        default:
            break
        }
    }
        
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = mathSortingViewModel.playerController {
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
        mathSortingViewModel.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.mathSortingViewModel.stopVideo()
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
        if let info = self.mathSortingViewModel.getCurrentCommandInfo(),let option = info.option {
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

extension LearningMathSortingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

extension LearningMathSortingViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
            self.mathSortingViewModel.updateCurrentCommandIndex()
        }
    }
}

