//
//  AssessmentIntroductionViewController.swift
//  Autism
//
//  Created by Dilip Technology on 13/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage


class AssessmentIntroductionViewController: UIViewController {
    
    var questionState: QuestionState = .inProgress

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    private var introductionQuestionInfo: IntroductionQuestionInfo!
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var introductionViewModel = AssessmentIntroductionViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var apiDataState: APIDataState = .notCall
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0
    
    private var isUserInteraction = false {
           didSet {
               self.view.isUserInteractionEnabled = isUserInteraction
           }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.listenModelClosures()
        self.customSetting()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
          self.stopTimer()
          self.stopSpeechAndRecorder()
          UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
            self.skipQuestion = true
            self.moveToNextQuestion()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
}

// MARK: Private Methods
extension AssessmentIntroductionViewController {
    private func listenModelClosures() {
              self.introductionViewModel.dataClosure = {
                        DispatchQueue.main.async {
                            if let res = self.introductionViewModel.accessmentSubmitResponseVO {
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
        if let user = UserManager.shared.getUserInfo() {
            isUserInteraction = false
            SpeechManager.shared.setDelegate(delegate: self)
            let title = introductionQuestionInfo.question_title.replacingOccurrences(of: "(child_name)", with: Utility.deCrypt(text: user.nickname))
            print(title)
            
            if self.introductionQuestionInfo.question_type == "introduction_name" {
                 self.questionTitle.text = title
            } else {
                self.questionTitle.text = ""
            }
       
        SpeechManager.shared.speak(message: title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        AutismTimer.shared.initializeTimer(delegate: self)
        }
    }
    
    private func moveToNextQuestion() {
        self.stopTimer()
                   RecordingManager.shared.stopRecording()
                   RecordingManager.shared.stopWaitUserAnswerTimer()
                   self.completeRate = 0
                   questionState = .submit
        if let user = UserManager.shared.getUserInfo() {
            let message = SpeechMessage.moveForward.getMessage() +  Utility.deCrypt(text: user.nickname)
                SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
     private func calculateTimeTaken() {
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        if self.timeTakenToSolve >= introductionQuestionInfo.trial_time  {
            self.moveToNextQuestion()
        }
    }
    
   private func stopTimer() {
    AutismTimer.shared.stopTimer()
   }
    
    private func stopSpeechAndRecorder() {
        SpeechManager.shared.setDelegate(delegate: nil)
        RecordingManager.shared.stopRecording()
        RecordingManager.shared.stopWaitUserAnswerTimer()
    }
    
}

// MARK: Public Methods
extension AssessmentIntroductionViewController {
    func setIntroductionQuestionInfo(info:IntroductionQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.introductionQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentIntroductionViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob {
                       self.avatarImageView.animatedImage =  getIdleGif()
                   }
               }
        else {
                self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        switch questionState {
        case .submit:
            var answer = ""
            if let text = self.userAnswer.text {
                answer = text
            } else {
                answer = ""
            }
            self.stopTimer()
            self.stopSpeechAndRecorder()
            self.introductionViewModel.submitIntroductionQuestionDetails(info: self.introductionQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, useranswer: answer)
            break
        default:
            self.isUserInteraction = true
            RecordingManager.shared.startRecording(delegate: self)
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .hurrayGoodJob:
                self.avatarImageView.animatedImage =  getHurrayGif()
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage =  getTalkingGif()
    }
}

//MARK:- RecordingManager Delegate Methods

extension AssessmentIntroductionViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text
    }
    
    func recordingStart() {
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.checkUserAnswer(text: speechText)
    }
    
    func checkUserAnswer(text:String) {
        
        if let user = UserManager.shared.getUserInfo() {
        if text.count > 0 {
            if self.introductionQuestionInfo.question_type == "introduction_name" {                
                if let user = UserManager.shared.getUserInfo() {
                    if text.lowercased().contains(Utility.deCrypt(text: user.nickname).lowercased()) {
                        questionState = .submit
                        self.completeRate = 100
                        SpeechManager.shared.speak(message: SpeechMessage.greatToKnowYou.getMessage() + " " + Utility.deCrypt(text: user.nickname), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    } else {
                        self.userAnswer.text = ""
                        questionState = .submit
                        self.completeRate = 100
                        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage()  + " " + Utility.deCrypt(text: user.nickname), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    }
                }
               return
            }
            
            questionState = .submit
            self.completeRate = 100
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.introductionQuestionInfo.correct_text)  + " " + Utility.deCrypt(text: user.nickname), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            
             
        } else {
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage()  + " " + Utility.deCrypt(text: user.nickname), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
            
        }
    }
}


extension AssessmentIntroductionViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                self.listenModelClosures()
            }
            SpeechManager.shared.setDelegate(delegate: self)
            RecordingManager.shared.startRecording(delegate: self)
        }
    }
}

extension AssessmentIntroductionViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
