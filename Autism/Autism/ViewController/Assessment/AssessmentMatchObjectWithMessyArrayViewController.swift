//
//  AssessmentMatchObjectWithMessyArrayViewController.swift
//  Autism
//
//  Created by Dilip Technology on 24/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentMatchObjectWithMessyArrayViewController: UIViewController {
    
    private var matchingObjectInfo: MatchingObjectInfo!
    private let matchingObjectViewModel = AssessmentMatchingObjectViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
        
    @IBOutlet weak var labelTitle: UILabel!
    
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
    
    var selectedObject:ImageViewWithID!
    var currectObject:ImageViewWithID!
    
    private var initialFrame: CGRect?
    
    private var answerIndex = -1
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
    
    var downloaded10Images:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.customSetting()
        self.listenModelClosures()
                
        answerIndex = Int(self.matchingObjectInfo.correct_answer)!-1
        
        let diff:CGFloat = 60
        if(answerIndex == 0) {
            imageViewRight.center = CGPoint(x: diff+imageView1.center.x, y: diff+imageView1.center.y)
            currectObject = imageView1
        } else if(answerIndex == 1) {
            imageViewRight.center = CGPoint(x: diff+imageView2.center.x, y: diff+imageView2.center.y)
            currectObject = imageView2
        } else if(answerIndex == 2) {
            imageViewRight.center = CGPoint(x: diff+imageView3.center.x, y: diff+imageView3.center.y)
            currectObject = imageView3
        } else if(answerIndex == 3) {
            imageViewRight.center = CGPoint(x: diff+imageView4.center.x, y: diff+imageView4.center.y)
            currectObject = imageView4
        } else if(answerIndex == 4) {
            imageViewRight.center = CGPoint(x: diff+imageView5.center.x, y: diff+imageView5.center.y)
            currectObject = imageView5
        } else if(answerIndex == 5) {
            imageViewRight.center = CGPoint(x: diff+imageView6.center.x, y: diff+imageView6.center.y)
            currectObject = imageView6
        } else if(answerIndex == 6) {
            imageViewRight.center = CGPoint(x: diff+imageView7.center.x, y: diff+imageView7.center.y)
            currectObject = imageView7
        } else if(answerIndex == 7) {
            imageViewRight.center = CGPoint(x: diff+imageView8.center.x, y: diff+imageView8.center.y)
            currectObject = imageView8
        } else if(answerIndex == 8) {
            imageViewRight.center = CGPoint(x: diff+imageView9.center.x, y: diff+imageView9.center.y)
            currectObject = imageView9
        } else if(answerIndex == 9) {
            imageViewRight.center = CGPoint(x: diff+imageView10.center.x, y: diff+imageView10.center.y)
            currectObject = imageView10
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
        
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
        if let touch = touches.first {
                let position = touch.location(in: view)
                print(position)
            if(imageViewTouched != nil) {
                if(self.imageViewTouched!.frame.contains(position)) {

                    let iMdl = self.matchingObjectInfo.image_with_text[answerIndex]
                    
                    if(self.imageViewTouched?.iModel?.id == iMdl.id) {
                        self.success_count = 100
                        self.questionState = .submit
                        imageViewRight.isHidden = false
                        imageViewCroos.isHidden = true
                        SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    } else {
                        self.success_count = 0
                        self.questionState = .submit
                        let diff:CGFloat = 60
                        imageViewRight.isHidden = false
                        imageViewCroos.isHidden = false
                        imageViewCroos.center = CGPoint(x: diff+imageViewTouched!.center.x, y: diff+imageViewTouched!.center.y)
//                        Animations.shake(on: imageViewTouched!)
                        let speechText = SpeechMessage.rectifyAnswer.getMessage()+iMdl.name
                        self.animateTheRightImage(speechText)
                    }
                }
            }
        }
    }
    
    @objc func animateTheRightImage(_ speechText:String)
    {
        DispatchQueue.main.async {
            SpeechManager.shared.speak(message: speechText, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: {
                   // HERE
                self.currectObject!.transform = CGAffineTransform.identity.scaledBy(x: 2.5, y: 2.5) // Scale your image
             }) { (finished) in
                 UIView.animate(withDuration: 1, animations: {
                    
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: {
                        self.currectObject!.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                     }) { (finished) in
                        self.imageViewTouched = nil
                    }
               })
            }
        }
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

extension AssessmentMatchObjectWithMessyArrayViewController {
    func setMatchingObjectInfo(info:MatchingObjectInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
}

// MARK: - UIDragInteractionDelegate
extension AssessmentMatchObjectWithMessyArrayViewController {
    
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

