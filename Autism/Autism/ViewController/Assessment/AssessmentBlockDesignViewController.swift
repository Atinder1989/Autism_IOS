//
//  AssessmentBlockDesignViewController.swift
//  Autism
//
//  Created by Dilip Technology on 23/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentBlockDesignViewController: UIViewController, UIDragInteractionDelegate {
    @IBOutlet weak var labelTitle: UILabel!

    private var blockDesignInfo: BlockDesignInfo!
    private let blockDesignInfoViewModel = AssessmentBlockDesignViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var skipQuestion = false
    private var answerIndex = -1
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var initialState = true
    private var questionState: QuestionState = .inProgress
    private var initialFrame: CGRect?
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
        self.initializeFilledBlockes()
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

extension AssessmentBlockDesignViewController {
    func setBlockDesignInfo(info:BlockDesignInfo,delegate:AssessmentSubmitDelegate) {
        self.blockDesignInfo = info
        self.delegate = delegate
    }
}

extension AssessmentBlockDesignViewController {
    private func customSetting() {
        self.isUserInteraction = false
        self.labelTitle.text = self.blockDesignInfo.question_title
                    
            let space:CGFloat = -1.0
            let cWH:CGFloat = 100
                
            var xRef:CGFloat = 100.0
            var yRef:CGFloat = 220.0
        
        var matrixOf:CGFloat = 3
        
        if(self.blockDesignInfo.images.count == 4) {
            matrixOf = 2
        } else if(self.blockDesignInfo.images.count == 16) {
            matrixOf = 4
        }
        
        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let screenHalf:CGFloat = screenWidth/2.0
        
        xRef = (screenHalf-(cWH*matrixOf))/2.0
        
        var index:Int = 0
        
        for i in 0..<Int(matrixOf) {
                    
            for j in 0..<Int(matrixOf) {
                                
                let iModel:ImageModel = self.blockDesignInfo.images[index]
                        
                let viewBlock = BlockDesignView()
                viewBlock.iModel = iModel
                viewBlock.frame =  CGRect(x:xRef, y: yRef, width: cWH, height: cWH)
                viewBlock.tag = Int(i*Int(matrixOf))+j
                viewBlock.backgroundColor = .white
                viewBlock.clipsToBounds = true
                self.view.addSubview(viewBlock)

                let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + iModel.image
                viewBlock.setImageWith(urlString: urlString)
                    
                xRef = xRef+space+cWH
                
                index = index+1
            }
            xRef = (screenHalf-(cWH*matrixOf))/2.0
            yRef = yRef+cWH+space
        }
               
        xRef = screenHalf+(screenHalf-(cWH*matrixOf))/2.0
        yRef = 240
              
        index = 0
        for i in 0..<Int(matrixOf) {
                                
            for j in 0..<Int(matrixOf) {
                                            
                let iModel:ImageModel = self.blockDesignInfo.images[index]
                                    
                let viewBlock = BlockDesignBucketView()
                viewBlock.iModel = iModel
                viewBlock.frame =  CGRect(x:xRef, y: yRef, width: cWH, height: cWH)
                viewBlock.tag = Int(i*Int(matrixOf))+j
                viewBlock.backgroundColor = .white
                viewBlock.layer.borderWidth = 1.0
                viewBlock.layer.borderColor = UIColor.black.cgColor
                viewBlock.clipsToBounds = true
                self.view.addSubview(viewBlock)
                                            
                xRef = xRef+space+cWH
                            
                index = index+1
            }
            xRef = screenHalf+(screenHalf-(cWH*matrixOf))/2.0
            yRef = yRef+cWH+space
        }

        
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message:  blockDesignInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        labelTitle.text = blockDesignInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)

    }

    func initializeFilledBlockes()
    {
        let space:CGFloat = 10.0
        
        var  cWH:CGFloat = 100
        
        if(self.blockDesignInfo.images.count == 16) {
            cWH = 60
        }
        var xRef:CGFloat = 100.0
        let yRef:CGFloat = 580.0
                
        
        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        
        xRef = (screenWidth-((CGFloat(self.blockDesignInfo.images.count)*cWH)+(CGFloat(self.blockDesignInfo.images.count-1)*space)))/2.0
                    
            for j in 0..<self.blockDesignInfo.images.count {
                                
                let iModel:ImageModel = self.blockDesignInfo.images[j]
                        
                let viewBlock = BlockDesignView()
                viewBlock.iModel = iModel
                viewBlock.isUserInteractionEnabled = true
                viewBlock.tag = j
                viewBlock.frame =  CGRect(x:xRef, y: yRef, width: cWH, height: cWH)
                viewBlock.backgroundColor = .white
                viewBlock.layer.borderWidth = 1.0
                viewBlock.layer.borderColor = UIColor.black.cgColor
                viewBlock.clipsToBounds = true
                self.view.addSubview(viewBlock)
                
                let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + iModel.image
                viewBlock.setImageWith(urlString: urlString)
                    
                xRef = xRef+space+cWH

                let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
                viewBlock.addGestureRecognizer(gestureRecognizer)
                
//                let dragInteraction1 = UIDragInteraction(delegate: self)
//                dragInteraction1.isEnabled = true
//                viewBlock.isUserInteractionEnabled = true
//                viewBlock.addInteraction(dragInteraction1)
//
//                let delayTime = 0.0
//                if let longPressRecognizer = viewBlock.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
//                    longPressRecognizer.minimumPressDuration = delayTime // your custom value
//                }
            }
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began,.changed:
            if self.initialFrame == nil {
                let currentFilledPattern:BlockDesignView = (gestureRecognizer.view as? BlockDesignView)!
                self.initialFrame = currentFilledPattern.frame
            }
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
            break
        case .ended:
            print("Ended")
                        
            let dropLocation = gestureRecognizer.location(in: view)
            
            let currentFilledPattern:BlockDesignView = (gestureRecognizer.view as? BlockDesignView)!
            var isLocationExist = false

            for view in self.view.subviews {
                if let bucket = view as? BlockDesignBucketView {
                    if bucket.iModel!.id == currentFilledPattern.iModel!.id {
                        if bucket.frame.contains(dropLocation) {
                            isLocationExist = true
                            self.handleValidDropLocation(filledBlockDesignView: currentFilledPattern, emptyBlockDesignView: bucket)
                            break
                        }
                    }
                }
            }
                
            if !isLocationExist {
                self.handleInvalidDropLocation(currentBlockDesignView:currentFilledPattern)
            } else {
            }
            break
        default:
            break
        }
    }
    
    //MARK:- UIDragInteraction delegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let currentFilledImageView:BlockDesignView = (interaction.view as? BlockDesignView)!
        guard let image = currentFilledImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
        
        let dropLocation = session.location(in: self.view)
        
        let currentFilledPattern:BlockDesignView = (interaction.view as? BlockDesignView)!
        var isLocationExist = false

        for view in self.view.subviews {
            if let bucket = view as? BlockDesignBucketView {
                if bucket.iModel!.id == currentFilledPattern.iModel!.id {
                    if bucket.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledBlockDesignView: currentFilledPattern, emptyBlockDesignView: bucket)
                        break
                    }
                }
            }
        }
            
        if !isLocationExist {
            self.handleInvalidDropLocation(currentBlockDesignView:currentFilledPattern)
        } else {
        }
    }
    
    private func listenModelClosures() {
       self.blockDesignInfoViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.blockDesignInfoViewModel.accessmentSubmitResponseVO {
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
}

extension AssessmentBlockDesignViewController {

    private func handleInvalidDropLocation(currentBlockDesignView:BlockDesignView){
           DispatchQueue.main.async {
                SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            self.incorrectDragDropCount += 1

               if let frame = self.initialFrame {
                   currentBlockDesignView.frame = frame
                   self.initialFrame = nil
               }
           }
    }
    
    private func handleValidDropLocation(filledBlockDesignView:BlockDesignView, emptyBlockDesignView:BlockDesignBucketView){
           DispatchQueue.main.async {
           filledBlockDesignView.isHidden = true
           self.initialFrame = nil
           emptyBlockDesignView.image = filledBlockDesignView.image
           self.success_count += 1
           if self.success_count < self.blockDesignInfo.images.count {
//                   SpeechManager.shared.speak(message: SpeechMessage.excellentWork.getMessage(self.blokDesignInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
               } else {
               
                   self.questionState = .submit
                   SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.blockDesignInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
               }
           }
    }
}

extension AssessmentBlockDesignViewController {
   
    @objc private func calculateTimeTaken() {
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1
        if trailPromptTimeForUser == blockDesignInfo.trial_time && self.timeTakenToSolve < blockDesignInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.blockDesignInfo.completion_time  {
            self.moveToNextQuestion()
        }
    }
    
    private func moveToNextQuestion() {
        self.stopQuestionCompletionTimer()
        self.questionState = .submit
        self.success_count = 0
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    
}
}

// MARK: Speech Manager Delegate Methods
extension AssessmentBlockDesignViewController: SpeechManagerDelegate {
    
    
    func speechDidFinish(speechText: String) {

        switch self.questionState {
        case .submit:
            let imagesCount:Int = self.blockDesignInfo.images.count
            if(self.success_count == imagesCount) {
                self.success_count = 100
            } else {
                let perPer = 100/imagesCount
                self.success_count = self.success_count*perPer
            }
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
          
            self.blockDesignInfoViewModel.submitUserAnswer(successCount: self.success_count, info: self.blockDesignInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion,touchOnEmptyScreenCount: touchOnEmptyScreenCount, incorrectDragDropCount: incorrectDragDropCount)
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

class BlockDesignView : UIImageView {
    var iModel : ImageModel?
}

class BlockDesignBucketView : UIImageView {
    var iModel : ImageModel?
}

extension AssessmentBlockDesignViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentBlockDesignViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
