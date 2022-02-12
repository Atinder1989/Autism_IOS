//
//  AssessmentPuzzleViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/02.
//  emptyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import MobileCoreServices
import FLAnimatedImage

class AssessmentPuzzleViewController: UIViewController, UIDragInteractionDelegate {
    
    private let puzzleViewModel = AssessmentPuzzleViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var questionState: QuestionState = .inProgress
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var puzzleQuestionInfo: PuzzleQuestionInfo!
    private var initialFrame: CGRect?
    private var skipQuestion = false
    private var incorrectDragDropCount = 0

    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var filledImageView1: PuzzleCustomImageView!
    @IBOutlet weak var filledImageView2: PuzzleCustomImageView!
    @IBOutlet weak var filledImageView3: PuzzleCustomImageView!
    @IBOutlet weak var filledImageView4: PuzzleCustomImageView!
    @IBOutlet weak var filledImageView5: PuzzleCustomImageView!

    @IBOutlet weak var emptyImageView1: PuzzleCustomImageView!
    @IBOutlet weak var emptyImageView2: PuzzleCustomImageView!
    @IBOutlet weak var emptyImageView3: PuzzleCustomImageView!
    @IBOutlet weak var emptyImageView4: PuzzleCustomImageView!
    @IBOutlet weak var emptyImageView5: PuzzleCustomImageView!
    @IBOutlet weak var emptyBgView: UIView!
    @IBOutlet weak var emptyBgImageView: UIImageView!
    
    var selectedPuzzle: PuzzleCustomImageView!
    private var touchOnEmptyScreenCount = 0

    var isPan:Bool = true
    
    private var apiDataState: APIDataState = .notCall
    
    private var isUserInteraction = false {
          didSet {
              self.view.isUserInteractionEnabled = isUserInteraction
          }
    }
    private var noOfImagesToDownload = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.customSetting()
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
extension AssessmentPuzzleViewController {
    func setPuzzleQuestionInfo(info:PuzzleQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.puzzleQuestionInfo = info
        self.delegate = delegate
    }
}

//MARK:- Private Methods
extension AssessmentPuzzleViewController {
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

