//
//  AssessmentReinforcerViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/08.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentReinforcerViewController: UIViewController {
    private var reinforcerInfo: ReinforcerInfo!
    private var nonPreferredReinforcerInfo: ReinforcerNonPreferredInfo!
    private var questionType: AssessmentQuestionType!
    private weak var delegate: AssessmentSubmitDelegate?
    private var reinforcerViewModel = AssessmentReinforceViewModel()
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    private var preferredSelection = ""
    private var selectionId = ""
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var preferredLabel: UILabel!
    @IBOutlet weak var nonPreferredLabel: UILabel!
    @IBOutlet weak var preferredImageView: UIImageView!
    @IBOutlet weak var nonPreferredImageView: UIImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    @IBOutlet weak var greenTickImageView1: UIImageView!
    @IBOutlet weak var greenTickImageView2: UIImageView!

    
    private var completeRate = 0

    var isChoose:Bool = false
    private var apiDataState: APIDataState = .notCall
    
    private var isUserInteraction = false {
          didSet {
              self.view.isUserInteractionEnabled = isUserInteraction
          }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           self.stopTimer()
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
extension AssessmentReinforcerViewController {
    func setReinforcerInfo(info:ReinforcerInfo,nonpreferredInfo:ReinforcerNonPreferredInfo,delegate:AssessmentSubmitDelegate,type:AssessmentQuestionType) {
        self.apiDataState = .dataFetched
        self.reinforcerInfo = info
        self.nonPreferredReinforcerInfo = nonpreferredInfo
        self.questionType = type
        self.delegate = delegate
    }
}


// MARK: Private Methods
extension AssessmentReinforcerViewController {

    private func moveToNextQuestion() {
        self.stopTimer()
        self.questionState = .submit
        self.completeRate = 0
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }

    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1

        if self.timeTakenToSolve >= reinforcerInfo.completion_time  {
            self.moveToNextQuestion()
        } else if trailPromptTimeForUser == reinforcerInfo.trial_time && self.timeTakenToSolve < reinforcerInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
        
    }
    
    func stopTimer() {
        AutismTimer.shared.stopTimer()

    }
    
    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = self.reinforcerInfo.questionTitle
        self.preferredLabel.text = self.reinforcerInfo.name
        Utility.setView(view: self.preferredLabel, cornerRadius: 5, borderWidth: 2, color: .white)
        Utility.setView(view: self.nonPreferredLabel, cornerRadius: 5, borderWidth: 2, color: .white)
        Utility.setView(view: self.preferredImageView, cornerRadius: 5, borderWidth: 2, color: .darkGray)
        Utility.setView(view: self.nonPreferredImageView, cornerRadius: 5, borderWidth: 2, color: .darkGray)
        ImageDownloader.sharedInstance.downloadImage(urlString: self.reinforcerInfo.image, imageView: self.preferredImageView, callbackAfterNoofImages: 2, delegate: self)
        
        self.nonPreferredLabel.text = self.nonPreferredReinforcerInfo.name
        
        ImageDownloader.sharedInstance.downloadImage(urlString: self.nonPreferredReinforcerInfo.image, imageView: self.nonPreferredImageView, callbackAfterNoofImages: 2, delegate: self)
        //self.nonPreferredImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.nonPreferredReinforcerInfo.image)
        
        let preferredTap = UITapGestureRecognizer(target: self, action: #selector(self.preferredTap(_:)))
        self.preferredImageView.addGestureRecognizer(preferredTap)
        
        let nonPreferredTap = UITapGestureRecognizer(target: self, action: #selector(self.nonPreferredTap(_:)))
        self.nonPreferredImageView.addGestureRecognizer(nonPreferredTap)
        
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    @objc func preferredTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if(isChoose == false) {
            isChoose = true
            self.isUserInteraction = false
            Utility.setView(view: self.preferredImageView, cornerRadius: 5, borderWidth: 2, color: .greenBorderColor)
            self.greenTickImageView1.isHidden = false
            self.preferredSelection = "yes"
            self.selectionId = self.reinforcerInfo.id
            self.questionState = .submit
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.reinforcerInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
        
    }
    
    @objc func nonPreferredTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if(isChoose == false) {
            isChoose = true
            self.isUserInteraction = false
            Utility.setView(view: self.nonPreferredImageView, cornerRadius: 5, borderWidth: 2, color: .greenBorderColor)
            self.greenTickImageView2.isHidden = false
            self.preferredSelection = "no"
            self.selectionId = self.nonPreferredReinforcerInfo.id
            self.questionState = .submit
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.reinforcerInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
    private func listenModelClosures() {
            self.navigationController?.navigationBar.isHidden = true
            self.reinforcerViewModel.submitClosure = {
                DispatchQueue.main.async {
                    if let res = self.reinforcerViewModel.accessmentSubmitResponseVO {
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

// MARK: Speech Manager Delegate Methods
extension AssessmentReinforcerViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob && type != .wrongAnswer {
                self.avatarImageView.animatedImage =  getIdleGif()
            }
        } else {
            completeRate = 100
                self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
            SpeechManager.shared.setDelegate(delegate: nil)
            self.stopTimer()

            if(SpeechMessage.moveForward.getMessage() == speechText) {
                self.reinforcerViewModel.submitReinforcerQuestionDetails(completeRate: 0, selection: "", preferredSelection: "", touchResponse: "no", responseTime: self.timeTakenToSolve, info: self.reinforcerInfo, type: self.questionType, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
               self.reinforcerViewModel.submitReinforcerQuestionDetails(completeRate:completeRate,selection: self.selectionId, preferredSelection: self.preferredSelection, touchResponse: "yes", responseTime: self.timeTakenToSolve, info: self.reinforcerInfo, type: self.questionType, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            }
            
            break
        default:
            self.isUserInteraction = true
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

extension AssessmentReinforcerViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
        SpeechManager.shared.speak(message:  self.reinforcerInfo.questionTitle, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}
extension AssessmentReinforcerViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                self.listenModelClosures()
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentReinforcerViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
