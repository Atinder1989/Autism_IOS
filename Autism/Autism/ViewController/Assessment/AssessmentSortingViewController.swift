//
//  AssessmentSortingViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/13.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import MobileCoreServices

class AssessmentSortingViewController: UIViewController, UIDragInteractionDelegate {
    
    private var draggingModel:ImageModel?
    private var sortObjectInfo: SortObjectInfo!
    private weak var delegate: AssessmentSubmitDelegate?
    private var success_count = 0
    private var timeTakenToSolve = 0

    private let sortingViewModel = AssessmentSortingViewModel()
    private var questionState: QuestionState = .inProgress
    private var initialFrame: CGRect?
    private var skipQuestion = false

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var bucketView1: BucketView!
    @IBOutlet weak var bucketView2: BucketView!
    @IBOutlet weak var bucketView3: BucketView!

    @IBOutlet weak var bucket1: UIImageView!
    @IBOutlet weak var bucket2: UIImageView!
    @IBOutlet weak var bucket3: UIImageView!

    @IBOutlet weak var bucketTitle1: UILabel!
    @IBOutlet weak var bucketTitle2: UILabel!
    @IBOutlet weak var bucketTitle3: UILabel!
    
    @IBOutlet weak var previewImageView1: UIImageView!
    @IBOutlet weak var previewImageView2: UIImageView!
    @IBOutlet weak var previewImageView3: UIImageView!
    
    @IBOutlet weak var filledImageView1: SortingCustomImageView!
    @IBOutlet weak var filledImageView2: SortingCustomImageView!
    @IBOutlet weak var filledImageView3: SortingCustomImageView!
    @IBOutlet weak var filledImageView4: SortingCustomImageView!
    @IBOutlet weak var filledImageView5: SortingCustomImageView!
    @IBOutlet weak var filledImageView6: SortingCustomImageView!
    
    @IBOutlet weak var widthBucket1: NSLayoutConstraint!
    @IBOutlet weak var widthBucket2: NSLayoutConstraint!
    @IBOutlet weak var widthBucket3: NSLayoutConstraint!
    
    var isPan:Bool = true
    var selectedObject:SortingCustomImageView!
    
    private var apiDataState: APIDataState = .notCall
    
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    private var touchOnEmptyScreenCount = 0
    private var incorrectDragDropCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        self.initializeFilledImageView()
        if(isPan == true) {
            self.addPanGesture()
        } else {
            self.addDragInteraction()
        }
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
   @objc func appCameToForeground() {
       print("app enters foreground")
       if let frame = self.initialFrame {
           self.selectedObject.frame = frame
           self.initialFrame = nil
           self.selectedObject = nil
       }
   }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           self.stopQuestionCompletionTimer()
           SpeechManager.shared.setDelegate(delegate: nil)
           UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
        self.skipQuestion = true
        self.moveToNextQuestion()
        }
    }
}

// MARK: Public Methods
extension AssessmentSortingViewController {
    func setSortQuestionInfo(info:SortObjectInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.sortObjectInfo = info
        self.delegate = delegate
    }
}

// MARK: - UIDragInteractionDelegate

extension AssessmentSortingViewController {
    
    private func moveToNextQuestion() {
          self.stopQuestionCompletionTimer()
          self.questionState = .submit
          SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
      }
    
   
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
         self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1

