//
//  AssesmentMathematicsViewController.swift
//  Autism
//
//  Created by mac on 19/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssesmentMathematicsViewController: UIViewController, UITextFieldDelegate {
    
    private var mathematicsCalculationQuestionInfo: MathematicsCalculation!
    private weak var delegate: AssessmentSubmitDelegate?
    private let mathematicsCalculationViewModel = AssesmentMathmeticsViewModel()
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false

    private var isUserInteraction = false {
        didSet {
            self.view.isUserInteractionEnabled = isUserInteraction
        }
    }
    
    @IBOutlet weak var lblQuestionTitle: UILabel!
    @IBOutlet weak var lblQuestionData: UILabel!
    @IBOutlet weak var txtAnwere: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtAnwere.delegate = self
        self.customSetting()
        self.listenModelClosures()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMathematicsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMathematicsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: .decimalDigits) != nil || string == ""{
            return true
        }else {
            return false
        }
    }
}
extension AssesmentMathematicsViewController {
        func setSortQuestionInfo(info:MathematicsCalculation,delegate:AssessmentSubmitDelegate) {
            self.mathematicsCalculationQuestionInfo = info
            self.delegate = delegate
        }
    }

extension AssesmentMathematicsViewController {
    private func customSetting() {
        isUserInteraction = false
        self.txtAnwere.attributedPlaceholder = NSAttributedString(string: "Type your answer here",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        Utility.setView(view: self.lblQuestionData, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.txtAnwere, cornerRadius: 5, borderWidth: 1, color: UIColor.purpleBorderColor)
        SpeechManager.shared.setDelegate(delegate: self)
        lblQuestionTitle.text = mathematicsCalculationQuestionInfo.question_title
        
        Utility.setView(view: self.submitBtn, cornerRadius: self.submitBtn.frame.size.height/2.0, borderWidth: 1, color: .lightGray)
        let questionString = self.mathematicsCalculationQuestionInfo.first_digit + " " + self.mathematicsCalculationQuestionInfo.operatorString + " " + self.mathematicsCalculationQuestionInfo.second_digit
        lblQuestionData.text = questionString
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func listenModelClosures() {
       self.mathematicsCalculationViewModel.dataClosure = {
          DispatchQueue.main.async {
            if let res = self.mathematicsCalculationViewModel.accessmentSubmitResponseVO {
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
    
    @IBAction func callDone(sender: UIButton) {
        self.questionState = .submit
        if txtAnwere.text == mathematicsCalculationQuestionInfo.correct_value {
                self.success_count = 100
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.mathematicsCalculationQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
            else {
                self.success_count = 0
            SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(self.mathematicsCalculationQuestionInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
        }
    }
extension AssesmentMathematicsViewController {
    
    
    private func moveToNextQuestion() {
        self.stopQuestionCompletionTimer()
        self.questionState = .submit
        self.success_count = 0
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        self.timeTakenToSolve += 1

        if self.timeTakenToSolve == Int(AppConstant.screenloadQuestionSpeakTimeDelay.rawValue) {
            SpeechManager.shared.speak(message:  mathematicsCalculationQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if trailPromptTimeForUser == mathematicsCalculationQuestionInfo.trial_time && self.timeTakenToSolve < mathematicsCalculationQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.mathematicsCalculationQuestionInfo.completion_time {
            self.moveToNextQuestion()
        }
}

private func stopQuestionCompletionTimer() {
    AutismTimer.shared.stopTimer()
    }
}

// MARK: Speech Manager Delegate Methods
extension AssesmentMathematicsViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob && type != .wrongAnswer {
                self.avatarImageView.animatedImage = getIdleGif()
            }
        } else {
                self.avatarImageView.animatedImage = getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.mathematicsCalculationViewModel.submitUserAnswer(successCount: success_count, info: self.mathematicsCalculationQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion)
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
                self.avatarImageView.animatedImage = getHurrayGif()
                return
            case .wrongAnswer:
                self.avatarImageView.animatedImage = getWrongAnswerGif()
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage = getTalkingGif()
    }
}

extension AssesmentMathematicsViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssesmentMathematicsViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
