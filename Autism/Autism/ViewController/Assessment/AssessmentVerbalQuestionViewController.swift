//
//  AssessmentVerbalQuestionViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/01.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

protocol AssessmentSubmitDelegate:NSObject {
    func submitQuestionResponse(response:AssessmentQuestionResponseVO)
}

class AssessmentVerbalQuestionViewController: UIViewController {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var questionImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    
    private var verbalQuestionInfo: VerbalQuestionInfo!
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var verbalViewModel = AssessmentVerbalViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0

    private var isUserInteraction = false {
           didSet {
               self.view.isUserInteractionEnabled = isUserInteraction
           }
    }
    
    private var apiDataState: APIDataState = .notCall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.listenModelClosures()
        self.customSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
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
}

// MARK: Private Methods
extension AssessmentVerbalQuestionViewController {
    private func listenModelClosures() {
              self.verbalViewModel.dataClosure = {
                        DispatchQueue.main.async {
                            if let res = self.verbalViewModel.accessmentSubmitResponseVO {
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
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = verbalQuestionInfo.question_title
        
        if (self.verbalQuestionInfo.question_type == AssessmentQuestionType.verbal_actions.rawValue) {
            Utility.setView(view: self.questionImageView, cornerRadius: 0, borderWidth: 0, color: .clear)
            self.containerWidth.constant = CGFloat(900)
        } else {
            self.containerWidth.constant = CGFloat(460)
            Utility.setView(view: self.questionImageView, cornerRadius: 230, borderWidth: 2, color: .clear)
        }
        
        
        if(self.verbalQuestionInfo.image.lowercased().contains(".gif") == false) {
            ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image, imageView: self.questionImageView, callbackAfterNoofImages: 1, delegate: self)
        } else {
            ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image, imageView: self.questionImageView, callbackAfterNoofImages: 1, delegate: self)
        }
    }

   private func initializeTimer() {
    AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func moveToNextQuestion() {
        self.stopTimer()
                   RecordingManager.shared.stopRecording()
                   RecordingManager.shared.stopWaitUserAnswerTimer()
                   self.completeRate = 0
                   self.questionState = .submit
                   SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
       
    }
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        if self.timeTakenToSolve >= verbalQuestionInfo.trial_time  {
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
extension AssessmentVerbalQuestionViewController {
    func setVerbalQuestionInfo(info:VerbalQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.verbalQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentVerbalQuestionViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob {
                       self.avatarImageView.animatedImage =  idleGif
                   }
               }
        else {
                self.avatarImageView.animatedImage =  idleGif
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.stopSpeechAndRecorder()
            self.verbalViewModel.submitVerbalQuestionDetails(info: self.verbalQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            break
        default:
            isUserInteraction = true
            RecordingManager.shared.startRecording(delegate: self)
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .hurrayGoodJob:
                self.avatarImageView.animatedImage =  hurrayGif
                return
            case .wrongAnswer:
                self.avatarImageView.animatedImage =  wrongAnswerGif
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage =  talkingGif
    }
}

//MARK:- RecordingManager Delegate Methods

extension AssessmentVerbalQuestionViewController: RecordingManagerDelegate {
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
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.verbalQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else {
                self.userAnswer.text = ""
                SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(self.verbalQuestionInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
        } else {
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}


extension AssessmentVerbalQuestionViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.apiDataState = .imageDownloaded
            SpeechManager.shared.speak(message: self.verbalQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            self.initializeTimer()
        }
    }
}

extension AssessmentVerbalQuestionViewController: NetworkRetryViewDelegate {
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

extension AssessmentVerbalQuestionViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
