//
//  AssessmentBalloonGameViewController.swift
//  Autism
//
//  Created by Savleen on 21/05/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentBalloonGameViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionTitle: UILabel!

    private let balloonViewModel = AssessmentBalloonGameViewModel()

    private var balloonGameQuestionInfo: BalloonGameQuestionInfo!
    private weak var delegate: AssessmentSubmitDelegate?
    private var skipQuestion = false
    private var success_count = 0
    private var isBalloonTap = false

    private var animationIndex = 0
    var imageViewsize:CGFloat = 300

    private var animationFrameList:[CGPoint] = []
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            imageViewsize = 150
        }
        
        self.listenModelClosures()
        self.customSetting()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{return}
        let touchLocation = touch.location(in: self.view)
        for ourView in self.view.subviews{
            //guard let ourView = subs as? UIView else{return}
            if ourView.layer.presentation()!.hitTest(touchLocation) != nil{
                if ourView.tag == 1001 {
                   // ourView.isHidden = true
                    ourView.layer.removeAllAnimations()
                    isBalloonTap = true
                    self.questionState = .submit
                    self.success_count = 100
                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.balloonGameQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                    print("Not our view")
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
            self.imageView.layer.removeAllAnimations()
            self.skipQuestion = true
            self.moveToNextQuestion()
        }
    }

}

// MARK: Public Methods
extension AssessmentBalloonGameViewController {
    func setBalloonGameQuestionInfo(info:BalloonGameQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.balloonGameQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentBalloonGameViewController {
    
    private func listenModelClosures() {
       self.balloonViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.balloonViewModel.accessmentSubmitResponseVO {
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
    
    
    private func initializeFrame()
    {
        self.imageView.isHidden = false
        let xAxis:CGFloat = (UIScreen.main.bounds.width/2) - (imageViewsize/2)
        let yAxis:CGFloat = UIScreen.main.bounds.height - imageViewsize
        imageView.frame = CGRect(x:xAxis, y:yAxis, width:imageViewsize, height:imageViewsize)
    }
    private func customSetting() {
        self.initializeFrame()
        animationFrameList = [
            CGPoint.init(x: UIScreen.main.bounds.width - imageViewsize, y: (UIScreen.main.bounds.height / 2) - (imageViewsize/2)),
            CGPoint.init(x: (UIScreen.main.bounds.width/2) - (imageViewsize/2) , y: 0),
            CGPoint.init(x: 0, y: (UIScreen.main.bounds.height / 2)),
            CGPoint.init(x: (UIScreen.main.bounds.width/2) - (imageViewsize/2), y: UIScreen.main.bounds.height - imageViewsize),
        ]

        self.isUserInteraction = false
        if self.balloonGameQuestionInfo.image_with_text.count > 0 {
            self.imageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.balloonGameQuestionInfo.image_with_text[0].image)
        }
        questionTitle.text = self.balloonGameQuestionInfo.question_title
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message: self.balloonGameQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func startAnimation(point: CGPoint) {
        UIView.animate(withDuration: 3, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) { [weak self] in
            if let this = self {
                this.imageView.frame = CGRect(x: point.x, y: point.y, width: this.imageView.frame.height, height: this.imageView.frame.height)
            }
                } completion: { [weak self]  (isCompleted) in
                    if let this = self {
                        
                        if !this.isBalloonTap {
                        this.animationIndex += 1
                        if this.animationIndex <= 3 {
                            this.startAnimation(point: this.animationFrameList[this.animationIndex])
                        } else {
                            this.animationIndex = 0
                            this.startAnimation(point: this.animationFrameList[this.animationIndex])
                        }
                        }
                        
                    }
                }
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

// MARK: Speech Manager Delegate Methods
extension AssessmentBalloonGameViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.balloonViewModel.submitUserAnswer(successCount: self.success_count, info: self.balloonGameQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion)
            break
        default:
            if speechText == self.balloonGameQuestionInfo.question_title {
                self.startAnimation(point: self.animationFrameList[animationIndex])
            }
            self.isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
    }
}


// MARK: Autism Timer Delegate
extension AssessmentBalloonGameViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
