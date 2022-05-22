//
//  AssesmentMatchSpellingViewController.swift
//  Autism
//
//  Created by mac on 19/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssesmentMatchSpellingViewController: UIViewController, UITextFieldDelegate {
       @IBOutlet weak var avatarImageView: FLAnimatedImageView!
       @IBOutlet weak var pictureImageView: UIImageView!
       @IBOutlet weak var lblTitle: UILabel!
       @IBOutlet weak var txtAnwere: UITextField!
       @IBOutlet weak var submitButton: UIButton!
        
        private var touchOnEmptyScreenCount = 0
        private var matchSpellingQuestionInfo: MatchSpelling!
        private weak var delegate: AssessmentSubmitDelegate?
        private let matchSpellingViewModel = AssesmentMatchSpellingViewModel()
        private var success_count = 0
        private var timeTakenToSolve = 0
        private var questionState: QuestionState = .inProgress
        private var skipQuestion = false
        private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
        }
    
    private var apiDataState: APIDataState = .notCall

    override func viewDidLoad() {
        super.viewDidLoad()
        txtAnwere.delegate = self
        self.customSetting()
        self.listenModelClosures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMatchSpellingViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMatchSpellingViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
        self.view.endEditing(true)
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
        if string.rangeOfCharacter(from: .letters) != nil || string == ""{
            return true
        }else {
            return false
        }
    }

}

extension AssesmentMatchSpellingViewController {
        func setSortQuestionInfo(info:MatchSpelling,delegate:AssessmentSubmitDelegate) {
            self.apiDataState = .dataFetched
            self.matchSpellingQuestionInfo = info
            self.delegate = delegate
        }
    }

extension AssesmentMatchSpellingViewController {
    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        Utility.setView(view: txtAnwere, cornerRadius: 5, borderWidth: 2, color: UIColor.purpleBorderColor)
        Utility.setView(view: self.pictureImageView, cornerRadius: Utility.isRunningOnIpad() ? 225 : 80, borderWidth: 2, color: .darkGray)
        let array = matchSpellingQuestionInfo.question_title.components(separatedBy: "<br>")
        if array.count == 2 {
            lblTitle.text = array[0]

            self.txtAnwere.attributedPlaceholder = NSAttributedString(string: array[1],
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        else {
            lblTitle.text = self.matchSpellingQuestionInfo.question_title
        }
        ImageDownloader.sharedInstance.downloadImage(urlString: matchSpellingQuestionInfo.image, imageView: self.pictureImageView, callbackAfterNoofImages: 1, delegate: self)
    }
    
    private func listenModelClosures() {
          self.matchSpellingViewModel.dataClosure = {
             DispatchQueue.main.async {
                   if let res = self.matchSpellingViewModel.accessmentSubmitResponseVO {
                           if res.success {
                             self.dismiss(animated: true) {
                                   if let del = self.delegate {
                                    self.stopQuestionCompletionTimer()
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
        if txtAnwere.text?.lowercased() == matchSpellingQuestionInfo.answer.lowercased() {
            self.success_count = 100
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.matchSpellingQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

        }
        else {
                self.success_count = 0
            SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(self.matchSpellingQuestionInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                                }
    }
}

extension AssesmentMatchSpellingViewController {
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1
        
        if trailPromptTimeForUser == matchSpellingQuestionInfo.trial_time && self.timeTakenToSolve < matchSpellingQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.matchSpellingQuestionInfo.completion_time {
            self.moveToNextQuestion()
          
        }
}
    
    private func moveToNextQuestion() {
        self.stopQuestionCompletionTimer()
        self.success_count = 0
        self.questionState = .submit
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }

    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    }
}

// MARK: Speech Manager Delegate Methods
extension AssesmentMatchSpellingViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob && type != .wrongAnswer {
                       self.avatarImageView.animatedImage =  getIdleGif()
                   }
               }
        else {
                       self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.matchSpellingViewModel.submitUserAnswer(successCount: self.success_count, info: self.matchSpellingQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount)
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

extension AssesmentMatchSpellingViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.apiDataState = .imageDownloaded
            let array = self.matchSpellingQuestionInfo.question_title.components(separatedBy: "<br>")
            if array.count >= 2 {
                let questiontitle = array[0]
                SpeechManager.shared.speak(message: questiontitle, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else {
                SpeechManager.shared.speak(message: self.matchSpellingQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
            AutismTimer.shared.initializeTimer(delegate: self)
        }
    }
}
extension AssesmentMatchSpellingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                
            } else if(self.apiDataState == .dataFetched) {
                ImageDownloader.sharedInstance.downloadImage(urlString: matchSpellingQuestionInfo.image, imageView: self.pictureImageView, callbackAfterNoofImages: 1, delegate: self)
            } else {

            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssesmentMatchSpellingViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
