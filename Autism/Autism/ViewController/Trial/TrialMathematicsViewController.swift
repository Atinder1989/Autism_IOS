//
//  TrialMathematicsViewController.swift
//  Autism
//
//  Created by Dilip Technology on 14/04/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TrialMathematicsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var pictureImageView1: UIImageView!
    @IBOutlet weak var pictureImageView2: UIImageView!
    
    @IBOutlet weak var lblAdd1: UILabel!
    @IBOutlet weak var lblAdd2: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtAnwere: UITextField!
    @IBOutlet weak var submitButton: UIButton!
     
     private var touchOnEmptyScreenCount = 0
     private var mathematicsQuestionInfo: MathematicsCalculation!
     private weak var delegate: TrialSubmitDelegate?
     private let mathematicsViewModel = TrialMathematicsViewModel()
     private var completeRate = 0
     private var timeTakenToSolve = 0
     private var questionState: QuestionState = .inProgress
     private var skipQuestion = false
     private var isUserInteraction = false {
          didSet {
              self.view.isUserInteractionEnabled = isUserInteraction
          }
     }
 
    var isFromLearning:Bool = false
    
    
    private var apiDataState: APIDataState = .notCall
    
    @IBOutlet weak var collectionWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionKeys: UICollectionView!
    
 override func viewDidLoad() {
     super.viewDidLoad()
        
     txtAnwere.text = ""
     txtAnwere.delegate = self
     self.customSetting()
     self.listenModelClosures()
    
    self.mathematicsQuestionInfo.arrKeys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    self.mathematicsQuestionInfo.arrKeys.append("⌫")
    
    var countDouble:Int = self.mathematicsQuestionInfo.arrKeys.count/2
    countDouble = countDouble+self.mathematicsQuestionInfo.arrKeys.count%2
     
     if(UIDevice.current.userInterfaceIdiom == .pad) {
         collectionWidth.constant = CGFloat(countDouble*100)
     } else {
         collectionWidth.constant = CGFloat(countDouble*50)
     }
    
 }
    
 
    @objc func btnKeyClicked(_ sender:UIButton) {
                
        let keyText = sender.title(for: .normal) ?? ""
        print("keyText = ", keyText)
        
        if(keyText == "⌫") {
            if(txtAnwere.text!.count > 0) {
                txtAnwere.text = String((txtAnwere.text?.dropLast())!)
            }
        } else {
            txtAnwere.text = txtAnwere.text! + keyText
        }
        
    }
    
 override func viewWillAppear(_ animated: Bool) {
     NotificationCenter.default.addObserver(self, selector: #selector(TrialMathematicsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(TrialMathematicsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
 }
    
 override func viewWillDisappear(_ animated: Bool) {
     self.mathematicsViewModel.stopAllCommands()

     NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
     NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
 }
 
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     touchOnEmptyScreenCount += 1
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
    
    private func stopTimer() {
     AutismTimer.shared.stopTimer()
    }
     
     private func stopSpeechAndRecorder() {
         SpeechManager.shared.setDelegate(delegate: nil)
         RecordingManager.shared.stopRecording()
         RecordingManager.shared.stopWaitUserAnswerTimer()
     }
    
    func submitTrialMatchingAnswer(info:MathematicsCalculation) {

        if let user = UserManager.shared.getUserInfo() {

            let parameters: [String : Any] = [
               ServiceParsingKeys.user_id.rawValue :user.id,
               ServiceParsingKeys.question_type.rawValue :info.question_type,
               ServiceParsingKeys.time_taken.rawValue :self.timeTakenToSolve,
               ServiceParsingKeys.complete_rate.rawValue :completeRate,
               ServiceParsingKeys.success_count.rawValue : completeRate,
               ServiceParsingKeys.question_id.rawValue :info.id,
               ServiceParsingKeys.language.rawValue:user.languageCode,
               ServiceParsingKeys.req_no.rawValue:info.req_no,
               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
               ServiceParsingKeys.level.rawValue:info.level,
               ServiceParsingKeys.skip.rawValue:skipQuestion,
                ServiceParsingKeys.program_id.rawValue:info.program_id,

                ServiceParsingKeys.course_type.rawValue:"Trial",
                ServiceParsingKeys.prompt_type.rawValue:info.prompt_type,

                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
            ]
            LearningManager.submitTrialMatchingAnswer(parameters: parameters)
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

extension TrialMathematicsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mathematicsQuestionInfo.arrKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            return CGSize.init(width:80, height: 80)
        } else {
            return CGSize.init(width:40, height: 40)
        }
       }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:SpellingKeyBoardCell.identifier, for: indexPath as IndexPath) as! SpellingKeyBoardCell
            
        let strKey = self.mathematicsQuestionInfo.arrKeys[indexPath.row]
        
        cell.btnKey.setTitle(strKey, for: .normal)
        cell.btnKey.addTarget(self, action: #selector(btnKeyClicked(_:)), for: .touchDown)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            cell.btnKey.frame = CGRect(x: 5, y: 5, width: 70, height: 70)
        } else {
            cell.btnKey.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        }
        
        let cornerRadius:CGFloat = 10.0
        Utility.setView(view: cell.btnKey, cornerRadius: cornerRadius, borderWidth: 0.5, color: .lightGray)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
    }
}
extension TrialMathematicsViewController {
        func setMathematicsQuestionInfo(info:MathematicsCalculation,delegate:TrialSubmitDelegate) {
            self.apiDataState = .dataFetched
            self.mathematicsQuestionInfo = info
            self.delegate = delegate
        }
        
