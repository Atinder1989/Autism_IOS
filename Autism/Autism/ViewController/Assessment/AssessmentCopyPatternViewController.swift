//
//  AssessmentCopyPatternViewController.swift
//  Autism
//
//  Created by Dilip Technology on 20/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import MobileCoreServices
import FLAnimatedImage

class AssessmentCopyPatternViewController: UIViewController, UIDragInteractionDelegate {
    
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var arrImages:[CopyPatternView] = []
    private var copyPatternInfo: CopyPatternInfo!
    private let copyPatternInfoViewModel = AssessmentCopyPatternInfoViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    
    var arrPattern:[String] = []
    private var initialFrame: CGRect?
    var isPan:Bool = true
    
    var selectedPattern:CopyPatternView!
    private var touchOnEmptyScreenCount = 0
    private var incorrectDragDropCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        self.initializeFilledPattern()
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
    extension AssessmentCopyPatternViewController {
        func setCopyPatternInfo(info:CopyPatternInfo,delegate:AssessmentSubmitDelegate) {
            self.copyPatternInfo = info
            self.delegate = delegate
        }
    }

    // MARK: - UIDragInteractionDelegate

    extension AssessmentCopyPatternViewController {
       
        @objc private func calculateTimeTaken() {
            
            if !Utility.isNetworkAvailable() {
                return
            }
            
            self.timeTakenToSolve += 1
            trailPromptTimeForUser += 1

            if trailPromptTimeForUser == copyPatternInfo.trial_time && self.timeTakenToSolve < copyPatternInfo.completion_time
            {
                trailPromptTimeForUser = 0
                SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else if self.timeTakenToSolve == self.copyPatternInfo.completion_time  {
                self.moveToNextQuestion()
            }
        }
        
        private func moveToNextQuestion() {
            self.stopQuestionCompletionTimer()
            self.questionState = .submit
            SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
        
        func stopQuestionCompletionTimer() {
            AutismTimer.shared.stopTimer()
        }
        
        private func listenModelClosures() {
               self.copyPatternInfoViewModel.dataClosure = {
                   DispatchQueue.main.async {
                       if let res = self.copyPatternInfoViewModel.accessmentSubmitResponseVO {
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
            self.isUserInteraction = false
            SpeechManager.shared.setDelegate(delegate: self)
            SpeechManager.shared.speak(message:self.copyPatternInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            
            self.labelTitle.text = self.copyPatternInfo.question_title
            
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
            let totalInPattern:Int = self.copyPatternInfo.repeat_count*self.copyPatternInfo.image_count
            let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
            
            xRef = (screenWidth-(CGFloat(totalInPattern-1)*space)-(CGFloat(totalInPattern)*cWH))/2.0
            
            for i in 0..<totalInPattern {
                let index = i%self.copyPatternInfo.image_count
                let strImage = self.copyPatternInfo.images[index].image
                
                let imgViewPattern = UIImageView()
                imgViewPattern.frame =  CGRect(x:xRef, y: yRef, width: cWH, height: cWH)
                imgViewPattern.backgroundColor = .clear
                imgViewPattern.layer.borderWidth = 2.0
                imgViewPattern.layer.cornerRadius = cWH/2.0
                imgViewPattern.layer.borderColor = UIColor.white.cgColor
                imgViewPattern.clipsToBounds = true
                self.view.addSubview(imgViewPattern)
                
                let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + strImage
                imgViewPattern.setImageWith(urlString: urlString)
                
                xRef = xRef+space+cWH
            }
                        
            yRef = yRef+cWH+ySpace
                        
            let widthHeight:CGFloat = cWH

            xRef = (screenWidth-(CGFloat(totalInPattern-1)*space)-(CGFloat(totalInPattern)*widthHeight))/2.0
            
            for i in 0..<totalInPattern {
                
                let index = i%self.copyPatternInfo.image_count
                let img = self.copyPatternInfo.images[index]
                
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

                xRef = xRef+widthHeight+space
            }
            AutismTimer.shared.initializeTimer(delegate: self)
        }
        

        private func initializeFilledPattern() {
            
            var xRef:CGFloat = 40.90
            var yRef:CGFloat = 580.90
            let space:CGFloat = 20.0
            
            var widthHeight:CGFloat = 150
            if(UIDevice.current.userInterfaceIdiom != .pad) {
                
                widthHeight = 70
                yRef = 250
            }
            
            let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
            xRef = (screenWidth-(CGFloat(self.copyPatternInfo.images.count-1)*space)-(CGFloat(self.copyPatternInfo.images.count)*widthHeight))/2.0

            self.arrImages.removeAll()
            for imageModel in self.copyPatternInfo.images {

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

                if(isPan == true) {
                    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
                    cpView.addGestureRecognizer(gestureRecognizer)
                } else {
                    let dragInteraction1 = UIDragInteraction(delegate: self)
                    dragInteraction1.isEnabled = true
                    cpView.isUserInteractionEnabled = true
                    cpView.addInteraction(dragInteraction1)
                    
                    let delayTime = 0.0
                    if let longPressRecognizer = cpView.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
                        longPressRecognizer.minimumPressDuration = delayTime
                    }
                }
            }
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
                        if bucket.iModel!.id == self.selectedPattern.iModel!.id {
                            if bucket.frame.contains(dropLocation) {
                                if(bucket.image == nil) {
                                    isLocationExist = true
                                    self.handleValidDropLocation(filledPatternView: self.selectedPattern, emptyPatternView: bucket)
                                }
                                break
                            }
                        }
                    }
                }
                
                if !isLocationExist {
                    self.handleInvalidDropLocation(currentImageView:self.selectedPattern)
                }
                
                break
            default:
                break
            }
        }
    }

extension AssessmentCopyPatternViewController {

    //MARK:- UIDragInteraction delegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let currentFilledPattern:CopyPatternView = (interaction.view as? CopyPatternView)!
        guard let image = currentFilledPattern.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
        
        let dropLocation = session.location(in: self.view)
        
        let currentFilledPattern:CopyPatternView = (interaction.view as? CopyPatternView)!
        var isLocationExist = false

        for view in self.view.subviews {
            if let bucket = view as? CopyPatternBucketView {
                if bucket.iModel!.id == currentFilledPattern.iModel!.id {
                    if bucket.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledPatternView: currentFilledPattern, emptyPatternView: bucket)
                        break
                    }
                }
            }
        }
        
