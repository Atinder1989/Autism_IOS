//
//  AssesmentMatchDateViewController.swift
//  Autism
//
//  Created by mac on 18/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssesmentMatchDateViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var whitebackgroundView: UIView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    private weak var delegate: AssessmentSubmitDelegate?
    private let matchobjectViewModel = AssesmentMatchDateViewModel()
    private var matchObjectQuestionInfo: MatchDate!
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isUserInteraction = false {
         didSet {
             self.view.isUserInteractionEnabled = isUserInteraction
         }
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
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
extension AssesmentMatchDateViewController {
        func setSortQuestionInfo(info:MatchDate,delegate:AssessmentSubmitDelegate) {
            self.matchObjectQuestionInfo = info
            self.delegate = delegate
        }
}

extension AssesmentMatchDateViewController {
     private func moveToNextQuestion() {
        self.stopQuestionCompletionTimer()
        self.questionState = .submit
        self.success_count = 0
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func customSetting() {
        isUserInteraction = false
        Utility.setView(view: self.btnSubmit, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.whitebackgroundView, cornerRadius: 10, borderWidth: 0, color: .clear)
        Utility.setView(view: self.datePickerView, cornerRadius: 10, borderWidth: 2, color: .darkGray)
        Utility.setView(view: self.lblDate, cornerRadius: 10, borderWidth: 2, color: UIColor.purpleBorderColor)
         lblTitle.text = matchObjectQuestionInfo.question_title
        lblDate.text = matchObjectQuestionInfo.answer_date
         datePickerView.addTarget(self, action: #selector(AssesmentMatchDateViewController.datePickerValueChanged), for: UIControl.Event.valueChanged)
        SpeechManager.shared.setDelegate(delegate: self)
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    private func listenModelClosures() {
       self.matchobjectViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.matchobjectViewModel.accessmentSubmitResponseVO {
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
    @objc func datePickerValueChanged(sender:UIDatePicker) {

    }
      @IBAction func callDone(sender: UIButton) {
        self.questionState = .submit
        let selectedDate = Utility.convertDateToString(date: datePickerView.date, format: "dd-MM-yyyy")
        if selectedDate == matchObjectQuestionInfo.answer_date {
                            self.success_count = 100
                                     SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.matchObjectQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

            
                                }
                                else {
            self.success_count = 0
                        SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(self.matchObjectQuestionInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
    }
}

extension AssesmentMatchDateViewController {
    
@objc private func calculateTimeTaken() {
    
    if !Utility.isNetworkAvailable() {
        return
    }
        self.timeTakenToSolve += 1
    trailPromptTimeForUser += 1

        if self.timeTakenToSolve == Int(AppConstant.screenloadQuestionSpeakTimeDelay.rawValue) {
            SpeechManager.shared.speak(message:matchObjectQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if trailPromptTimeForUser == matchObjectQuestionInfo.trial_time && self.timeTakenToSolve < matchObjectQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.matchObjectQuestionInfo.completion_time {
            self.moveToNextQuestion()
       }
    }

    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
       
    }
}

// MARK: Speech Manager Delegate Methods
extension AssesmentMatchDateViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true
        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob && type != .wrongAnswer {
                       self.avatarImageView.animatedImage =  getIdleGif()
                   }
               } else {
                       self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.matchobjectViewModel.submitUserAnswer(successCount: success_count, info: self.matchObjectQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion)
            break
        default:
            isUserInteraction = true
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
            case .wrongAnswer:
                self.avatarImageView.animatedImage =  getWrongAnswerGif()
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage =  getTalkingGif()
    }
}

extension AssesmentMatchDateViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssesmentMatchDateViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
