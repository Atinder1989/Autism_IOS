//
//  AssessmentMakeWordViewController.swift
//  Autism
//
//  Created by Dilip Technology on 17/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import MobileCoreServices
import FLAnimatedImage

class AssessmentMakeWordViewController: UIViewController, UIDragInteractionDelegate {

    private var makeWordInfo: MakeWordInfo!
    private let makeWordInfoViewModel = AssessmentMakeWordInfoViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    
    @IBOutlet weak var labelTitle: UILabel!
        @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    private var initialFrame: CGRect?
    private var skipQuestion = false
    
    private var actualWorrd:String = ""
    private var arrAlphabets:[UILabel] = []
    private var touchOnEmptyScreenCount = 0

    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            self.customSetting()
            self.listenModelClosures()
            self.initializeFilledLabel()
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
    extension AssessmentMakeWordViewController {
        func setMakeWordInfo(info:MakeWordInfo,delegate:AssessmentSubmitDelegate) {
            self.makeWordInfo = info
            self.delegate = delegate
        }
    }

    // MARK: - UIDragInteractionDelegate

    extension AssessmentMakeWordViewController {
        
        @objc private func calculateTimeTaken() {
            
            if !Utility.isNetworkAvailable() {
                return
            }
             self.timeTakenToSolve += 1
            trailPromptTimeForUser += 1

            if trailPromptTimeForUser == makeWordInfo.trial_time && self.timeTakenToSolve < makeWordInfo.completion_time
            {
                trailPromptTimeForUser = 0
                SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else if self.timeTakenToSolve == self.makeWordInfo.completion_time {
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
               self.makeWordInfoViewModel.dataClosure = {
                   DispatchQueue.main.async {
                       if let res = self.makeWordInfoViewModel.accessmentSubmitResponseVO {
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
            self.actualWorrd = self.makeWordInfo.word[0].name
            let title = self.makeWordInfo.question_title + " " + self.actualWorrd
            self.labelTitle.text = title

            SpeechManager.shared.setDelegate(delegate: self)
            SpeechManager.shared.speak(message:title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            
                                    
            var xRef:CGFloat = 100.00
            let yRef:CGFloat = 240.0
            let space:CGFloat = 20.0
            
            let widthHeight:CGFloat = 130
            
            let totalSpace = CGFloat(CGFloat(self.actualWorrd.count)*widthHeight) + CGFloat(CGFloat(self.actualWorrd.count-1)*space)
            
            let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
            xRef = (screenWidth-totalSpace)/2.0
            
            for i in 0..<self.actualWorrd.count {
                
                let lblAlphabet: AlphabetBucketView = AlphabetBucketView()
                lblAlphabet.tag = i
                let index = self.actualWorrd.index(self.actualWorrd.startIndex, offsetBy: i)
                lblAlphabet.name = String(self.actualWorrd[index])
                lblAlphabet.frame = CGRect(x:xRef, y:yRef, width:widthHeight, height:widthHeight)
                lblAlphabet.backgroundColor = .white
                lblAlphabet.layer.cornerRadius  = 30.0
                lblAlphabet.clipsToBounds = true
                lblAlphabet.textColor = .black
                lblAlphabet.textAlignment = .center
                lblAlphabet.font = UIFont.boldSystemFont(ofSize:widthHeight/2.0)
                lblAlphabet.textColor = .black
                self.view.addSubview(lblAlphabet)
                
                xRef = xRef+widthHeight+space                
            }
            
            AutismTimer.shared.initializeTimer(delegate: self)
        }
        

        private func initializeFilledLabel() {
            
            var xRef:CGFloat = 40.90
            let yRef:CGFloat = 400.0
            let space:CGFloat = 20.0
            
            xRef = 0
            
            let widthHeight:CGFloat = 130
            
            let totalSpace = CGFloat(CGFloat(self.makeWordInfo.option.count)*widthHeight) + CGFloat(CGFloat(self.makeWordInfo.option.count-1)*space)
            
            let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
            xRef = (screenWidth-totalSpace)/2.0
            
            self.arrAlphabets.removeAll()
            for objOption in self.makeWordInfo.option {
                
                let lblAlphabet: AlphabetUILabel = AlphabetUILabel()
                lblAlphabet.frame = CGRect(x:xRef, y:yRef, width:widthHeight, height:widthHeight)
                lblAlphabet.backgroundColor = .white
                lblAlphabet.layer.cornerRadius  = 30.0//widthHeight/2.0
                lblAlphabet.textColor = .black
                lblAlphabet.textAlignment = .center
                lblAlphabet.font = UIFont.boldSystemFont(ofSize:widthHeight/2.0)
                lblAlphabet.clipsToBounds = true
                lblAlphabet.textColor = .black
                lblAlphabet.oModel = objOption
                lblAlphabet.text = objOption.name
                self.view.addSubview(lblAlphabet)
                lblAlphabet.isUserInteractionEnabled = true

                xRef = xRef+widthHeight+space
                
                arrAlphabets.append(lblAlphabet)
                
                let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
                lblAlphabet.addGestureRecognizer(gestureRecognizer)

                
//                let dragInteraction1 = UIDragInteraction(delegate: self)
//                dragInteraction1.isEnabled = true
//                lblAlphabet.isUserInteractionEnabled = true
//                lblAlphabet.addInteraction(dragInteraction1)
//
//                let delayTime = 0.0
//                if let longPressRecognizer = lblAlphabet.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
//                    longPressRecognizer.minimumPressDuration = delayTime
//                }
            }
        }
        
        @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .began,.changed:
                if self.initialFrame == nil {
                    let currentFilledPattern:AlphabetUILabel = (gestureRecognizer.view as? AlphabetUILabel)!
                    self.initialFrame = currentFilledPattern.frame
                }
                let translation = gestureRecognizer.translation(in: self.view)
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
                break
            case .ended:
                print("Ended")
                
                let dropLocation = gestureRecognizer.location(in: view)
                
                let currentFilledLabel:AlphabetUILabel = (gestureRecognizer.view as? AlphabetUILabel)!
                var isLocationExist = false
                
                for view in self.view.subviews {
                    if let bucket = view as? AlphabetBucketView {
                        if bucket.name!.lowercased() == currentFilledLabel.oModel?.name.lowercased() {
                            if bucket.frame.contains(dropLocation) {
                                isLocationExist = true
                                self.handleValidDropLocation(filledUILabel: currentFilledLabel, emptyLabel: bucket)
                                break
                            }
                        }
                        
                    }
                }
                
                if !isLocationExist {
                    self.handleInvalidDropLocation(currentLabelView:currentFilledLabel)
                }
                break
            default:
                break
            }
        }
    }

extension AssessmentMakeWordViewController {

            //MARK:- UIDragInteraction delegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let currentFilledAlphabetView:AlphabetUILabel = (interaction.view as? AlphabetUILabel)!
        guard let text = currentFilledAlphabetView.text else { return [] }
        let provider = NSItemProvider(object: text as NSItemProviderWriting)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = text
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
        
        let dropLocation = session.location(in: self.view)
        
        let currentFilledLabel:AlphabetUILabel = (interaction.view as? AlphabetUILabel)!
        var isLocationExist = false

        for view in self.view.subviews {
            if let bucket = view as? AlphabetBucketView {
                if bucket.name!.lowercased() == currentFilledLabel.oModel?.name.lowercased() {
                    if bucket.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledUILabel: currentFilledLabel, emptyLabel: bucket)
                        break
                    }
                }
                
            }
        }
        
        if !isLocationExist {
            self.handleInvalidDropLocation(currentLabelView:currentFilledLabel)
        }
    }
    
    private func handleInvalidDropLocation(currentLabelView:UILabel){
           DispatchQueue.main.async {
               SpeechManager.shared.speak(message: self.makeWordInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
               if let frame = self.initialFrame {
                   currentLabelView.frame = frame
                   self.initialFrame = nil
               }
           }
    }
    
    private func handleValidDropLocation(filledUILabel:AlphabetUILabel,emptyLabel:AlphabetBucketView){
           DispatchQueue.main.async {
            //filledUILabel.frame = self.initialFrame!
            filledUILabel.isHidden = true
            self.initialFrame = nil
            emptyLabel.text = filledUILabel.text
            filledUILabel.text = ""
            self.success_count += 1
            if self.success_count < Int(self.actualWorrd.count) {
                    //SpeechManager.shared.speak(message: SpeechMessage.excellentWork.getMessage(self.blokDesignInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                self.success_count = 100
                    self.questionState = .submit
                    SpeechManager.shared.speak(message: self.makeWordInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            }
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentMakeWordViewController: SpeechManagerDelegate {
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
            
            let wordCount:Int = self.actualWorrd.count
            
            if(self.success_count == wordCount) {
                self.success_count = 100
            } else {
                let perPer = 100/wordCount
                self.success_count = self.success_count*perPer
            }
            self.makeWordInfoViewModel.submitUserAnswer(successCount: self.success_count,  info: self.makeWordInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount )
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

class AlphabetUILabel : UILabel {
    var oModel : OptionModel?
}

class AlphabetBucketView : UILabel {
    var name : String?
}
extension AssessmentMakeWordViewController: NetworkRetryViewDelegate {

    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentMakeWordViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