        if trailPromptTimeForUser == sortObjectInfo.trial_time && self.timeTakenToSolve < sortObjectInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.sortObjectInfo.completion_time  {
            self.moveToNextQuestion()
        }
    }
    
    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    }
    
    private func listenModelClosures() {
           self.sortingViewModel.dataClosure = {
               DispatchQueue.main.async {
                   if let res = self.sortingViewModel.accessmentSubmitResponseVO {
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
    }
    
    private func customSetting() {
                
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        if self.sortObjectInfo.bucketList.count == 3 {
            self.bucketView1.iModel = self.sortObjectInfo.bucketList[0]
            self.bucketView2.iModel = self.sortObjectInfo.bucketList[1]
            self.bucketView3.iModel = self.sortObjectInfo.bucketList[2]
            self.bucketTitle1.text = self.sortObjectInfo.bucketList[0].name
            self.bucketTitle2.text = self.sortObjectInfo.bucketList[1].name
            self.bucketTitle3.text = self.sortObjectInfo.bucketList[2].name
            AutismTimer.shared.initializeTimer(delegate: self)
        } else if self.sortObjectInfo.bucketList.count == 2 {
            self.bucketView1.iModel = self.sortObjectInfo.bucketList[0]
            self.bucketView2.isHidden = true
            self.bucketView3.iModel = self.sortObjectInfo.bucketList[1]
            self.bucketTitle1.text = self.sortObjectInfo.bucketList[0].name
            self.bucketTitle2.isHidden = true
            self.bucketTitle3.text = self.sortObjectInfo.bucketList[1].name
            AutismTimer.shared.initializeTimer(delegate: self)
        } else if self.sortObjectInfo.bucketList.count == 1 {
            self.bucketView1.isHidden = true
            self.bucketView3.isHidden = true
            self.bucketTitle1.isHidden = true
            self.bucketTitle3.isHidden = true
            
            self.bucketView2.iModel = self.sortObjectInfo.bucketList[0]
            self.bucketTitle2.text = self.sortObjectInfo.bucketList[0].name
            AutismTimer.shared.initializeTimer(delegate: self)
        }
    }

    private func initializeFilledImageView() {
        
        var wh:CGFloat = 140.0
        var xSpace:CGFloat = 20.0
        
        var xRef:CGFloat = (UIScreen.main.bounds.width-((wh*6)+(xSpace*5)))/2.0
        var yRef:CGFloat = UIScreen.main.bounds.height-wh-20
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
        } else {
        }

        if(UIDevice.current.userInterfaceIdiom != .pad) {
            wh = 70.0
            xSpace = 10.0
            
            xRef = (UIScreen.main.bounds.width-((wh*6)+(xSpace*5)))/2.0
            yRef = UIScreen.main.bounds.height-wh-20

            widthBucket1.constant = 140
            widthBucket2.constant = 140
            widthBucket3.constant = 140
        } else {
            widthBucket1.constant = 280
            widthBucket2.constant = 280
            widthBucket3.constant = 280
        }
        
        self.filledImageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        xRef = xRef+xSpace+wh

        self.filledImageView2.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        xRef = xRef+xSpace+wh

        self.filledImageView3.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        xRef = xRef+xSpace+wh

        self.filledImageView4.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        xRef = xRef+xSpace+wh

        self.filledImageView5.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        xRef = xRef+xSpace+wh

        self.filledImageView6.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        xRef = xRef+xSpace+wh

        let cornerRadius:CGFloat = wh/2.0
        self.filledImageView1.layer.cornerRadius = cornerRadius
        self.filledImageView2.layer.cornerRadius = cornerRadius
        self.filledImageView3.layer.cornerRadius = cornerRadius
        self.filledImageView4.layer.cornerRadius = cornerRadius
        self.filledImageView5.layer.cornerRadius = cornerRadius
        self.filledImageView6.layer.cornerRadius = cornerRadius
        
        self.previewImageView1.alpha = 0.5
        self.previewImageView2.alpha = 0.5
        self.previewImageView3.alpha = 0.5
        
        if(sortObjectInfo.bucketList.count == 3) {
            bucket1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + sortObjectInfo.bg_image)
            bucket2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + sortObjectInfo.bg_image)
            bucket3.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + sortObjectInfo.bg_image)
        } else if(sortObjectInfo.bucketList.count == 2) {
            bucket1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + sortObjectInfo.bg_image)
            bucket3.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + sortObjectInfo.bg_image)
        } else if(sortObjectInfo.bucketList.count == 1) {
            bucket2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + sortObjectInfo.bg_image)
        }
        
        var index = -1
        for list in self.sortObjectInfo.bucketList {
            for model in self.sortObjectInfo.imagesList {
                if model.name == list.name {
                    index = index + 1
                    
                    if(sortObjectInfo.bucketList.count == 3) {
                        if index == 0 {
                             self.previewImageView1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
                        } else if index == 1 {
                            self.previewImageView2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
                        } else if index == 2 {
                            self.previewImageView3.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
                        }
                    } else if(sortObjectInfo.bucketList.count == 2) {
                        if index == 0 {
                             self.previewImageView1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
                        } else if index == 1 {
                            self.previewImageView3.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
                        }
                    } else if(sortObjectInfo.bucketList.count == 3) {
                        if index == 0 {
                            self.previewImageView2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
                        }
                    }
                    break
                }
            }
        }
         
        filledImageView1.iModel = self.sortObjectInfo.imagesList[0]
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.sortObjectInfo.imagesList[0].image, imageView: filledImageView1, callbackAfterNoofImages: self.sortObjectInfo.imagesList.count, delegate: self)
        
        filledImageView2.iModel = self.sortObjectInfo.imagesList[1]
        ImageDownloader.sharedInstance.downloadImage(urlString: self.sortObjectInfo.imagesList[1].image, imageView: filledImageView2, callbackAfterNoofImages: self.sortObjectInfo.imagesList.count, delegate: self)
               
        
        filledImageView3.iModel = self.sortObjectInfo.imagesList[2]
        ImageDownloader.sharedInstance.downloadImage(urlString: self.sortObjectInfo.imagesList[2].image, imageView: filledImageView3, callbackAfterNoofImages: self.sortObjectInfo.imagesList.count, delegate: self)
        
        filledImageView4.iModel = self.sortObjectInfo.imagesList[3]
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.sortObjectInfo.imagesList[3].image, imageView: filledImageView4, callbackAfterNoofImages: self.sortObjectInfo.imagesList.count, delegate: self)

        filledImageView5.iModel = self.sortObjectInfo.imagesList[4]
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.sortObjectInfo.imagesList[4].image, imageView: filledImageView5, callbackAfterNoofImages: self.sortObjectInfo.imagesList.count, delegate: self)
        
        filledImageView6.iModel = self.sortObjectInfo.imagesList[5]
         ImageDownloader.sharedInstance.downloadImage(urlString:  self.sortObjectInfo.imagesList[5].image, imageView: filledImageView6, callbackAfterNoofImages: self.sortObjectInfo.imagesList.count, delegate: self)
    }

    private func addDragInteraction() {
         
        let dragInteraction1 = UIDragInteraction(delegate: self)
        dragInteraction1.isEnabled = true
        filledImageView1.isUserInteractionEnabled = true
        filledImageView1.addInteraction(dragInteraction1)
        
        let dragInteraction2 = UIDragInteraction(delegate: self)
        dragInteraction2.isEnabled = true
        filledImageView2.isUserInteractionEnabled = true
        filledImageView2.addInteraction(dragInteraction2)
        
        let dragInteraction3 = UIDragInteraction(delegate: self)
        dragInteraction3.isEnabled = true
        filledImageView3.isUserInteractionEnabled = true
        filledImageView3.addInteraction(dragInteraction3)
        
        let dragInteraction4 = UIDragInteraction(delegate: self)
        dragInteraction4.isEnabled = true
        filledImageView4.isUserInteractionEnabled = true
        filledImageView4.addInteraction(dragInteraction4)
        
        let dragInteraction5 = UIDragInteraction(delegate: self)
        dragInteraction5.isEnabled = true
        filledImageView5.isUserInteractionEnabled = true
        filledImageView5.addInteraction(dragInteraction5)
        
        let dragInteraction6 = UIDragInteraction(delegate: self)
        dragInteraction6.isEnabled = true
        filledImageView6.isUserInteractionEnabled = true
        filledImageView6.addInteraction(dragInteraction6)
        
        self.SetupDragDelay()
    }
    
    func SetupDragDelay()
    {
        let delayTime = 0.0
        if let longPressRecognizer = filledImageView1.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
            longPressRecognizer.minimumPressDuration = delayTime // your custom value
        }
        if let longPressRecognizer = filledImageView2.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
            longPressRecognizer.minimumPressDuration = delayTime // your custom value
        }
        if let longPressRecognizer = filledImageView3.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
            longPressRecognizer.minimumPressDuration = delayTime // your custom value
        }
        if let longPressRecognizer = filledImageView4.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
            longPressRecognizer.minimumPressDuration = delayTime // your custom value
        }
        if let longPressRecognizer = filledImageView5.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
            longPressRecognizer.minimumPressDuration = delayTime // your custom value
        }
        if let longPressRecognizer = filledImageView6.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
            longPressRecognizer.minimumPressDuration = delayTime // your custom value
        }
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
        
        let gestureRecognizer6 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.filledImageView6.addGestureRecognizer(gestureRecognizer6)
        
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
            
            case .began:
            if self.initialFrame == nil && selectedObject == nil {
                self.selectedObject = (gestureRecognizer.view as? SortingCustomImageView)!
                self.initialFrame = self.selectedObject.frame

                let translation = gestureRecognizer.translation(in: self.view)
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            break
        case .changed:

            let currentFilledPattern:SortingCustomImageView = (gestureRecognizer.view as? SortingCustomImageView)!
            
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
            
            let currentFilledImageView:SortingCustomImageView = (gestureRecognizer.view as? SortingCustomImageView)!
            
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
                    if let bModel = bucket.iModel {
                        if bModel.name == currentFilledImageView.iModel?.name {
                                if bucket.frame.contains(dropLocation) {
                                    for imgView in bucket.subviews {
                                        if let cImageView = imgView as? SortingCustomImageView {
                                                if cImageView.image == nil {
                                                    isLocationExist = true
                                                    self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: cImageView)
                                                                 break
                                                }
                                        }
                                    }
                                }
                        }
                    }
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
    //MARK:- UIDragInteraction delegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let currentFilledImageView:SortingCustomImageView = (interaction.view as? SortingCustomImageView)!
        guard let image = currentFilledImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
        
        let dropLocation = session.location(in: self.view)
        
        let currentFilledImageView:SortingCustomImageView = (interaction.view as? SortingCustomImageView)!
        var isLocationExist = false

        //if(currentFilledImageView != nil) {
         
            for view in self.view.subviews {
                if let bucket = view as? BucketView {
                    if let bModel = bucket.iModel {
                        if bModel.name == currentFilledImageView.iModel?.name {
                                if bucket.frame.contains(dropLocation) {
                                    for imgView in bucket.subviews {
                                        if let cImageView = imgView as? SortingCustomImageView {
                                                if cImageView.image == nil {
                                                    isLocationExist = true
                                                    self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: cImageView)
                                                                 break
                                                }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        if !isLocationExist {
            self.handleInvalidDropLocation(currentImageView:currentFilledImageView)
        } else {
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        let currentFilledImageView:SortingCustomImageView = (interaction.view as? SortingCustomImageView)!

        let previewParameters = UIDragPreviewParameters()
        previewParameters.backgroundColor = UIColor.clear
        return UITargetedDragPreview(view: currentFilledImageView,
                                     parameters: previewParameters)
    }
    
    //MARK:- Helper
    private func handleInvalidDropLocation(currentImageView:SortingCustomImageView){
           DispatchQueue.main.async {
            
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            self.incorrectDragDropCount += 1
                SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
           }
    }
    
    private func handleValidDropLocation(filledImageView:SortingCustomImageView,emptyImageView:SortingCustomImageView){
           DispatchQueue.main.async {
            emptyImageView.image = filledImageView.image
            filledImageView.image = nil
            filledImageView.isHidden = true
            
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            
            self.success_count += 1
                if self.success_count < Int(self.sortObjectInfo.imagesList_count)! {
                //    SpeechManager.shared.speak(message:SpeechMessage.excellentWork.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                    self.questionState = .submit
                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.sortObjectInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            
        }
    }
    
}

// MARK: Speech Manager Delegate Methods
extension AssessmentSortingViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            
            let imagesCount:Int = self.sortObjectInfo.imagesList.count
            
            if(self.success_count == imagesCount) {
                self.success_count = 100
            } else {
                let perPer = 100/imagesCount
                self.success_count = self.success_count*perPer
            }
            
            self.sortingViewModel.submitUserAnswer(successCount: self.success_count,  info: self.sortObjectInfo, timeTaken: self.timeTakenToSolve, skip: true, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, incorrectDragDropCount: self.incorrectDragDropCount)
            break
        default:
            isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
    }
}

extension AssessmentSortingViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
        SpeechManager.shared.speak(message:self.sortObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        self.questionTitle.text = self.sortObjectInfo.question_title
    }
}
extension AssessmentSortingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentSortingViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
