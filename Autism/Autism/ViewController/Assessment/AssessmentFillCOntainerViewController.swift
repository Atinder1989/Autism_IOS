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
//    @IBOutlet weak var filledImageView4: FillContainerImageView!
//    @IBOutlet weak var filledImageView5: FillContainerImageView!
//    @IBOutlet weak var filledImageView6: FillContainerImageView!
    
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
        self.customSetting()
        self.listenModelClosures()
        self.initializeFilledImageView()
        if(isPan == true) {
            self.addPanGesture()
        } else {
            self.addDragInteraction()
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
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        if self.fillContainerInfo.bucketList.count >= 1 {
            self.bucketView1.iModel = self.fillContainerInfo.bucketList[0]
            AutismTimer.shared.initializeTimer(delegate: self)
        }
    }
    

    private func initializeFilledImageView() {
        
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.fillContainerInfo.bg_image, imageView: imgViewBucket, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: nil)

        filledImageView1.iModel = self.fillContainerInfo.imagesList[0]
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.fillContainerInfo.imagesList[0].image, imageView: filledImageView1, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
        
        filledImageView2.iModel = self.fillContainerInfo.imagesList[1]
        ImageDownloader.sharedInstance.downloadImage(urlString: self.fillContainerInfo.imagesList[1].image, imageView: filledImageView2, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
               
        
        filledImageView3.iModel = self.fillContainerInfo.imagesList[2]
        ImageDownloader.sharedInstance.downloadImage(urlString: self.fillContainerInfo.imagesList[2].image, imageView: filledImageView3, callbackAfterNoofImages: self.fillContainerInfo.imagesList.count, delegate: self)
        
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
    }

    private func addPanGesture() {
         let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
         self.filledImageView1.addGestureRecognizer(gestureRecognizer1)
        
        let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.filledImageView2.addGestureRecognizer(gestureRecognizer2)
        
        let gestureRecognizer3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.filledImageView3.addGestureRecognizer(gestureRecognizer3)
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
                    if let bModel = bucket.iModel {
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
                if self.success_count < Int(self.fillContainerInfo.imagesList_count)! {
                //    SpeechManager.shared.speak(message:SpeechMessage.excellentWork.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                    self.questionState = .submit
                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.fillContainerInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
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
            
            let imagesCount:Int = self.fillContainerInfo.imagesList.count
            
            if(self.success_count == imagesCount) {
                self.success_count = 100
            } else {
                let perPer = 100/imagesCount
                self.success_count = self.success_count*perPer
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