        if trailPromptTimeForUser == puzzleQuestionInfo.trial_time && self.timeTakenToSolve < puzzleQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.puzzleQuestionInfo.completion_time {
            self.moveToNextQuestion()
           
        }
    }
    
    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    }
    
    private func customSetting() {
            isUserInteraction = false
            SpeechManager.shared.setDelegate(delegate: self)
          //  emptyBgView.transform = CGAffineTransform(rotationAngle: -.pi / 30.0)
        if self.puzzleQuestionInfo.frame_image.count > 0 {
            self.noOfImagesToDownload = 1 + (self.puzzleQuestionInfo.block.count * 2)
        }
        
        ImageDownloader.sharedInstance.downloadImage(urlString:  self.puzzleQuestionInfo.frame_image, imageView: emptyBgImageView, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        
          //  self.emptyBgImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.puzzleQuestionInfo.frame_image)
        
         //   self.screenTitle.text = self.puzzleQuestionInfo.question_title
            self.initializeEmptyImageView()
            self.initializeFilledImageView()
            self.addPanGesture()
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func listenModelClosures() {
        self.puzzleViewModel.dataClosure = {
            DispatchQueue.main.async {
                if let res = self.puzzleViewModel.accessmentSubmitResponseVO {
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
    
    private func initializeEmptyImageView() {
        for model in self.puzzleQuestionInfo.block {
            for subview in self.view.subviews {
                if let emptyImageView = subview as? PuzzleCustomImageView {
                    if emptyImageView.tag == 1000 {
                        if emptyImageView.ddModel == nil {
                            emptyImageView.ddModel = model
                            if(model.is_hidden == true) {
                                emptyImageView.isHidden = true
                            } else {
                                emptyImageView.isHidden = false
                            }
                            ImageDownloader.sharedInstance.downloadImage(urlString:  model.empty_image, imageView: emptyImageView, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
                                                         
                            break
                        }
                    }
                }
            }
        }
    }
    
    private func initializeFilledImageView() {
        for model in self.puzzleQuestionInfo.block {
            for subview in self.view.subviews {
                if let filledImageView = subview as? PuzzleCustomImageView {
                    if filledImageView.tag == 10000 {
                        if filledImageView.ddModel == nil {
                           filledImageView.ddModel = model
                            ImageDownloader.sharedInstance.downloadImage(urlString:  model.image, imageView: filledImageView, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
                            
                      //     filledImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image, placeholderImage: "")
                           break
                        }
                    }
                }
            }
        }
    }

    func reDownloadImages()
    {
        if(emptyImageView1.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  emptyImageView1.ddModel!.empty_image, imageView: emptyImageView1, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(emptyImageView2.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  emptyImageView2.ddModel!.empty_image, imageView: emptyImageView2, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(emptyImageView3.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  emptyImageView3.ddModel!.empty_image, imageView: emptyImageView3, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(emptyImageView4.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  emptyImageView4.ddModel!.empty_image, imageView: emptyImageView4, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(emptyImageView5.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  emptyImageView5.ddModel!.empty_image, imageView: emptyImageView5, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }

        if(filledImageView1.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  filledImageView1.ddModel!.image, imageView: filledImageView1, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(filledImageView2.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  filledImageView2.ddModel!.image, imageView: filledImageView2, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(filledImageView3.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  filledImageView3.ddModel!.image, imageView: filledImageView3, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(filledImageView4.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  filledImageView4.ddModel!.image, imageView: filledImageView4, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
        }
        if(filledImageView5.ddModel != nil) {
        ImageDownloader.sharedInstance.downloadImage(urlString:  filledImageView5.ddModel!.image, imageView: filledImageView5, callbackAfterNoofImages: self.noOfImagesToDownload, delegate: self)
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

            if self.initialFrame == nil && selectedPuzzle == nil {
                self.selectedPuzzle = (gestureRecognizer.view as? PuzzleCustomImageView)!
                self.initialFrame = self.selectedPuzzle.frame

                let translation = gestureRecognizer.translation(in: self.view)
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            break
        case .changed:
            
            let currentFilledPuzzle:PuzzleCustomImageView = (gestureRecognizer.view as? PuzzleCustomImageView)!
            
            if(selectedPuzzle != currentFilledPuzzle) {
                return
            }
            
            if self.initialFrame == nil && selectedPuzzle == nil {
                return
            }
            let translation = gestureRecognizer.translation(in: self.view)
            self.selectedPuzzle.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
        break
        case .ended:
            print("Ended")
            
            if self.initialFrame == nil && selectedPuzzle == nil {
                return
            }
            
            let currentFilledImageView = gestureRecognizer.view as! PuzzleCustomImageView
            
            if(selectedPuzzle != currentFilledImageView) {
                return
            }
            
            let dropLocation = gestureRecognizer.location(in: view)
            for subview in self.view.subviews {
                if let emptyImageView = subview as? PuzzleCustomImageView {
                    if emptyImageView.tag == 1000 && currentFilledImageView.ddModel?.id == emptyImageView.ddModel?.id {
                                if !emptyImageView.frame.contains(dropLocation) {
                                    self.handleInvalidDropLocation(currentImageView: currentFilledImageView)
                                     break
                                } else {
                                    if(emptyImageView.ddModel?.is_hidden == true) {
                                        self.handleInvalidDropLocation(currentImageView: currentFilledImageView)
                                    } else {
                                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: emptyImageView)
                                    }
                                    break
                                }
                        }
                }
            }
            break
        default:
            break
        }
    }

    
    
    //MARK:- UIDragInteraction delegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let currentFilledImageView:PuzzleCustomImageView = (interaction.view as? PuzzleCustomImageView)!
        guard let image = currentFilledImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
        
        let dropLocation = session.location(in: self.view)
        
        let currentFilledImageView:PuzzleCustomImageView = (interaction.view as? PuzzleCustomImageView)!
         
            for subview in self.view.subviews {
                if let emptyImageView = subview as? PuzzleCustomImageView {
                    if emptyImageView.tag == 1000 && currentFilledImageView.ddModel?.id == emptyImageView.ddModel?.id {
                        if !emptyImageView.frame.contains(dropLocation) {
                            self.handleInvalidDropLocation(currentImageView: currentFilledImageView)
                            break
                        } else {
                            if(emptyImageView.ddModel?.is_hidden == true) {
                                self.handleInvalidDropLocation(currentImageView: currentFilledImageView)
                            } else {
                                self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: emptyImageView)
                            }
                            break
                        }
                    }
                }
            }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        let currentFilledImageView:PuzzleCustomImageView = (interaction.view as? PuzzleCustomImageView)!

        let previewParameters = UIDragPreviewParameters()
        previewParameters.backgroundColor = UIColor.clear
        return UITargetedDragPreview(view: currentFilledImageView,
                                     parameters: previewParameters)
    }
    
    private func handleInvalidDropLocation(currentImageView:PuzzleCustomImageView){
        DispatchQueue.main.async {
            
            if let frame = self.initialFrame {
                self.selectedPuzzle.frame = frame
                self.initialFrame = nil
                self.selectedPuzzle = nil
            }
            self.incorrectDragDropCount += 1
             SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
    private func handleValidDropLocation(filledImageView:PuzzleCustomImageView,emptyImageView:PuzzleCustomImageView){
           DispatchQueue.main.async {
            
            if let frame = self.initialFrame {
                self.selectedPuzzle.frame = frame
                self.initialFrame = nil
                self.selectedPuzzle = nil
            }
            
            
            emptyImageView.image = filledImageView.image
            filledImageView.image = nil
            
            self.success_count += 1
            var numberOfAction:Int = 0
            for b in self.puzzleQuestionInfo.block {
                if(b.is_hidden != true) {
                    numberOfAction = numberOfAction+1
                }
            }
                                   //if self.success_count < Int(self.puzzleQuestionInfo.image_count)! {
            if(self.success_count < numberOfAction) {
                                 
            } else {
                self.questionState = .submit
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.puzzleQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
            
        }
    }

}

// MARK: Speech Manager Delegate Methods
extension AssessmentPuzzleViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob  {
                self.avatarImageView.animatedImage =  getIdleGif()
            }
        } else {
                self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
           
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            
            var numberOfAction:Int = 0
            for b in self.puzzleQuestionInfo.block {
                if(b.is_hidden != true) {
                    numberOfAction = numberOfAction+1
                }
            }
            
            if(self.success_count == numberOfAction) {
                self.success_count = 100
            } else {
                let perPer = 100/numberOfAction
                self.success_count = self.success_count*perPer
            }
            self.puzzleViewModel.submitUserAnswer(successCount: self.success_count, puzzleCount: Int(self.puzzleQuestionInfo.image_count)!, info: self.puzzleQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, incorrectDragDropCount: self.incorrectDragDropCount )
            break
        default:
            self.isUserInteraction = true
            self.avatarImageView.animatedImage =  getIdleGif()
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
                   switch type {
                   case .hurrayGoodJob:
                       self.avatarImageView.animatedImage =  getHurrayGif()
                       return
                   case .excellentWork:
                        self.avatarImageView.animatedImage =  getExcellentGif()
                    return
                   default:
                       break
                   }
        }
        self.avatarImageView.animatedImage =  getTalkingGif()
     }
}


extension AssessmentPuzzleViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
        SpeechManager.shared.speak(message:self.puzzleQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        self.screenTitle.text = self.puzzleQuestionInfo.question_title
    }
}

extension AssessmentPuzzleViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        print("self.apiDataState = ", self.apiDataState)
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall || self.apiDataState == .dataFetched) {
                self.reDownloadImages()
            } else {
                
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentPuzzleViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
