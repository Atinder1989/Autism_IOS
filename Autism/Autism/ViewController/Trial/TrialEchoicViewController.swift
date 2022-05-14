//
//  TrialEchoicViewController.swift
//  Autism
//
//  Created by Dilip Technology on 02/03/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TrialEchoicViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var scrlAvatar: UIScrollView!
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
        scrlAvatar.clipsToBounds = false
        self.userAnswer.isHidden = true
//        scrlAvatar.delegate = self
//        scrlAvatar.minimumZoomScale = 1.0
//        scrlAvatar.maximumZoomScale = 20.0
        
        avatarImageView.frame = scrlAvatar.bounds
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
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return avatarImageView
    }
}

// MARK: Private Methods
extension TrialEchoicViewController {
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
//                        else {
//                            self.dismiss(animated: true) {
//                                if let del = self.delegate {
//                                    del.submitQuestionResponse(response: res)
//                                }
//                            }
//                        }
                    }
                }
               }
        
        self.verbalViewModel.startPracticeClosure = {
            DispatchQueue.main.async {
                self.startRec()
                self.apiDataState = .comandFinished
                self.initializeTimer()
            }
        }
        
        self.verbalViewModel.zoomOnAvatarFaceClosure = {
            DispatchQueue.main.async {
                self.zoomAvatarFace()
            }
        }
        
        
        self.verbalViewModel.blinkTextClosure = { questionInfo in
            DispatchQueue.main.async {
                self.blinkText(questionInfo, count: 3)
            }
        }
        
        self.verbalViewModel.showTextClosure = { questionInfo in
            DispatchQueue.main.async {
                self.showText(questionInfo)
            }
        }
        
        self.verbalViewModel.childActionClosure = { questionInfo in
            DispatchQueue.main.async {
                self.childActionStart(questionInfo)
            }
        }
        
    }
    private func childActionStart(_ questionInfo:ScriptCommandInfo) {
        print("childActionStart")
        if let option = questionInfo.option {
            if(option.time_in_second != ""){
                self.timeTakenToSolve = Int(verbalQuestionInfo.trial_time) - Int(option.time_in_second)!
            }
        }
        self.verbalViewModel.updateCurrentCommandIndex()
    }
    
    private func showText(_ questionInfo:ScriptCommandInfo) {
        print("showText")
        self.userAnswer.isHidden = false
        self.userAnswer.text = questionInfo.value
        self.verbalViewModel.updateCurrentCommandIndex()
    }
    
    private func blinkText(_ questionInfo:ScriptCommandInfo, count:Int)
    {
        self.userAnswer.isHidden = false
        print("blinkText")
        var index:Int = count
        if(index == 0) {
            self.userAnswer.isHidden = true
            self.userAnswer.alpha = 1;
            return
        }
        
        self.userAnswer.alpha = 0;
        
        UIView.animate(
            withDuration: 0.5,
                delay: 0.2,
                options: [], animations: {
                    self.userAnswer.alpha = 1
                },
            completion: {_ in
                index = index-1
                self.blinkText(questionInfo, count: index)
            }
        )
    }
    
    private func zoomAvatarFace(){
        let w = scrlAvatar.bounds.size.width
        let h = scrlAvatar.bounds.size.height
                
        UIView.animate(withDuration: learningAnimationDuration-1.5, animations: {
            //self.avatarImageView.frame = CGRect(x: -1.8*w, y: -h/2.5, width: 3.6*w, height: 3.6*h)
            self.avatarImageView.frame = CGRect(x: -0.8*w, y: 0.0, width: 2.0*w, height: 2.0*h)
        })
    }
    

    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = verbalQuestionInfo.question_title

        self.apiDataState = .imageDownloaded
        SpeechManager.shared.speak(message: self.verbalQuestionInfo.question_title, uttrenceRate: 0.35)
                        
    }

   private func initializeTimer() {
    
        answerResponseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    private func moveToNextQuestion() {
        self.stopTimer()
        RecordingManager.shared.stopRecording()
        print("stopRecording = 3")
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
        print("stopRecording = 2")
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
extension TrialEchoicViewController {
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
extension TrialEchoicViewController: SpeechManagerDelegate {
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
               self.verbalViewModel.submitVerbalQuestionDetails(info: self.verbalQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
                self.submitTrialMatchingAnswer(info: self.verbalQuestionInfo)
            }
            break
        default:
            isUserInteraction = true
            
            if(apiDataState == .imageDownloaded) {
                if self.verbalQuestionInfo.prompt_detail.count > 0 {
                    apiDataState = .comandRunning
                    self.verbalViewModel.setQuestionInfo(info:self.verbalQuestionInfo)
                } else {
//                    self.startRec()
                    self.verbalViewModel.setQuestionInfo(info:self.verbalQuestionInfo)
                }
            } else if(apiDataState == .comandRunning) {
                DispatchQueue.main.async {
                    self.verbalViewModel.updateCurrentCommandIndex()
                }
            } else if(apiDataState == .comandFinished) {
                self.startRec()
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

extension TrialEchoicViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text
//        if(text != "") {
//            RecordingManager.shared.stopRecording()
//            self.checkUserAnswer(text: text)
//        } else {
//            self.startRec()
//        }
    }
    
    func recordingStart() {
    }
    
    func recordingFinish(speechText:String) {
        if(speechText != "") {
            print("stopRecording = 1")
            RecordingManager.shared.stopRecording()
            self.checkUserAnswer(text: speechText)
        } else {
            RecordingManager.shared.stopRecording()
            self.startRec()
        }
    }
     
    func checkUserAnswer(text:String) {
        if text.count > 0 {
            if Utility.sharedInstance.isAnswerMatched(text: text, answer: self.verbalQuestionInfo.answer) {
                self.questionState = .submit
                self.completeRate = 100
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: 0.35)
            } else {
                //self.userAnswer.text = ""
                let arrComponent:[String] = self.verbalQuestionInfo.answer.components(separatedBy: ",")
                if(arrComponent.count > 1) {
                    SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+arrComponent[0], uttrenceRate: 0.35)
                } else {
                    SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+self.verbalQuestionInfo.answer, uttrenceRate: 0.35)
                }
            }
        } else {
            //self.startRec()
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: 0.35)
        }
    }
    
    func startRec()
    {
        RecordingManager.shared.startRecording(delegate: self)
//        DispatchQueue.main.async {
//            print("startRec")
//            RecordingManager.shared.startRecording(delegate: self)
//        }
    }
}


extension TrialEchoicViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.apiDataState = .imageDownloaded
                                    
            SpeechManager.shared.speak(message: self.verbalQuestionInfo.question_title, uttrenceRate: 0.35)
        }
    }
}

extension TrialEchoicViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall || self.apiDataState == .dataFetched) {
                self.listenModelClosures()
                self.customSetting()
            } else {
                
            }
            SpeechManager.shared.setDelegate(delegate: self)
            self.startRec()
        }
    }
}

