//
//  AssessmentMandingVdeosViewController.swift
//  Autism
//
//  Created by Dilip Technology on 23/01/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

class AssessmentMandingVdeosViewController: UIViewController {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var videoPreviewLayer: UIView!
        
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    private var videoQuestionInfo: VideoInfo!
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var mandingVideoViewModel = AssessmentMandingVideoViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0

    private var observer: Any?

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
        self.videoplayController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if(playerLayer != nil) {
            playerLayer.frame = videoPreviewLayer.bounds
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let ob = observer {
            NotificationCenter.default.removeObserver(ob)
        }
    }

    private func videoplayController() {
    
       if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + videoQuestionInfo.video_url) {
        self.player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        player.isMuted = false
           player.play()
           videoPreviewLayer.layer.addSublayer(playerLayer)
         observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: nil,
                                               queue: nil) { [weak self] note in
            
            if(self?.player != nil)
            {
                self?.player.seek(to: CMTime.zero)
                self!.player.rate = 0
                self!.apiDataState = .imageDownloaded
                SpeechManager.shared.speak(message: self!.videoQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                self?.initializeTimer()
                self?.player.pause()
                self?.player = nil
            }
            
         }
        }
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

// MARK: Public Methods
extension AssessmentMandingVdeosViewController {
    func setVideoQuestionInfo(info:VideoInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.videoQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentMandingVdeosViewController {
    private func listenModelClosures() {
              self.mandingVideoViewModel.dataClosure = {
                        DispatchQueue.main.async {
                            if let res = self.mandingVideoViewModel.accessmentSubmitResponseVO {
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
//        self.setCenterVideoFrame()
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = videoQuestionInfo.question_title
    }

    func setCenterVideoFrame() {
        let h:CGFloat = UIScreen.main.bounds.size.height-200
        let w:CGFloat = 3.0*(h/2.0)
        self.videoPreviewLayer.frame = CGRect(x: (UIScreen.main.bounds.size.width-w)/2.0, y: 120, width: w, height: h)
    }

   private func initializeTimer() {
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func moveToNextQuestion() {
        
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
        if(isUserInteraction == false) {
            return
        }
        self.timeTakenToSolve += 1
        if self.timeTakenToSolve >= videoQuestionInfo.trial_time  {
            self.stopTimer()
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


// MARK: Speech Manager Delegate Methods
extension AssessmentMandingVdeosViewController: SpeechManagerDelegate {
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
            self.mandingVideoViewModel.submitVerbalQuestionDetails(info: self.videoQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
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
extension AssessmentMandingVdeosViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text.lowercased()
    }
    
    func recordingStart() {
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.checkUserAnswer(text: speechText)
    }
     
    func checkUserAnswer(text:String) {
        if text.count > 0 {
            if Utility.sharedInstance.isAnswerMatched(text: text, answer: self.videoQuestionInfo.correct_answer) {
                self.questionState = .submit
                self.completeRate = 100
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.videoQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else {
                self.userAnswer.text = ""
                SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(self.videoQuestionInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
        } else {
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}

extension AssessmentMandingVdeosViewController: NetworkRetryViewDelegate {
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

extension AssessmentMandingVdeosViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}