        if trailPromptTimeForUser == matchingObjectInfo.trial_time && self.timeTakenToSolve < matchingObjectInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.matchingObjectInfo.completion_time {
            self.moveToNextQuestion()
        }
    }
    
    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    
    }
    
    private func customSetting() {
        self.isUserInteraction = false
        
        labelTitle.text = matchingObjectInfo.question_title
        imageViewBG.alpha = 0.5
        imageViewBG.backgroundColor = .clear
        imageViewBG.isHidden = false
//        self.imageViewBG.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.bg_image)
//        self.imageViewBG.iModel = matchingObjectInfo
        
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
        
        if(self.matchingObjectInfo.images.count > 0) {
            imageView1.iModel = self.matchingObjectInfo.images[0]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.images[0].image, imageView: imageView1, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }

        if(self.matchingObjectInfo.images.count > 1) {
            imageView2.iModel = self.matchingObjectInfo.images[1]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[1].image, imageView: imageView2, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        
        
        if(self.matchingObjectInfo.images.count > 2) {
            imageView3.iModel = self.matchingObjectInfo.images[2]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[2].image, imageView: imageView3, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        if(self.matchingObjectInfo.images.count > 3) {
            imageView4.iModel = self.matchingObjectInfo.images[3]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.images[3].image, imageView: imageView4, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        if(self.matchingObjectInfo.images.count > 4) {
            imageView5.iModel = self.matchingObjectInfo.images[4]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[4].image, imageView: imageView5, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        if(self.matchingObjectInfo.images.count > 5) {
            imageView6.iModel = self.matchingObjectInfo.images[5]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[5].image, imageView: imageView6, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        if(self.matchingObjectInfo.images.count > 6) {
            imageView7.iModel = self.matchingObjectInfo.images[6]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[6].image, imageView: imageView7, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        if(self.matchingObjectInfo.images.count > 7) {
            imageView8.iModel = self.matchingObjectInfo.images[7]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[7].image, imageView: imageView8, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        if(self.matchingObjectInfo.images.count > 8) {
            imageView9.iModel = self.matchingObjectInfo.images[8]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[8].image, imageView: imageView9, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        if(self.matchingObjectInfo.images.count > 9) {
            imageView10.iModel = self.matchingObjectInfo.images[9]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.matchingObjectInfo.images[9].image, imageView: imageView10, callbackAfterNoofImages: self.matchingObjectInfo.images.count, delegate: self)
        }
        
        self.addPanGesture()
    }

    private func addPanGesture() {
        
        let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView1.addGestureRecognizer(gestureRecognizer1)
        
        let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView2.addGestureRecognizer(gestureRecognizer2)
        
        let gestureRecognizer3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView3.addGestureRecognizer(gestureRecognizer3)
        
        let gestureRecognizer4 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView4.addGestureRecognizer(gestureRecognizer4)
        
        let gestureRecognizer5 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView5.addGestureRecognizer(gestureRecognizer5)
        
        let gestureRecognizer6 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView6.addGestureRecognizer(gestureRecognizer6)
        
        let gestureRecognizer7 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView7.addGestureRecognizer(gestureRecognizer7)
        
        let gestureRecognizer8 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView8.addGestureRecognizer(gestureRecognizer8)
        
        let gestureRecognizer9 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView9.addGestureRecognizer(gestureRecognizer9)
        
        let gestureRecognizer10 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageView10.addGestureRecognizer(gestureRecognizer10)
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
            
            if(self.matchingObjectInfo.correct_answer == "1") {
                if(currentFilledImageView == imageView1) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "2") {
                if(currentFilledImageView == imageView2) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "3") {
                if(currentFilledImageView == imageView3) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "4") {
                if(currentFilledImageView == imageView4) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "5") {
                if(currentFilledImageView == imageView5) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "6") {
                if(currentFilledImageView == imageView6) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "7") {
                if(currentFilledImageView == imageView7) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "8") {
                if(currentFilledImageView == imageView8) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "9") {
                if(currentFilledImageView == imageView9) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                }
            } else if(self.matchingObjectInfo.correct_answer == "10") {
                if(currentFilledImageView == imageView10) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
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
            filledImageView.image = nil
            filledImageView.isHidden = true
            
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            
            self.success_count = 100
            self.questionState = .submit
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.matchingObjectInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}

extension AssessmentMatchObjectWithMessyArrayViewController {
    func setSortQuestionInfo(info:MatchingObjectInfo,delegate:AssessmentSubmitDelegate) {
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentMatchObjectWithMessyArrayViewController: SpeechManagerDelegate {
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


extension AssessmentMatchObjectWithMessyArrayViewController: NetworkRetryViewDelegate {
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


extension AssessmentMatchObjectWithMessyArrayViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if(downloaded10Images == false) {
            downloaded10Images = true
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.matchingObjectInfo.bg_image, imageView: imageViewBG, callbackAfterNoofImages: 1, delegate: self)

        } else {
            self.apiDataState = .imageDownloaded
            
            SpeechManager.shared.setDelegate(delegate: self)
            SpeechManager.shared.speak(message:  matchingObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}

extension AssessmentMatchObjectWithMessyArrayViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
