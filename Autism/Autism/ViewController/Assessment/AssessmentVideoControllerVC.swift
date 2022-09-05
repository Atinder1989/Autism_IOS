//
//  AssessmentVideoControllerVC.swift
//  Autism
//
//  Created by mac on 13/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage


class AssessmentVideoControllerVC: UIViewController {
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var lblTitle: UILabel!
    private weak var delegate: AssessmentSubmitDelegate?
    private let videoViewModel = AssessmentVideoViewModel()
    @IBOutlet weak var videoPreviewLayer: UIView!
    @IBOutlet weak var videoPreviewLayer1: UIView!
    @IBOutlet weak var videoPreviewLayer2: UIView!
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    @IBOutlet weak var greenTickImageview1: UIImageView!
    @IBOutlet weak var greenTickImageview2: UIImageView!
    @IBOutlet weak var greenTickImageview3: UIImageView!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    private var player1: AVPlayer!
    private var playerLayer1: AVPlayerLayer!
    
    private var player2: AVPlayer!
    private var playerLayer2: AVPlayerLayer!
    
    private var answereid = NSString()
    private var videoQuestionInfo: VideoInfo!
    
    private var selectedIndex = 0
    private var touchOnEmptyScreenCount = 0
    private var success_count = 0
    private var timeTakenToSolve = 0
    
    var isChoose:Bool = false
    private var apiDataState: APIDataState = .notCall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        self.videoplayController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
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



// MARK: Public Methods
extension AssessmentVideoControllerVC {
    func setVideoQuestionInfo(info:VideoInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.videoQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentVideoControllerVC {
   private func customSetting() {
    isUserInteraction = false
    SpeechManager.shared.setDelegate(delegate: self)
    SpeechManager.shared.speak(message:videoQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
          lblTitle.text = videoQuestionInfo.question_title
    Utility.setView(view: self.videoPreviewLayer, cornerRadius: 10, borderWidth: 2, color: .darkGray)
    Utility.setView(view: self.videoPreviewLayer1, cornerRadius: 10, borderWidth: 2, color: .darkGray)
    Utility.setView(view: self.videoPreviewLayer2, cornerRadius: 10, borderWidth: 2, color: .darkGray)
    AutismTimer.shared.initializeTimer(delegate: self)
   }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if(playerLayer != nil) {
            playerLayer.frame = videoPreviewLayer.bounds
        }
        if(playerLayer1 != nil) {
            playerLayer1.frame = videoPreviewLayer1.bounds
        }
        if(playerLayer2 != nil) {
            playerLayer2.frame = videoPreviewLayer2.bounds
        }
    }
    
   private func videoplayController() {
    let content = videoQuestionInfo.images[0]
    let content1 = videoQuestionInfo.images[1]
    let content2 = videoQuestionInfo.images[2]

   
      if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + content.image) {
           self.player = AVPlayer(url: url)
           playerLayer = AVPlayerLayer(player: player)
           playerLayer.videoGravity = .resize
        player.isMuted = true
           player.play()
           videoPreviewLayer.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: nil,
                                               queue: nil) { [weak self] note in
                                                self?.player.seek(to: CMTime.zero)
                                                self?.player.play()
        }
        
        }
    if let url1 = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + content1.image) {
       self.player1 = AVPlayer(url: url1)
       playerLayer1 = AVPlayerLayer(player: player1)
       playerLayer1.videoGravity = .resize
        player1.isMuted = true
       player1.play()
       videoPreviewLayer1.layer.addSublayer(playerLayer1)
        
       NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                     object: nil,
                                                     queue: nil) { [weak self] note in
                                                      self?.player1.seek(to: CMTime.zero)
                                                      self?.player1.play()
       }
        
    }
    
    if let url2 = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + content2.image) {
          self.player2 = AVPlayer(url: url2)
          playerLayer2 = AVPlayerLayer(player: player2)
          playerLayer2.videoGravity = .resize
        player2.isMuted = true
          player2.play()
          videoPreviewLayer2.layer.addSublayer(playerLayer2)
          NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                     object: nil,
                                                     queue: nil) { [weak self] note in
                                                      self?.player2.seek(to: CMTime.zero)
                                                      self?.player2.play()
              }
        
    }
    
    self.videoPreviewLayer.bringSubviewToFront(self.greenTickImageview1)
    self.videoPreviewLayer1.bringSubviewToFront(self.greenTickImageview2)
    self.videoPreviewLayer2.bringSubviewToFront(self.greenTickImageview3)

   }
    
    private func showCorrectAnswer(sendertag:Int) {
        let correctGreenTickTag = 100 + Int(videoQuestionInfo.correct_answer)!
        if let imageView:UIImageView = self.view.viewWithTag(correctGreenTickTag) as? UIImageView {
            let tickImageView = imageView
            tickImageView.isHidden = false
            tickImageView.image = UIImage.init(named: "greenTick")
        }
        
        let inCorrectGreenTickTag = 100 + sendertag
        if correctGreenTickTag != inCorrectGreenTickTag {
        if let imageView:UIImageView = self.view.viewWithTag(inCorrectGreenTickTag) as? UIImageView {
            let tickImageView = imageView
                   tickImageView.isHidden = false
                   tickImageView.image = UIImage.init(named: "cross")
        }
        }
        
        let correctGreenBorderTag = 1000 + Int(videoQuestionInfo.correct_answer)!
        if let parentView:UIView = self.view.viewWithTag(correctGreenBorderTag) {
            Utility.setView(view: parentView, cornerRadius: 10, borderWidth: 2, color: .greenBorderColor)
        }
        
        let inCorrectGreenBorderTag = 1000 + sendertag
        if correctGreenBorderTag != inCorrectGreenBorderTag {
        if let parentView:UIView = self.view.viewWithTag(inCorrectGreenBorderTag) {
            Utility.setView(view: parentView, cornerRadius: 10, borderWidth: 2, color: .redBorderColor)
        }
        }
        
    }
    
    @IBAction func callDone(sender: UIButton) {
        if(isChoose == true) {
            return
        }
        isChoose = true
        selectedIndex = sender.tag
        self.showCorrectAnswer(sendertag: sender.tag)
        self.questionState = .submit
        if String(format: "%d", sender.tag) == videoQuestionInfo.correct_answer {
            self.success_count = 100
            SpeechManager.shared.speak(message: self.videoQuestionInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
           else {
             self.success_count = 0
            SpeechManager.shared.speak(message: self.videoQuestionInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    private func listenModelClosures() {
       self.videoViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.videoViewModel.accessmentSubmitResponseVO {
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
}
extension AssessmentVideoControllerVC {
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
    trailPromptTimeForUser += 1

    if trailPromptTimeForUser == videoQuestionInfo.trial_time && self.timeTakenToSolve < videoQuestionInfo.completion_time
    {
        trailPromptTimeForUser = 0
        SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    } else if self.timeTakenToSolve == self.videoQuestionInfo.completion_time {
        self.moveToNextQuestion()
    }
}
    
   

func stopQuestionCompletionTimer() {
    AutismTimer.shared.stopTimer()
    
}
}

// MARK: Speech Manager Delegate Methods
extension AssessmentVideoControllerVC: SpeechManagerDelegate {
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
            self.videoViewModel.submitUserAnswer(successCount: self.success_count, info: self.videoQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, selectedIndex: selectedIndex)
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
extension AssessmentVideoControllerVC: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
//            if(self.apiDataState == .notCall) {
//                self.listenModelClosures()
//            } else if(self.apiDataState == .dataFetched) {
//                self.initializeFilledImageView()
//            } else {
//
//            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentVideoControllerVC: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
