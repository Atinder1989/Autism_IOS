//
//  TrialSpellingViewController.swift
//  Autism
//
//  Created by Dilip Technology on 31/03/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TrialSpellingViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtAnwere: UITextField!
    @IBOutlet weak var submitButton: UIButton!
     
     private var touchOnEmptyScreenCount = 0
     private var matchSpellingQuestionInfo: MatchSpelling!
     private weak var delegate: TrialSubmitDelegate?
     private let matchSpellingViewModel = TrialSpellingViewModel()
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
    
     self.customSetting()
     self.listenModelClosures()
    
    var countDouble:Int = self.matchSpellingQuestionInfo.arrKeys.count/2
    countDouble = countDouble+self.matchSpellingQuestionInfo.arrKeys.count%2
    
    collectionWidth.constant = CGFloat(countDouble*100)
    
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
     NotificationCenter.default.addObserver(self, selector: #selector(TrialSpellingViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(TrialSpellingViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
 }
 override func viewWillDisappear(_ animated: Bool) {
     
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
    
    func submitTrialMatchingAnswer(info:MatchSpelling) {
//        if !Utility.isNetworkAvailable() {
//            if let noNetwork = self.noNetWorkClosure {
//                noNetwork()
//            }
//            return
//        }

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
    
}

extension TrialSpellingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.matchSpellingQuestionInfo.arrKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize.init(width:80, height: 80)
       }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:SpellingKeyBoardCell.identifier, for: indexPath as IndexPath) as! SpellingKeyBoardCell
            
        let strKey = self.matchSpellingQuestionInfo.arrKeys[indexPath.row]
        
        cell.btnKey.setTitle(strKey, for: .normal)
        cell.btnKey.addTarget(self, action: #selector(btnKeyClicked(_:)), for: .touchDown)
        
        let cornerRadius:CGFloat = 10.0
        Utility.setView(view: cell.btnKey, cornerRadius: cornerRadius, borderWidth: 0.5, color: .lightGray)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
//        let strKey = self.matchSpellingQuestionInfo.arrKeys[indexPath.row]
//        txtAnwere.text = txtAnwere.text! + strKey
//
//        print("strKey = ", strKey)
    }
}
extension TrialSpellingViewController {
        func setSpellingQuestionInfo(info:MatchSpelling,delegate:TrialSubmitDelegate) {
            self.apiDataState = .dataFetched
            self.matchSpellingQuestionInfo = info
            self.delegate = delegate
        }
        
        func setSpellingQuestionInfo(info:MatchSpelling) {
            self.apiDataState = .dataFetched
            self.matchSpellingQuestionInfo = info
        }
    }

extension TrialSpellingViewController {
    private func customSetting() {
        
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.lblTitle.text = matchSpellingQuestionInfo.question_title
                        
        Utility.setView(view: txtAnwere, cornerRadius: 5, borderWidth: 2, color: UIColor.purpleBorderColor)

        ImageDownloader.sharedInstance.downloadImage(urlString: matchSpellingQuestionInfo.image, imageView: self.pictureImageView, callbackAfterNoofImages: 1, delegate: self)
    }
    