        func setMathematicsQuestionInfo(info:MathematicsCalculation) {
            self.apiDataState = .dataFetched
            self.mathematicsQuestionInfo = info
        }
    }

extension TrialMathematicsViewController {
    private func customSetting() {
        
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.lblTitle.text = mathematicsQuestionInfo.question_title
                        
        Utility.setView(view: txtAnwere, cornerRadius: 5, borderWidth: 2, color: UIColor.purpleBorderColor)

        lblAdd1.text = mathematicsQuestionInfo.first_digit
        lblAdd2.text = mathematicsQuestionInfo.operatorString+mathematicsQuestionInfo.second_digit
        
        
        ImageDownloader.sharedInstance.downloadImage(urlString: mathematicsQuestionInfo.video_url, imageView: self.pictureImageView1, callbackAfterNoofImages: 2, delegate: self)
        ImageDownloader.sharedInstance.downloadImage(urlString: mathematicsQuestionInfo.video_url, imageView: self.pictureImageView2, callbackAfterNoofImages: 2, delegate: self)
    }
    
    private func listenModelClosures() {
        self.mathematicsViewModel.dataClosure = {
          DispatchQueue.main.async {
              if let res = self.mathematicsViewModel.trialSubmitResponseVO {
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
  
      self.mathematicsViewModel.startPracticeClosure = {
          DispatchQueue.main.async {
              self.apiDataState = .comandFinished
            AutismTimer.shared.initializeTimer(delegate: self)
            self.isUserInteraction = true
          }
      }
        //P1
        self.mathematicsViewModel.blinkAllImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                self.blinkAllImages(questioninfo, count: Int(questioninfo.option!.time_in_second)!)
            }
        }
        //P2
        self.mathematicsViewModel.blinkAllTextClosure = { questionInfo in
              DispatchQueue.main.async {
                self.blinkAllText(questionInfo, count: Int(questionInfo.option!.blink_count)!)
              }
          }
        
        self.mathematicsViewModel.blinkImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                self.blinkImage(questioninfo, count: Int(questioninfo.option!.time_in_second)!)
             }
        }
        
        self.mathematicsViewModel.blinkTextClosure = { questionInfo in
              DispatchQueue.main.async {
                self.blinkText(questionInfo, count: Int(questionInfo.option!.time_in_second)!)
              }
          }
        
