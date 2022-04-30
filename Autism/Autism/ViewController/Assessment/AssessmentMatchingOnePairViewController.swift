//
//  AssessmentMatchingOnePairViewController.swift
//  Autism
//
//  Created by Dilip Technology on 14/01/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentMatchingOnePairViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    var shouldShowAvatar = true
    
    private var matchingObjectInfo: MatchingObjectInfo!
    private let matchingObjectViewModel = AssessmentMatchingObjectViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
        
    @IBOutlet weak var labelTitle: UILabel!
//    @IBOutlet weak var imageViewBG:  ImageViewWithID!

    var answerCount:Int = 0
    @IBOutlet weak var imageViewBG1:  ImageViewWithID!
    @IBOutlet weak var imageViewBG2:  ImageViewWithID!
    @IBOutlet weak var imageViewBG3:  ImageViewWithID!

    @IBOutlet weak var imageView1:  ImageViewWithID!
    @IBOutlet weak var imageView2:  ImageViewWithID!
    @IBOutlet weak var imageView3:  ImageViewWithID!

    
    var selectedObject:ImageViewWithID!
    
    private var initialFrame: CGRect?
    
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var initialState = true
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    private var selectedIndex = -1 {
           didSet {
               DispatchQueue.main.async {
//                   self.collectionOption.reloadData()
               }
           }
    }
    
    private var apiDataState: APIDataState = .notCall
    private var touchOnEmptyScreenCount = 0
    private var incorrectDragDropCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.customSetting()
        self.listenModelClosures()

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
extension AssessmentMatchingOnePairViewController {
    func setMatchingObjectInfo(info:MatchingObjectInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
}

// MARK: - UIDragInteractionDelegate
extension AssessmentMatchingOnePairViewController {
    
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

        if self.timeTakenToSolve == self.matchingObjectInfo.completion_time  {
            self.moveToNextQuestion()
        } else if trailPromptTimeForUser == matchingObjectInfo.trial_time && self.timeTakenToSolve < matchingObjectInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
          
    }
    