    private func listenModelClosures() {
        self.matchSpellingViewModel.dataClosure = {
          DispatchQueue.main.async {
              if let res = self.matchSpellingViewModel.trialSubmitResponseVO {
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
  
      self.matchSpellingViewModel.startPracticeClosure = {
          DispatchQueue.main.async {
              self.apiDataState = .comandFinished
            AutismTimer.shared.initializeTimer(delegate: self)
            self.isUserInteraction = true
          }
      }
        
        self.matchSpellingViewModel.blinkTextClosure = { questionInfo in
              DispatchQueue.main.async {
                self.blinkText(questionInfo, count: Int(questionInfo.option!.time_in_second)!*2)
              }
          }
        self.matchSpellingViewModel.showImageClosure = { questionInfo in
              DispatchQueue.main.async {
                  self.showImage()
              }
          }
        
        self.matchSpellingViewModel.showTextClosure = { questionInfo in
              DispatchQueue.main.async {
                  self.showText(questionInfo)
              }
          }

        self.matchSpellingViewModel.childActionClosure = { questionInfo in
            DispatchQueue.main.async {
                self.childActionStart(questionInfo)
                self.isUserInteraction = true
            }
        }
          
    }
    
    private func showImage() {
        self.matchSpellingViewModel.updateCurrentCommandIndex()
    }
    
    private func blinkText(_ questionInfo:ScriptCommandInfo, count:Int) {
        
        var index:Int = count
        if(index == 0) {
            self.matchSpellingViewModel.updateCurrentCommandIndex()
            return
        }
        
        if(self.matchSpellingQuestionInfo.arrKeys.contains(questionInfo.value) == true) {
            
            print("blinkText")
            let rowIndex:Int = self.matchSpellingQuestionInfo.arrKeys.firstIndex(of: questionInfo.value) ?? 0
            let cell:SpellingKeyBoardCell = collectionKeys.cellForItem(at: IndexPath.init(row: rowIndex, section: 0)) as! SpellingKeyBoardCell
            
            cell.btnKey.alpha = 0;
            
            UIView.animate(
                withDuration: 0.5,
                    delay: 0.2,
                    options: [], animations: {
                        cell.btnKey.alpha = 1
                    },
                completion: {_ in
                    index = index-1
                    self.blinkText(questionInfo, count: index)
                }
            )
        } else {
            print("Not contain")
        }
    }
    
    private func showText(_ questionInfo:ScriptCommandInfo) {
        if let option = questionInfo.option {
            if(option.transparent == "true") {
                self.txtAnwere.text = ""
                self.txtAnwere.placeholder = questionInfo.value
            } else {
                self.txtAnwere.text = questionInfo.value
            }
        }
        self.matchSpellingViewModel.updateCurrentCommandIndex()
    }
    
    private func childActionStart(_ questionInfo:ScriptCommandInfo) {
        print("childActionStart")
        if let option = questionInfo.option {
            if(option.time_in_second != ""){
                self.timeTakenToSolve = Int(self.matchSpellingQuestionInfo.trial_time) - Int(option.time_in_second)!
            }
        }
        self.matchSpellingViewModel.updateCurrentCommandIndex()
    }
    
    @IBAction func callDone(sender: UIButton) {
        self.questionState = .submit
        if txtAnwere.text?.lowercased() == matchSpellingQuestionInfo.answer.lowercased() {
            self.completeRate = 100
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

        }
        else {
                self.completeRate = 0
            SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                                }
    }
}

extension TrialSpellingViewController {
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        print(timeTakenToSolve)
        if self.timeTakenToSolve == self.matchSpellingQuestionInfo.trial_time {
            //SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.matchSpellingQuestionInfo.completion_time + self.matchSpellingQuestionInfo.trial_time {
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
extension TrialSpellingViewController: SpeechManagerDelegate {
    
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
                self.matchSpellingViewModel.submitVerbalQuestionDetails(info: self.matchSpellingQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
                self.submitTrialMatchingAnswer(info: self.matchSpellingQuestionInfo)
            }
            break
        default:
            
            
            if(apiDataState == .imageDownloaded) {
                if self.matchSpellingQuestionInfo.prompt_detail.count > 0 {
                    apiDataState = .comandRunning
                    self.matchSpellingViewModel.setQuestionInfo(info:self.matchSpellingQuestionInfo)
                } else {
//                    self.startRec()
                    self.matchSpellingViewModel.setQuestionInfo(info:self.matchSpellingQuestionInfo)
                }
            } else if(apiDataState == .comandRunning) {
                DispatchQueue.main.async {
                    self.matchSpellingViewModel.updateCurrentCommandIndex()
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

extension TrialSpellingViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.apiDataState = .imageDownloaded
            SpeechManager.shared.speak(message: self.matchSpellingQuestionInfo.question_title+self.matchSpellingQuestionInfo.answer, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}
extension TrialSpellingViewController: NetworkRetryViewDelegate {
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

extension TrialSpellingViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}

class SpellingKeyBoardCell: UICollectionViewCell {

    @IBOutlet weak var btnKey: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

}
