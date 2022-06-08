//
//  TrialBalloonGameViewController.swift
//  Autism
//
//  Created by Dilip Technology on 27/05/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TrialBalloonGameViewController: UIViewController {

    @IBOutlet weak var speechTitle: UILabel!
    
    @IBOutlet weak var avatarCenterImageView: FLAnimatedImageView!
    @IBOutlet weak var imageView1: UIView!
    @IBOutlet weak var imageView2: UIView!
    @IBOutlet weak var imageView3: UIView!
    @IBOutlet weak var imageView4: UIView!
    
    @IBOutlet weak var imgH1: UIImageView!
    @IBOutlet weak var imgH2: UIImageView!
    @IBOutlet weak var imgH3: UIImageView!
    @IBOutlet weak var imgH4: UIImageView!
    
    @IBOutlet weak var imgB1: UIImageView!
    @IBOutlet weak var imgB2: UIImageView!
    @IBOutlet weak var imgB3: UIImageView!
    @IBOutlet weak var imgB4: UIImageView!
    
    private let balloonViewModel = TrialBalloonGameViewModel()

    private var balloonGameQuestionInfo: BalloonGameQuestionInfo!
    private weak var delegate: TrialSubmitDelegate?
    private var skipQuestion = false
    private var success_count = 0
    private var isBalloonTap = false

    private var animationIndex = 0
    let imageViewsize:CGFloat = 300

    private var animationFrameList:[CGPoint] = []
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    
    private var apiDataState: APIDataState = .notCall
    var isFromLearning:Bool = false
    private var touchOnEmptyScreenCount = 0
    private var completeRate = 0
    
    //game parameters
    private var isGame = true
    private var isGameStart = false
    private var balloonTapCount = 0
    private var timerMaxTime = 0
    private var noOfBalloonsAtTime = 4
    private var totalBalloonInGame = 0
    private var speedBreaker = 0
    
    var padding:CGFloat = 50
    var baloonWH:CGFloat = 220

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            baloonWH = 110
            padding = 25
        }

        self.listenModelClosures()
        self.customSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.balloonViewModel.stopAllCommands()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGame {
           return
        }
        guard let touch = touches.first else{return}
        let touchLocation = touch.location(in: self.view)
        for ourView in self.view.subviews{
            //guard let ourView = subs as? UIView else{return}
            if ourView.layer.presentation()!.hitTest(touchLocation) != nil{
                if ourView.tag == 1001 || ourView.tag == 1002 || ourView.tag == 1003 || ourView.tag == 1004 {
                    balloonTapCount += 1
                    ourView.isHidden = true
                    print(balloonTapCount)
                    
                    if(balloonTapCount >= 4) {
                        self.completeRate = 100
                        self.questionState = .submit
                        SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    }
                } else {
                    print("Not our view")
                    touchOnEmptyScreenCount += 1
                }
            }
        }
    }
    
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
          self.stopTimer()
          UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
            self.skipQuestion = true
            self.moveToNextQuestion()
        }
    }

    func submitTrialMatchingAnswer(info:BalloonGameQuestionInfo) {

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

// MARK: Public Methods
extension TrialBalloonGameViewController {
    func setQuestionInfo(info:BalloonGameQuestionInfo, delegate:TrialSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.balloonGameQuestionInfo = info
        self.delegate = delegate
        timerMaxTime = self.balloonGameQuestionInfo.completion_time
    }
    
    func setQuestionInfo(info:BalloonGameQuestionInfo) {
        self.apiDataState = .dataFetched
        self.balloonGameQuestionInfo = info
        timerMaxTime = self.balloonGameQuestionInfo.completion_time
    }
}

// MARK: Private Methods
extension TrialBalloonGameViewController {
    
    private func listenModelClosures() {
        
        self.balloonViewModel.dataClosure = {
          DispatchQueue.main.async {
              if let res = self.balloonViewModel.trialSubmitResponseVO {
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
  
      self.balloonViewModel.startPracticeClosure = {
          DispatchQueue.main.async {
              self.apiDataState = .comandFinished
            AutismTimer.shared.initializeTimer(delegate: self)
            self.isUserInteraction = true
            
            if(self.isGameStart == false) {
                self.startGame()
            }
          }
      }
      
        self.balloonViewModel.decreaseSpeedClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                self.speedBreaker = 10
                if(self.isGameStart == false) {
                    self.startGame()
                }
                self.balloonViewModel.updateCurrentCommandIndex()
            }
        }
                
        self.balloonViewModel.blinkImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                if(self.isGameStart == false) {
                    self.startGame()
                }
                self.blinkImage(questioninfo, count: 5)
             }
        }
     
        self.balloonViewModel.showFingerOnImage = { questioninfo in
            DispatchQueue.main.async { [self] in
                if(self.isGameStart == false) {
                    self.startGame()
                }
                self.showFingerOnImage(questioninfo, count: 5)
             }
        }
        
        self.balloonViewModel.haltScreen = { questioninfo in
            DispatchQueue.main.async { [self] in
                if(self.isGameStart == false) {
                    self.startGame()
                    self.perform(#selector(self.haltScreen(count:)), with: TimeInterval(5), afterDelay: TimeInterval(4))
                } else {
                    self.haltScreen(count: TimeInterval(10))
                }
             }
        }
        self.balloonViewModel.popBalloon = { questioninfo in
            DispatchQueue.main.async { [self] in
                if(self.isGameStart == false) {
                    self.startGame()
                    self.perform(#selector(self.popBalloon(_ :)), with: questioninfo, afterDelay: TimeInterval(5))
                } else {
                    self.popBalloon(questioninfo.value)
                }
             }
        }
    }
    
    private func blinkImage(_ questionInfo:ScriptCommandInfo, count: Int) {
        if count == 0 {
            if(questionInfo.condition.lowercased() == "no") {
                self.balloonViewModel.updateCurrentCommandIndex()
            }
            return
        }
        DispatchQueue.main.async {

            if(questionInfo.value == "first_image") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.imageView1.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.imageView1.alpha = 1.0
                    }) { [self] finished in
                        blinkImage(questionInfo, count: count - 1)
                    }
                }
            } else if(questionInfo.value == "second_image") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.imageView2.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.imageView2.alpha = 1.0
                    }) { [self] finished in
                        blinkImage(questionInfo, count: count - 1)
                    }
                }
            } else if(questionInfo.value == "third_image") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.imageView3.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.imageView3.alpha = 1.0
                    }) { [self] finished in
                        blinkImage(questionInfo, count: count - 1)
                    }
                }
            } else if(questionInfo.value == "fourth_image") {
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    self.imageView4.alpha = 0.2
                }) { [self] finished in
                    UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                        self.imageView4.alpha = 1.0
                    }) { [self] finished in
                        blinkImage(questionInfo, count: count - 1)
                    }
                }
            } else if(questionInfo.value == "") {
                self.balloonViewModel.updateCurrentCommandIndex()
            }
        }
    }
    
    
    private func showFingerOnImage(_ questionInfo:ScriptCommandInfo, count: Int) {
        if count == 0 {
            if(questionInfo.condition.lowercased() == "no") {
          //      self.balloonViewModel.updateCurrentCommandIndex()
            }
            return
        }
        DispatchQueue.main.async {
            if(questionInfo.value == "first_image") {
                self.imgH1.isHidden = false
                self.perform(#selector(self.hideImage(_:)), with: self.imgH1, afterDelay: TimeInterval(count))
            } else if(questionInfo.value == "second_image") {
                self.imgH2.isHidden = false
                self.perform(#selector(self.hideImage(_:)), with: self.imgH2, afterDelay: TimeInterval(count))
            } else if(questionInfo.value == "third_image") {
                self.imgH3.isHidden = false
                self.perform(#selector(self.hideImage(_:)), with: self.imgH3, afterDelay: TimeInterval(count))
            } else if(questionInfo.value == "fourth_image") {
                self.imgH4.isHidden = false
                self.perform(#selector(self.hideImage(_:)), with: self.imgH4, afterDelay: TimeInterval(count))
            }
        }
    }
    
    @objc private  func haltScreen(count: TimeInterval) {

        pauseLayer(layer:imageView1.layer)
        pauseLayer(layer:imageView2.layer)
        pauseLayer(layer:imageView3.layer)
        pauseLayer(layer:imageView4.layer)
        
        self.perform(#selector(self.resumeScreen), with: nil, afterDelay: TimeInterval(5))
    }
    
    @objc private func popBalloon(_ strImage:String) {

        DispatchQueue.main.async {
            
            if(strImage == "first_image") {
                self.imageView1.isHidden = true
            } else if(strImage == "second_image") {
                self.imageView2.isHidden = true
            } else if(strImage == "third_image") {
                self.imageView3.isHidden = true
            } else if(strImage == "fourth_image") {
                self.imageView4.isHidden = true
            } else {
                self.imageView3.isHidden = true
            }
        }
        self.balloonViewModel.updateCurrentCommandIndex()
    }
    
    @objc func resumeScreen() {
        resumeLayer(layer:imageView1.layer)
        resumeLayer(layer:imageView2.layer)
        resumeLayer(layer:imageView3.layer)
        resumeLayer(layer:imageView4.layer)
        
        self.balloonViewModel.updateCurrentCommandIndex()
    }

    @objc func hideImage(_ imgView:UIImageView) {
        imgView.isHidden =  true
        self.balloonViewModel.updateCurrentCommandIndex()
    }
    
    private func initializeFrame()
    {
        self.imageView1.isHidden = false
        self.imageView2.isHidden = false
        self.imageView3.isHidden = false
        self.imageView4.isHidden = false
        
        let yAxis:CGFloat = UIScreen.main.bounds.height
        
        imageView1.frame = CGRect(x:padding, y:yAxis, width:baloonWH, height:baloonWH)
        imageView2.frame = CGRect(x:(UIScreen.main.bounds.width/2) - (baloonWH), y:yAxis, width:baloonWH, height:baloonWH)
        imageView3.frame = CGRect(x:(UIScreen.main.bounds.width/2) + (baloonWH/2), y:yAxis, width:baloonWH, height:baloonWH)
        imageView4.frame = CGRect(x:UIScreen.main.bounds.width - padding - baloonWH, y:yAxis, width:baloonWH, height:baloonWH)
        
        imgH1.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgH2.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgH3.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgH4.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        
        imgB1.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgB2.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgB3.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgB4.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
  }

    private func initializeFrame1()
    {
        self.imageView1.isHidden = false
        
        let yAxis:CGFloat = UIScreen.main.bounds.height
        
        imageView1.frame = CGRect(x:padding, y:yAxis, width:baloonWH, height:baloonWH)
        imgH1.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgB1.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
  }

    private func initializeFrame2()
    {
        self.imageView2.isHidden = false

        let yAxis:CGFloat = UIScreen.main.bounds.height

        imageView2.frame = CGRect(x:(UIScreen.main.bounds.width/2) - (baloonWH), y:yAxis, width:baloonWH, height:baloonWH)
        imgH2.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgB2.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
  }

    private func initializeFrame3()
    {
        self.imageView3.isHidden = false
        
        let yAxis:CGFloat = UIScreen.main.bounds.height

        imageView3.frame = CGRect(x:(UIScreen.main.bounds.width/2) + (baloonWH/2), y:yAxis, width:baloonWH, height:baloonWH)

        imgH3.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgB3.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
  }

    private func initializeFrame4()
    {
        
        self.imageView4.isHidden = false
        
        let yAxis:CGFloat = UIScreen.main.bounds.height

        imageView4.frame = CGRect(x:UIScreen.main.bounds.width - padding - baloonWH, y:yAxis, width:baloonWH, height:baloonWH)
        imgH4.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
        imgB4.frame = CGRect(x:0 , y:0, width:baloonWH, height:baloonWH)
  }

    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

    private func startGame() {
        
        self.isGameStart = true
        print("startGame()")
        self.timerMaxTime = self.balloonGameQuestionInfo.completion_time
        self.totalBalloonInGame += noOfBalloonsAtTime
        
        UIView.animate(withDuration: TimeInterval(7+speedBreaker), delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .repeat]) { [weak self] in
        
            if let this = self {
                this.imageView1.frame = CGRect(x: this.imageView1.frame.origin.x, y: -this.imageView1.frame.height, width: this.imageView1.frame.height, height: this.imageView1.frame.height)
            }
                   
            } completion: { (isCompleted) in
            }
        
            UIView.animate(withDuration: TimeInterval(9+speedBreaker), delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .repeat]) { [weak self] in
                if let this = self {
                    this.imageView2.frame = CGRect(x: this.imageView2.frame.origin.x, y: -this.imageView2.frame.height, width: this.imageView2.frame.height, height: this.imageView2.frame.height)
                }
            } completion: { (isCompleted) in
                                        
            }
        
        UIView.animate(withDuration: TimeInterval(7+speedBreaker), delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .repeat]) { [weak self] in
            if let this = self {
                this.imageView3.frame = CGRect(x: this.imageView3.frame.origin.x, y: -this.imageView3.frame.height, width: this.imageView3.frame.height, height: this.imageView3.frame.height)
            }
            } completion: { (isCompleted) in
                    
            }
        
        UIView.animate(withDuration: TimeInterval(12+speedBreaker), delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .repeat]) { [weak self] in
            if let this = self {
                this.imageView4.frame = CGRect(x: this.imageView4.frame.origin.x, y: -this.imageView4.frame.height, width: this.imageView4.frame.height, height: this.imageView4.frame.height)
            }
        } completion: {[weak self] (isCompleted) in
            if let this = self {
                if this.timeTakenToSolve < this.timerMaxTime {
                    this.initializeFrame()
                    //this.startGame()
                } else {
                    print("balloonTapCount = \(this.balloonTapCount)")
                    print("totalBalloonInGame = \(this.totalBalloonInGame)")
                    let rate:Double = Double(this.balloonTapCount) / Double(this.totalBalloonInGame)
                    this.isGame = false

                    this.completeRate = 0
                    this.questionState = .submit
                    SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            }
        }
    }
    
    private func customSetting() {
        
        self.imgH1.isHidden = true
        self.imgH2.isHidden = true
        self.imgH3.isHidden = true
        self.imgH4.isHidden = true

        SpeechManager.shared.setDelegate(delegate: self)
        self.initializeFrame()
        self.isGame = true
        self.balloonTapCount = 0
        self.timeTakenToSolve = 0
        timerMaxTime = 0
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  getIdleGif()
        self.avatarCenterImageView.isHidden = true

        animationFrameList = [
            CGPoint.init(x: UIScreen.main.bounds.width - imageViewsize, y: (UIScreen.main.bounds.height / 2) - (imageViewsize/2)),
            CGPoint.init(x: (UIScreen.main.bounds.width/2) - (imageViewsize/2) , y: 0),
            CGPoint.init(x: 0, y: (UIScreen.main.bounds.height / 2)),
            CGPoint.init(x: (UIScreen.main.bounds.width/2) - (imageViewsize/2), y: UIScreen.main.bounds.height - imageViewsize),
        ]

        self.isUserInteraction = false
        speechTitle.text = self.balloonGameQuestionInfo.question_title
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message: self.balloonGameQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func calculateTimeTaken() {
       if !Utility.isNetworkAvailable() {
           return
       }
       self.timeTakenToSolve += 1
       trailPromptTimeForUser += 1
        
        if trailPromptTimeForUser == balloonGameQuestionInfo.trial_time && self.timeTakenToSolve < balloonGameQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.balloonGameQuestionInfo.completion_time {
            self.moveToNextQuestion()
        }
   }
    
    private func moveToNextQuestion() {
          self.stopTimer()
          self.questionState = .submit
          self.success_count = 0
          SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func stopTimer() {
        AutismTimer.shared.stopTimer()
    }
}

extension TrialBalloonGameViewController: SpeechManagerDelegate {
    
    func speechDidFinish(speechText:String) {
        self.avatarCenterImageView.isHidden = true
        self.speechTitle.isHidden = true
        
        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob {
                self.avatarCenterImageView.animatedImage =  getIdleGif()
            }
        }
        else {
            self.avatarCenterImageView.animatedImage =  getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            if(self.isFromLearning == false) {
                self.balloonViewModel.submitBalloonGameQuestionDetails(info: self.balloonGameQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
                self.submitTrialMatchingAnswer(info: self.balloonGameQuestionInfo)
            }
            break
        default:
            
            if(apiDataState == .dataFetched) {
                if self.balloonGameQuestionInfo.prompt_detail.count > 0 {
                    apiDataState = .comandRunning
                    self.balloonViewModel.setQuestionInfo(info:self.balloonGameQuestionInfo)
                } else {
                    self.balloonViewModel.setQuestionInfo(info:self.balloonGameQuestionInfo)
                }
            } else if(apiDataState == .comandRunning) {
                DispatchQueue.main.async {
                    self.balloonViewModel.updateCurrentCommandIndex()
                }
            } else if(apiDataState == .comandFinished) {

            }
            
            break
        }
    }
    
    func speechDidStart(speechText:String) {

        self.avatarCenterImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .hurrayGoodJob:
                self.avatarCenterImageView.animatedImage =  getHurrayGif()
                return
            case .wrongAnswer:
                self.avatarCenterImageView.animatedImage =  getWrongAnswerGif()
                return
            default:
                break
            }
        }
        self.avatarCenterImageView.animatedImage =  getTalkingGif()
    }
}


// MARK: Autism Timer Delegate
extension TrialBalloonGameViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}

extension TrialBalloonGameViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                
            } else if(self.apiDataState == .dataFetched) {
                
                self.apiDataState = .imageDownloaded
                SpeechManager.shared.speak(message: self.balloonGameQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}