    func initilizeFramming() {
    
        var wh:CGFloat = 180
        var yRef:CGFloat = 180
        var ySpace:CGFloat = 40
        let xSpace:CGFloat = 60
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            yRef = 100
            wh = 70
            ySpace = 10
        }
        imageViewBG3.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        imageView3.frame = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)
        
        yRef = yRef+wh+ySpace
        
        imageViewBG1.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        imageView1.frame = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)

        yRef = yRef+wh+ySpace
        
        imageViewBG2.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        imageView2.frame = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)

        yRef = yRef+wh+ySpace
    }
    
    private func customSetting() {

        self.initilizeFramming()
        
        self.isUserInteraction = false
        
        labelTitle.text = matchingObjectInfo.question_title
        
        
        
        self.initializeFilledImageView()
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func listenModelClosures() {
       self.matchingObjectViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.matchingObjectViewModel.accessmentSubmitResponseVO {
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
    

    private func initializeFilledImageView() {
        
        if(matchingObjectInfo.block.count == 1) {
            self.imageViewBG1.iModel = self.matchingObjectInfo.block[0]
            self.imageViewBG1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[0].empty_image)
            
            imageView1.iModel = self.matchingObjectInfo.block[0]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.block[0].image, imageView: imageView1, callbackAfterNoofImages: self.matchingObjectInfo.block.count, delegate: self)
            
            
        } else if(matchingObjectInfo.block.count == 2) {
            self.imageViewBG1.iModel = self.matchingObjectInfo.block[0]
            self.imageViewBG1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[0].empty_image)
            self.imageViewBG2.iModel = self.matchingObjectInfo.block[1]
            self.imageViewBG2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[1].empty_image)
            
            imageView1.iModel = self.matchingObjectInfo.block[0]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.block[0].image, imageView: imageView1, callbackAfterNoofImages: self.matchingObjectInfo.block.count, delegate: self)
            
            imageView2.iModel = self.matchingObjectInfo.block[1]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.block[1].image, imageView: imageView2, callbackAfterNoofImages: self.matchingObjectInfo.block.count, delegate: self)
        } else if(matchingObjectInfo.block.count == 3) {
            
            self.imageViewBG1.iModel = self.matchingObjectInfo.block[0]
            self.imageViewBG1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[0].empty_image)
            self.imageViewBG2.iModel = self.matchingObjectInfo.block[1]
            self.imageViewBG2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[1].empty_image)
            self.imageViewBG3.iModel = self.matchingObjectInfo.block[2]
            self.imageViewBG3.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[2].empty_image)
            
            imageView1.iModel = self.matchingObjectInfo.block[0]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.block[0].image, imageView: imageView1, callbackAfterNoofImages: self.matchingObjectInfo.block.count, delegate: self)
            
            imageView2.iModel = self.matchingObjectInfo.block[1]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.block[1].image, imageView: imageView2, callbackAfterNoofImages: self.matchingObjectInfo.block.count, delegate: self)
            
            imageView3.iModel = self.matchingObjectInfo.block[2]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.block[2].image, imageView: imageView3, callbackAfterNoofImages: self.matchingObjectInfo.block.count, delegate: self)
        }
        
        
        self.addPanGesture()
    }

    private func addPanGesture() {
        
        if(matchingObjectInfo.block.count == 1) {
            let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView1.addGestureRecognizer(gestureRecognizer1)
        } else if(matchingObjectInfo.block.count == 2) {
            let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView1.addGestureRecognizer(gestureRecognizer1)
            
            let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView2.addGestureRecognizer(gestureRecognizer2)
        } else if(matchingObjectInfo.block.count == 3) {
            let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView1.addGestureRecognizer(gestureRecognizer1)
            
            let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView2.addGestureRecognizer(gestureRecognizer2)
            
            let gestureRecognizer3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView3.addGestureRecognizer(gestureRecognizer3)
        }
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
            
            case .began:
            if self.initialFrame == nil && selectedObject == nil {
                self.selectedObject = (gestureRecognizer.view as? ImageViewWithID)!
                self.initialFrame = self.selectedObject.frame

                let translation = gestureRecognizer.translation(in: self.view)
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            break
        case .changed:

            let currentFilledPattern:ImageViewWithID = (gestureRecognizer.view as? ImageViewWithID)!
            
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
            
            let currentFilledImageView:ImageViewWithID = (gestureRecognizer.view as? ImageViewWithID)!
            
            if self.initialFrame == nil && selectedObject == nil {
                return
            }
            
            if(selectedObject != currentFilledImageView) {
                return
            }
            
            let dropLocation = gestureRecognizer.location(in: view)
            var isLocationExist = false
            
            if(currentFilledImageView == imageView1) {
                if imageViewBG1.frame.contains(dropLocation) {
                    isLocationExist = true
                    self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG1)
                }
            } else if(currentFilledImageView == imageView2) {
                if imageViewBG2.frame.contains(dropLocation) {
                    isLocationExist = true
                    self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG2)
                }
            } else if(currentFilledImageView == imageView3) {
                if imageViewBG3.frame.contains(dropLocation) {
                    isLocationExist = true
                    self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG3)
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
    
    //MARK:- Helper
    private func handleInvalidDropLocation(currentImageView:ImageViewWithID){
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
    
    private func handleValidDropLocation(filledImageView:ImageViewWithID,emptyImageView:ImageViewWithID){
           DispatchQueue.main.async {
            emptyImageView.image = filledImageView.image
            emptyImageView.alpha = 1
            filledImageView.image = nil
            filledImageView.isHidden = true
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            self.answerCount = self.answerCount+1
            
            if(self.matchingObjectInfo.block.count == 1) {
                self.success_count = 100
                self.questionState = .submit
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.matchingObjectInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else if(self.matchingObjectInfo.block.count == 2 && self.answerCount == 2) {
                self.success_count = 100
                self.questionState = .submit
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.matchingObjectInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else if(self.matchingObjectInfo.block.count == 3 && self.answerCount == 3) {
                self.success_count = 100
                self.questionState = .submit
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.matchingObjectInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
        }
    }
}

extension AssessmentMatchingOnePairViewController {
    func setSortQuestionInfo(info:MatchingObjectInfo,delegate:AssessmentSubmitDelegate) {
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentMatchingOnePairViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.matchingObjectViewModel.submitUserAnswer(successCount: self.success_count, info: self.matchingObjectInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, selectedIndex: self.selectedIndex)
            break
        default:
            self.isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false

    }
}


extension AssessmentMatchingOnePairViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                self.listenModelClosures()
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentMatchingOnePairViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
        
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message:  matchingObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
}

extension AssessmentMatchingOnePairViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