        self.mathematicsViewModel.childActionClosure = { questionInfo in
            DispatchQueue.main.async {
                self.childActionStart(questionInfo)
                self.isUserInteraction = true
            }
        }
          
    }
    
    private func blinkAllImages(_ questionInfo:ScriptCommandInfo, count: Int) {
        
        print("blinkAllImages")
        if count == 0 {
            if(questionInfo.condition.lowercased() == "no") {
                self.mathematicsViewModel.updateCurrentCommandIndex()
            }
            return
        }
        DispatchQueue.main.async {

            UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                self.pictureImageView1.alpha = 0.2
                self.pictureImageView2.alpha = 0.2
            }) { [self] finished in
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.pictureImageView1.alpha = 1
                    self.pictureImageView2.alpha = 1
                }) { [self] finished in
                    self.blinkAllImages(questionInfo, count: count-1)
                }
            }
        }
    }
    
    private func blinkAllText(_ questionInfo:ScriptCommandInfo, count:Int) {
        
        var index:Int = count
        if(index == 0) {
            if(questionInfo.condition.lowercased() == "no") {
                self.mathematicsViewModel.updateCurrentCommandIndex()
            }
            return
        }

        UIView.animate(withDuration: learningAnimationDuration-2, animations: {
            self.lblAdd1.alpha = 0.2
            self.lblAdd2.alpha = 0.2
        }) { [self] finished in
            UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                self.lblAdd1.alpha = 1
                self.lblAdd2.alpha = 1
            }) { [self] finished in
                index = index-1
                self.blinkAllText(questionInfo, count: index)
            }
        }
    }
    
    private func blinkImage(_ questionInfo:ScriptCommandInfo, count: Int) {
        if count == 0 {
            if(questionInfo.condition.lowercased() == "no") {
                self.mathematicsViewModel.updateCurrentCommandIndex()
            }
            return
        }
        DispatchQueue.main.async {

            if(questionInfo.value == "first_image") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.pictureImageView1.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.pictureImageView1.alpha = 1.0
                    }) { [self] finished in
                        blinkImage(questionInfo, count: count - 1)
                    }
                }
            } else if(questionInfo.value == "second_image") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.pictureImageView2.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.pictureImageView2.alpha = 1.0
                    }) { [self] finished in
                        blinkImage(questionInfo, count: count - 1)
                    }
                }
            }
        }
    }

    private func blinkText(_ questionInfo:ScriptCommandInfo, count:Int) {
                
        if(count == 0) {
            if(questionInfo.condition.lowercased() == "no") {
                self.mathematicsViewModel.updateCurrentCommandIndex()
            }
            return
        }
        
        DispatchQueue.main.async {

            if(questionInfo.value == "first_digit") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.lblAdd1.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.lblAdd1.alpha = 1.0
                    }) { [self] finished in
                        blinkText(questionInfo, count: count - 1)
                    }
                }
            } else if(questionInfo.value == "second_digit") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.lblAdd2.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.lblAdd2.alpha = 1.0
                    }) { [self] finished in
                        blinkText(questionInfo, count: count - 1)
                    }
                }
            }
        }
        
    }

    private func childActionStart(_ questionInfo:ScriptCommandInfo) {
        print("childActionStart")
        if let option = questionInfo.option {
            if(option.time_in_second != ""){
                self.timeTakenToSolve = Int(self.mathematicsQuestionInfo.trial_time) - Int(option.time_in_second)!
            }
        }
        self.mathematicsViewModel.updateCurrentCommandIndex()
    }
    
    @IBAction func callDone(sender: UIButton) {
        self.questionState = .submit
        self.txtAnwere.text = self.txtAnwere.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if(txtAnwere.text == "") {
            return
        }
        if txtAnwere.text?.lowercased() == mathematicsQuestionInfo.correct_value.lowercased() {
            self.completeRate = 100
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else {
            self.completeRate = 0
            SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}

extension TrialMathematicsViewController {
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        print(timeTakenToSolve)
        if self.timeTakenToSolve == self.mathematicsQuestionInfo.trial_time {
            //SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.mathematicsQuestionInfo.completion_time + self.mathematicsQuestionInfo.trial_time {
            self.moveToNextQuestion()
          
        }
}
    
    private func moveToNextQuestion() {
        self.stopQuestionCompletionTimer()
        self.completeRate = 0
        self.questionState = .submit
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }

    func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    }
}

// MARK: Speech Manager Delegate Methods
extension TrialMathematicsViewController: SpeechManagerDelegate {
    
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob {
                self.avatarImageView.animatedImage =  getIdleGif()
            }
        }
        else {
            self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.stopSpeechAndRecorder()
            if(self.isFromLearning == false) {
                self.mathematicsViewModel.submitMathematicsQuestionDetails(info: self.mathematicsQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
                self.submitTrialMatchingAnswer(info: self.mathematicsQuestionInfo)
            }
            break
        default:
            
            
            if(apiDataState == .imageDownloaded) {
                if self.mathematicsQuestionInfo.prompt_detail.count > 0 {
                    apiDataState = .comandRunning
                    self.mathematicsViewModel.setQuestionInfo(info:self.mathematicsQuestionInfo)
                } else {
                    self.mathematicsViewModel.setQuestionInfo(info:self.mathematicsQuestionInfo)
                }
            } else if(apiDataState == .comandRunning) {
                DispatchQueue.main.async {
                    self.mathematicsViewModel.updateCurrentCommandIndex()
                }
            } else if(apiDataState == .comandFinished) {
                //self.startRec()
            }
            
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

extension TrialMathematicsViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.apiDataState = .imageDownloaded
            SpeechManager.shared.speak(message: self.mathematicsQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}
extension TrialMathematicsViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                
            } else if(self.apiDataState == .dataFetched) {
                ImageDownloader.sharedInstance.downloadImage(urlString: mathematicsQuestionInfo.video_url, imageView: self.pictureImageView1, callbackAfterNoofImages: 1, delegate: self)
                ImageDownloader.sharedInstance.downloadImage(urlString: mathematicsQuestionInfo.video_url, imageView: self.pictureImageView2, callbackAfterNoofImages: 1, delegate: self)
            } else {

            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension TrialMathematicsViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
