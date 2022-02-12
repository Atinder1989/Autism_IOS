//
//  TrialVerbalQuestionViewController.swift
//  Autism
//
//  Created by Dilip Technology on 28/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TrialVerbalQuestionViewController: UIViewController {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var questionImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    
    private var verbalQuestionInfo: VerbalQuestionInfo!
    private var answerResponseTimer: Timer? = nil
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var verbalViewModel = TrialVerbalViewModel()
    private weak var delegate: TrialSubmitDelegate?
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0

    private var isUserInteraction = false {
           didSet {
               self.view.isUserInteractionEnabled = isUserInteraction
           }
    }
    
    private var apiDataState: APIDataState = .notCall
    
    var isFromLearning:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.listenModelClosures()
        self.customSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func exitTrialClicked(_ sender: Any) {
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
}

// MARK: Private Methods
extension TrialVerbalQuestionViewController {
    private func listenModelClosures() {
              self.verbalViewModel.dataClosure = {
                        DispatchQueue.main.async {
                            if let res = self.verbalViewModel.trialSubmitResponseVO {
                                if res.success {
                                    self.dismiss(animated: true) {
                                        if let del = self.delegate {
                                            del.submitQuestionResponse(response: res)
                                        }
                                    }
                                }
                                else {
                                    self.dismiss(animated: true) {
                                        if let del = self.delegate {
                                            del.submitQuestionResponse(response: res)
                                        }
                                    }
                                }
                            }
                        }
               }
        
        self.verbalViewModel.startPracticeClosure = {
            DispatchQueue.main.async {
                self.apiDataState = .comandFinished
                self.initializeTimer()
            }
        }
    }
    
    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = verbalQuestionInfo.question_title
        
        if (self.verbalQuestionInfo.question_type == AssessmentQuestionType.verbal_actions.rawValue) {
            Utility.setView(view: self.questionImageView, cornerRadius: 0, borderWidth: 0, color: .darkGray)
            self.containerWidth.constant = CGFloat(900)
        } else {
            self.containerWidth.constant = CGFloat(460)
            Utility.setView(view: self.questionImageView, cornerRadius: 230, borderWidth: 4, color: .darkGray)
        }
        
        
        if(self.verbalQuestionInfo.image.lowercased().contains(".gif") == false) {
            ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image, imageView: self.questionImageView, callbackAfterNoofImages: 1, delegate: self)
        } else {
            ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image, imageView: self.questionImageView, callbackAfterNoofImages: 1, delegate: self)
        }
                
    }

   private func initializeTimer() {
    
        answerResponseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    private func moveToNextQuestion() {
        self.stopTimer()
                   RecordingManager.shared.stopRecording()
                   RecordingManager.shared.stopWaitUserAnswerTimer()
                   self.completeRate = 0
                   self.questionState = .submit
                   SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: 0.35)
       
    }
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        print("verbal timer")
        if self.timeTakenToSolve >= verbalQuestionInfo.trial_time  {
            self.moveToNextQuestion()
        }
    }
    
   private func stopTimer() {
        if let timer = self.answerResponseTimer {
            self.answerResponseTimer!.invalidate()
            answerResponseTimer = nil
        }
   }
    
    private func stopSpeechAndRecorder() {
        SpeechManager.shared.setDelegate(delegate: nil)
        RecordingManager.shared.stopRecording()
        RecordingManager.shared.stopWaitUserAnswerTimer()
    }
    
    func submitTrialMatchingAnswer(info:VerbalQuestionInfo) {
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
        
//        if let user = UserManager.shared.getUserInfo() {
//
//            let parameters: [String : Any] = [
//               ServiceParsingKeys.user_id.rawValue :user.id,
//               ServiceParsingKeys.question_type.rawValue :info.question_type,
//               ServiceParsingKeys.time_taken.rawValue :self.timeTakenToSolve,
//               ServiceParsingKeys.complete_rate.rawValue :completeRate,
//               ServiceParsingKeys.success_count.rawValue : completeRate,
//               ServiceParsingKeys.question_id.rawValue :info.id,
//               ServiceParsingKeys.language.rawValue:user.languageCode,
//               ServiceParsingKeys.req_no.rawValue:info.req_no,
//               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
//               ServiceParsingKeys.level.rawValue:info.level,
//               ServiceParsingKeys.skip.rawValue:skipQuestion,
//                ServiceParsingKeys.program_id.rawValue:info.program_id,
//
////                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
////                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
//                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount
//            ]
//            LearningManager.submitTrialMatchingAnswer(parameters: parameters)
//        }
//        }
    }
}

// MARK: Public Methods
extension TrialVerbalQuestionViewController {
    func setVerbalQuestionInfo(info:VerbalQuestionInfo,delegate:TrialSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.verbalQuestionInfo = info
        self.delegate = delegate
    }
    
    func setVerbalQuestionInfo(info:VerbalQuestionInfo) {
        self.apiDataState = .dataFetched
        self.verbalQuestionInfo = info        
    }
}

// MARK: Speech Manager Delegate Methods
extension TrialVerbalQuestionViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

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
                self.verbalViewModel.submitVerbalQuestionDetails(info: self.verbalQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
                self.submitTrialMatchingAnswer(info: self.verbalQuestionInfo)
            }
            break
        default:
            isUserInteraction = true
            //RecordingManager.shared.startRecording(delegate: self)
            
            if(apiDataState == .imageDownloaded) {
                if self.verbalQuestionInfo.prompt_detail.count > 0 {
                    apiDataState = .comandRunning
                    self.verbalViewModel.setQuestionInfo(info:self.verbalQuestionInfo)
                } else {
                    RecordingManager.shared.startRecording(delegate: self)
                }
            } else if(apiDataState == .comandRunning) {
                DispatchQueue.main.async {
                RecordingManager.shared.startRecording(delegate: self)
                self.verbalViewModel.updateCurrentCommandIndex()
                }
            } else if(apiDataState == .comandFinished) {
                RecordingManager.shared.startRecording(delegate: self)
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

//MARK:- RecordingManager Delegate Methods

extension TrialVerbalQuestionViewController: RecordingManagerDelegate {
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
        if text.count > 0 {
            if Utility.sharedInstance.isAnswerMatched(text: text, answer: self.verbalQuestionInfo.answer) {
                self.questionState = .submit
                self.completeRate = 100
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: 0.35)
            } else {
                self.userAnswer.text = ""
                SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+self.verbalQuestionInfo.answer, uttrenceRate: 0.35)
            }
        } else {
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: 0.35)
        }
    }
}


extension TrialVerbalQuestionViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.apiDataState = .imageDownloaded
                                    
            SpeechManager.shared.speak(message: self.verbalQuestionInfo.question_title, uttrenceRate: 0.35)
        }
    }
}

extension TrialVerbalQuestionViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall || self.apiDataState == .dataFetched) {
                self.listenModelClosures()
                self.customSetting()
            } else {
                
            }
            SpeechManager.shared.setDelegate(delegate: self)
            RecordingManager.shared.startRecording(delegate: self)
        }
    }
}

