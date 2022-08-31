//
//  AssessmentFillCOntainerViewController.swift
//  Autism
//
//  Created by Dilip Technology on 30/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import MobileCoreServices

class AssessmentFillContainerViewController: UIViewController, UIDragInteractionDelegate {
    
    private var draggingModel:ImageModel?
    private var fillContainerInfo: FillContainerQuestionInfo!
    private weak var delegate: AssessmentSubmitDelegate?
    private var success_count = 0
    private var timeTakenToSolve = 0
    private let fillContainerViewModel = AssessmentFillContainerViewModal()
    private var questionState: QuestionState = .inProgress
    private var initialFrame: CGRect?
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0
    private var incorrectDragDropCount = 0

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var bucketView1: BucketView!
    
    @IBOutlet weak var imgViewBucket: UIImageView!

    @IBOutlet weak var filledImageView1: FillContainerImageView!
    @IBOutlet weak var filledImageView2: FillContainerImageView!
    @IBOutlet weak var filledImageView3: FillContainerImageView!
    @IBOutlet weak var filledImageView4: FillContainerImageView!
    @IBOutlet weak var filledImageView5: FillContainerImageView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var widthHeightBall: NSLayoutConstraint!
            
    var isPan:Bool = true
    var selectedObject:FillContainerImageView!
    
    private var apiDataState: APIDataState = .notCall
    
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        bucketView1.backgroundColor = .red
//        imgViewBucket.backgroundColor = .blue
//
//
//        for view in self.view.subviews {
//            if let bucket = view as? BucketView {
//                for imgView in bucket.subviews {
//                    if let cImageView = imgView as? FillContainerImageView {
//                        if cImageView.image == nil {
//                            cImageView.backgroundColor = .yellow
//                        }
//                    }
//                }
//            }
//        }

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
    
    @IBAction func submitClicked(_ sender: Any) {
        
        if self.success_count == self.fillContainerInfo.correct_object_count {
            self.questionState = .submit
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.fillContainerInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else {
            self.questionState = .submit
            SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(self.fillContainerInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}

// MARK: Public Methods
extension AssessmentFillContainerViewController {
    func setFillContainerQuestionInfo(info:FillContainerQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.fillContainerInfo = info
        self.delegate = delegate
    }
}

// MARK: - UIDragInteractionDelegate

extension AssessmentFillContainerViewController {
    
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

        if trailPromptTimeForUser == fillContainerInfo.trial_time && self.timeTakenToSolve < fillContainerInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.fillContainerInfo.completion_time {
            self.moveToNextQuestion()
        }
    }
    
    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    }
    
    private func listenModelClosures() {
        self.fillContainerViewModel.dataClosure = {
            DispatchQueue.main.async {
                if let res = self.fillContainerViewModel.accessmentSubmitResponseVO {
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
        let type = AssessmentQuestionType.init(rawValue: self.fillContainerInfo!.question_type)
        
        if(type == .fill_container_by_count) {
            self.submitButton.isHidden = false
        } else {
            self.submitButton.isHidden = true
        }
        
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        
        if self.fillContainerInfo.bucketList.count >= 1 {
            self.bucketView1.iModel = self.fillContainerInfo.bucketList[0]
            AutismTimer.shared.initializeTimer(delegate: self)
        }
    }
    

    private func initializeFilledImageView() {
        
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.fillContainerInfo.bg_image, imageView: imgViewBucket, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: nil)

        if(self.fillContainerInfo.imagesList.count > 0) {
            filledImageView1.iModel = self.fillContainerInfo.imagesList[0]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.fillContainerInfo.imagesList[0].image, imageView: filledImageView1, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
        }
        if(self.fillContainerInfo.imagesList.count > 1) {
            filledImageView2.iModel = self.fillContainerInfo.imagesList[1]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.fillContainerInfo.imagesList[1].image, imageView: filledImageView2, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
        }
        if(self.fillContainerInfo.imagesList.count > 2) {
            filledImageView3.iModel = self.fillContainerInfo.imagesList[2]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.fillContainerInfo.imagesList[2].image, imageView: filledImageView3, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
        }
        if(self.fillContainerInfo.imagesList.count > 3) {
            filledImageView4.iModel = self.fillContainerInfo.imagesList[3]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.fillContainerInfo.imagesList[3].image, imageView: filledImageView4, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
        }
        if(self.fillContainerInfo.imagesList.count > 4) {
            filledImageView5.iModel = self.fillContainerInfo.imagesList[4]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.fillContainerInfo.imagesList[4].image, imageView: filledImageView5, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
        }
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
        
        let currentFilledImageView:FillContainerImageView = (interaction.view as? FillContainerImageView)!
        guard let image = currentFilledImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
        
        let dropLocation = session.location(in: self.view)
        
        let currentFilledImageView:FillContainerImageView = (interaction.view as? FillContainerImageView)!
        var isLocationExist = false

        //if(currentFilledImageView != nil) {
         
            for view in self.view.subviews {
                if let bucket = view as? BucketView {
                    if let bModel = bucket.iModel {
                        if bModel.name == currentFilledImageView.iModel?.name {
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
        
        let currentFilledImageView:FillContainerImageView = (interaction.view as? FillContainerImageView)!

        let previewParameters = UIDragPreviewParameters()
        previewParameters.backgroundColor = UIColor.clear
        return UITargetedDragPreview(view: currentFilledImageView,
                                     parameters: previewParameters)
    }
    
    //MARK:- Helper
    private func handleInvalidDropLocation(currentImageView:FillContainerImageView){
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
             
             self.success_count += 1
                           
            let type = AssessmentQuestionType.init(rawValue: self.fillContainerInfo!.question_type)
            if(type == .fill_container_by_count) {
                
            } else {
                if self.success_count < self.fillContainerInfo.imagesList_count {
                } else {
                    self.questionState = .submit
                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.fillContainerInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            }
        }
    }
    
}

// MARK: Speech Manager Delegate Methods
extension AssessmentFillContainerViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            
            let type = AssessmentQuestionType.init(rawValue: self.fillContainerInfo!.question_type)
            if(type == .fill_container_by_count) {
                if(self.success_count == self.fillContainerInfo.correct_object_count) {
                    self.success_count = 100
                } else {
                    self.success_count = 0
                }
            } else {
                let imagesCount:Int = self.fillContainerInfo.imagesList.count
                
                if(self.success_count == imagesCount) {
                    self.success_count = 100
                } else {
                    let perPer = 100/imagesCount
                    self.success_count = self.success_count*perPer
                }
            }
            
            self.fillContainerViewModel.submitUserAnswer(successCount: self.success_count,  info: self.fillContainerInfo, timeTaken: self.timeTakenToSolve, skip: true, touchOnEmptyScreenCount:touchOnEmptyScreenCount,incorrectDragDropCount:incorrectDragDropCount)
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

extension AssessmentFillContainerViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
        SpeechManager.shared.speak(message:self.fillContainerInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        self.questionTitle.text = self.fillContainerInfo.question_title
    }
}
extension AssessmentFillContainerViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
//            if(self.apiDataState == .notCall) {
//                self.listenModelClosures()
//            } else if(self.apiDataState == .dataFetched) {
//                self.initializeFilledImageView()
//            } else {
//
//            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}
class FillContainerImageView : UIImageView {
    var iModel : ImageModel?
}

extension AssessmentFillContainerViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