        if !isLocationExist {
            self.handleInvalidDropLocation(currentImageView:currentFilledPattern)
        }
    }
    
    private func handleInvalidDropLocation(currentImageView:CopyPatternView){
           DispatchQueue.main.async {
                        
            if let frame = self.initialFrame {
                self.selectedPattern.frame = frame
                self.initialFrame = nil
                self.selectedPattern = nil
            }
            self.incorrectDragDropCount += 1
                SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
           }
    }
    
    private func handleValidDropLocation(filledPatternView:CopyPatternView,emptyPatternView:CopyPatternBucketView){
           DispatchQueue.main.async {
           emptyPatternView.image = filledPatternView.image
            
            if let frame = self.initialFrame {
                self.selectedPattern.frame = frame
                self.initialFrame = nil
                self.selectedPattern = nil
            }
            
            let totalInPattern:Int = self.copyPatternInfo.repeat_count*self.copyPatternInfo.images.count
            
           self.success_count += 1
            
            self.arrPattern.append(filledPatternView.iModel!.id)
            
            for view in self.view.subviews{
                
                if(view is CopyPatternView) {
                    let vCP:CopyPatternView = view as! CopyPatternView
                    
                    var rCount:Int = 0
                    for str in self.arrPattern {
                        if(vCP.iModel!.id == str) {
                            rCount = rCount+1
                        }
                    }
                    if(rCount >= self.copyPatternInfo.repeat_count) {
                        view.removeFromSuperview()
                    } else {
                        
                        if let frame = self.initialFrame {
                            filledPatternView.frame = frame
                            self.initialFrame = nil
                        }
                    }
                }
            }
            
           if self.success_count < totalInPattern {
                   //SpeechManager.shared.speak(message: SpeechMessage.excellentWork.getMessage(self.blokDesignInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
               } else {
               
                   self.questionState = .submit
                   SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.copyPatternInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
               }
           }
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentCopyPatternViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob {
                self.avatarImageView.animatedImage =  getIdleGif()
            }
        } else {
            self.avatarImageView.animatedImage =  getIdleGif()
        }
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)

            let totalInPattern:Int = self.copyPatternInfo.repeat_count*self.copyPatternInfo.images.count
            
            if(self.success_count == totalInPattern) {
                self.success_count = 100
            } else {
                let perPer = 100/totalInPattern
                self.success_count = self.success_count*perPer
            }

            self.copyPatternInfoViewModel.submitUserAnswer(successCount: self.success_count,  info: self.copyPatternInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, incorrectDragDropCount: incorrectDragDropCount )
            break
        default:
            self.isUserInteraction = true
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

class CopyPatternView : UIImageView {
    var iModel : ImageModel?
}

class CopyPatternBucketView : UIImageView {
    var iModel : ImageModel?
}

extension AssessmentCopyPatternViewController: NetworkRetryViewDelegate {

    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentCopyPatternViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
