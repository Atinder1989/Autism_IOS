//
//  AssessmentEnvironmentalSoundViewController.swift
//  Autism
//
//  Created by Savleen on 01/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentEnvironmentalSoundViewController: UIViewController {
    
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var pauseButton: UIButton!
    
    private var environmentQuestionInfo: EnvironmentalSoundQuestionInfo!
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var envSoundViewModel = AssessmentEnvironmentalSoundViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0

    private var isUserInteraction = false {
           didSet {
               self.view.isUserInteractionEnabled = isUserInteraction
           }
    }
    
    var lastSpeechResponse = ""
    
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
extension AssessmentEnvironmentalSoundViewController {
    private func listenModelClosures() {
              self.envSoundViewModel.dataClosure = {
                        DispatchQueue.main.async {
                            if let res = self.envSoundViewModel.accessmentSubmitResponseVO {
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
        
        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let screenHeight:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.height)
        var wh:CGFloat = 0.0
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            wh = 460.0
            self.questionImageView.frame = CGRect(x: (screenWidth-wh)/2.0, y: (screenHeight-wh)/2.0, width: wh, height: wh)
        } else {
            self.questionTitle.adjustsFontSizeToFitWidth = true
            wh = 240.0
            self.questionImageView.frame = CGRect(x: (screenWidth-wh)/2.0, y: (screenHeight-wh)/2.0, width: wh, height: wh)
        }
                
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        
        
        ImageDownloader.sharedInstance.downloadImage(urlString: self.environmentQuestionInfo.video_url, imageView: self.questionImageView, callbackAfterNoofImages: 1, delegate: self)
        
        if(self.environmentQuestionInfo.video_url == "") {
            self.avatarImageView.frame = questionImageView.frame
            questionImageView.isHidden = true
        } else {
            questionImageView.isHidden = false
            let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
            let screenHeight:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.height)

            if(UIDevice.current.userInterfaceIdiom == .pad) {
                self.avatarImageView.frame = CGRect(x: screenWidth-180-safeArealRight, y: screenHeight-255-safeAreaBottom, width: 180, height: 255)
            } else {
                self.avatarImageView.frame = CGRect(x: screenWidth-130-safeArealRight, y: screenHeight-200-safeAreaBottom, width: 130, height: 200)
            }
        }
    }

 
    
    private func moveToNextQuestion() {
        
        if self.timeTakenToSolve >= environmentQuestionInfo.trial_time  {
            if(skipQuestion == false && self.userAnswer.text != lastSpeechResponse && self.userAnswer.text != "") {
                self.stopTimer()
                RecordingManager.shared.stopRecording()
                RecordingManager.shared.stopWaitUserAnswerTimer()
                self.completeRate = 0
                self.questionState = .submit

                self.checkUserAnswer(text: self.userAnswer.text!)
                return
            }
        }
        
        self.stopTimer()
        RecordingManager.shared.stopRecording()
        RecordingManager.shared.stopWaitUserAnswerTimer()
        self.completeRate = 0
        self.questionState = .submit
        if let user = UserManager.shared.getUserInfo() {
            let message = SpeechMessage.moveForward.getMessage() + Utility.deCrypt(text: user.nickname)
                SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
       
    }
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        if self.timeTakenToSolve >= environmentQuestionInfo.trial_time  {
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
extension AssessmentEnvironmentalSoundViewController {
    func setIntroductionQuestionInfo(info:EnvironmentalSoundQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.environmentQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentEnvironmentalSoundViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob {
                self.avatarImageView.animatedImage =  getIdleGif()
            }
        } else {
            self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        if speechText == self.environmentQuestionInfo.question_title {
            SpeechManager.shared.speak(message: self.environmentQuestionInfo.sound_of_animal, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            return
        }
        
        if speechText == self.environmentQuestionInfo.sound_of_animal || speechText == self.environmentQuestionInfo.incorrect_text {
            self.isUserInteraction = true
            RecordingManager.shared.startRecording(delegate: self)
            AutismTimer.shared.initializeTimer(delegate: self)
            return
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.stopSpeechAndRecorder()
            self.envSoundViewModel.submitIntroductionQuestionDetails(info: self.environmentQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
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

extension AssessmentEnvironmentalSoundViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text.lowercased()
    }
    
    func recordingStart() {
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.stopTimer()
        self.checkUserAnswer(text: speechText)
    }
    
    func checkUserAnswer(text:String) {
        self.lastSpeechResponse = text
        
        if let user = UserManager.shared.getUserInfo() {
        if text.count > 0 {
            if Utility.sharedInstance.isAnswerMatched(text: text, answer: self.environmentQuestionInfo.correct_answer) {
                    self.questionState = .submit
                    self.completeRate = 100
                    SpeechManager.shared.speak(message: self.environmentQuestionInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                    self.userAnswer.text = ""
                    
                    if (self.questionState == .submit) {
                        if let user = UserManager.shared.getUserInfo() {
                            let message = SpeechMessage.moveForward.getMessage() + Utility.deCrypt(text: user.nickname)
                                SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                        }
                    } else {
                        SpeechManager.shared.speak(message: self.environmentQuestionInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    }
            }
        } else {
            SpeechManager.shared.speak(message: self.environmentQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
            
        }
    }
}

extension AssessmentEnvironmentalSoundViewController: PauseViewDelegate {
    func didTapOnPlay() {
        Utility.hidePauseView()
        self.pauseClicked(self.pauseButton as Any)
    }
    
    @IBAction func pauseClicked(_ sender: Any) {
        if AutismTimer.shared.isTimerRunning() {
            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            RecordingManager.shared.stopRecording()
            self.pauseButton.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
            Utility.showPauseView(delegate: self)
            self.isUserInteraction = true
        } else {
            AutismTimer.shared.initializeTimer(delegate: self)
            SpeechManager.shared.setDelegate(delegate: self)
            RecordingManager.shared.startRecording(delegate: self)
            self.pauseButton.setBackgroundImage(UIImage.init(named: "pause"), for: .normal)
        }
    }
}

extension AssessmentEnvironmentalSoundViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
            RecordingManager.shared.startRecording(delegate: self)
        }
    }
}

extension AssessmentEnvironmentalSoundViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}

extension AssessmentEnvironmentalSoundViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.questionTitle.text = self.environmentQuestionInfo.question_title
            SpeechManager.shared.speak(message: self.environmentQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}
