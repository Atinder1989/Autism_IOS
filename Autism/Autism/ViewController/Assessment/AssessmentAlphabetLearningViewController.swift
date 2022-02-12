//
//  AssessmentAlphabetLearningViewController.swift
//  Autism
//
//  Created by mac on 15/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentAlphabetLearningViewController: UIViewController {
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var labelTitle: UILabel!

    private var alphabetLearningInfo: AlphabetLearningInfo!
    private let alphabetLearningViewModel = AssessmentAlphabetLearningViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var answerIndex = -1
    private var skipQuestion = false
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var initialState = true
    private var questionState: QuestionState = .inProgress
    private var isUserInteraction = false {
                didSet {
                    self.view.isUserInteractionEnabled = isUserInteraction
                }
    }
    private var touchOnEmptyScreenCount = 0
    private var selectedIndex = -1

    var isAnswered:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customSetting()
        self.listenModelClosures()
        
        answerIndex = Int(self.alphabetLearningInfo.correct_answer)!-1
        
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

extension AssessmentAlphabetLearningViewController {
    func setAlphabetLearningInfo(info:AlphabetLearningInfo,delegate:AssessmentSubmitDelegate) {
        self.alphabetLearningInfo = info
        self.delegate = delegate
    }
}

extension AssessmentAlphabetLearningViewController {
    func setSortQuestionInfo(info:AlphabetLearningInfo,delegate:AssessmentSubmitDelegate) {
        self.alphabetLearningInfo = info
        self.delegate = delegate
    }
}

extension AssessmentAlphabetLearningViewController {
    private func customSetting() {
        self.isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message:  alphabetLearningInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        labelTitle.text = alphabetLearningInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)

        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        
        var xRef:CGFloat = 100.00
                    let yRef:CGFloat = 280.0
                    let space:CGFloat = 40.0
                    
                    let widthHeight:CGFloat = 200
                    
                    let totalSpace = CGFloat(CGFloat(self.alphabetLearningInfo.option.count)*widthHeight) + CGFloat(CGFloat(self.alphabetLearningInfo.option.count-1)*space)
                    xRef = (screenWidth-totalSpace)/2.0
                    
                    for i in 0..<self.alphabetLearningInfo.option.count {
                        
                        let opt = alphabetLearningInfo.option[i]
                        
                        let btnAlphabet: AlphabetButtonView = AlphabetButtonView()
                        btnAlphabet.tag = i
                        btnAlphabet.name = opt.name
                        btnAlphabet.setTitle(opt.name, for: .normal)
                        btnAlphabet.frame = CGRect(x:xRef, y:yRef, width:widthHeight, height:widthHeight)
                        btnAlphabet.backgroundColor = .white
        //                lblAlphabet.layer.borderWidth = 5.0
        //                lblAlphabet.layer.borderColor = AppColor.purpleBorderColor.cgColor
                        btnAlphabet.layer.cornerRadius  = 30.0
                        btnAlphabet.clipsToBounds = true
                        btnAlphabet.setTitleColor(UIColor.purpleBorderColor, for: .normal)
                        
                        btnAlphabet.titleLabel!.font = UIFont.boldSystemFont(ofSize:widthHeight/2.0)
                        btnAlphabet.addTarget(self, action: #selector(btnAlphabetClicked(_ :)), for: .touchUpInside)
                        self.view.addSubview(btnAlphabet)
                        
                        xRef = xRef+widthHeight+space
                    }

    }
    @objc func btnAlphabetClicked(_ sender: AlphabetButtonView) {

        if(isAnswered == false) {
            isAnswered = true
            selectedIndex = sender.tag
            self.questionState = .submit
            if sender.tag == answerIndex {
                self.success_count = 100
                sender.showCorrectTickImage()
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.alphabetLearningInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else {
                let btnAlphabet: AlphabetButtonView = self.view.viewWithTag(answerIndex) as! AlphabetButtonView
                btnAlphabet.perform(#selector(btnAlphabet.showCorrectTickImage), with: nil, afterDelay: 1.0)
                sender.showWrongTickImage()
                self.success_count = 0
                let message = SpeechMessage.rectifyAnswer.getMessage(self.alphabetLearningInfo.incorrect_text) +  self.alphabetLearningInfo.option[answerIndex].name
                SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
        }
    }
    
    private func listenModelClosures() {
       self.alphabetLearningViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.alphabetLearningViewModel.accessmentSubmitResponseVO {
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

extension AssessmentAlphabetLearningViewController {
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
        if trailPromptTimeForUser == alphabetLearningInfo.trial_time && self.timeTakenToSolve < alphabetLearningInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.alphabetLearningInfo.completion_time {
            self.moveToNextQuestion()
        }
    }

    private func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentAlphabetLearningViewController: SpeechManagerDelegate {
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
            self.alphabetLearningViewModel.submitUserAnswer(successCount: self.success_count, info: self.alphabetLearningInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, selectedIndex: selectedIndex)
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

class AlphabetButtonView : UIButton {
    var name : String?
    let greenTickImageView:UIImageView = UIImageView()
    
    @objc func showCorrectTickImage() {
        //self.clipsToBounds = true
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.systemGreen.cgColor
        
        let wh:CGFloat = 32.0
        
        greenTickImageView.frame = CGRect(x: self.frame.size.width-wh-5, y: self.frame.size.height-wh-5, width: wh, height: wh)
        greenTickImageView.setImage(UIImage.init(named: "greenTick")!)
        greenTickImageView.contentMode = .scaleAspectFit
        greenTickImageView.backgroundColor = .clear
        self.addSubview(greenTickImageView)
    }
    
    @objc func showWrongTickImage() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.systemRed.cgColor
        
        let wh:CGFloat = 32.0
        
        greenTickImageView.frame = CGRect(x: self.frame.size.width-wh, y: self.frame.size.height-wh, width: wh, height: wh)
        greenTickImageView.contentMode = .scaleAspectFit
        greenTickImageView.setImage(UIImage.init(named: "cross")!)
        greenTickImageView.backgroundColor = .clear
        self.addSubview(greenTickImageView)
    }
}

extension AssessmentAlphabetLearningViewController: NetworkRetryViewDelegate {

    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentAlphabetLearningViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
