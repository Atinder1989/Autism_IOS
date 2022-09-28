//
//  AssessmentWritingOnPadController.swift
//  Autism
//
//  Created by Singh, Atinderpal on 28/08/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentWritingOnPadController: UIViewController {
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var curveImageView: DrawnImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var pauseButton: UIButton!


    private var touchOnEmptyScreenCount = 0
    private weak var delegate: AssessmentSubmitDelegate?
    private var writingPadInfo: WritingOnPadInfo!
    private var timeTakenToSolve = 0
    private let writingViewModel = AssesmentWritingOnPadViewModel()
    private var isUserInteraction = false {
        didSet {
            self.view.isUserInteractionEnabled = isUserInteraction
        }
    }
    private var skipQuestion = false

    var isPaused = false
    var answerGiven = false
    var answerState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        //self.writingViewModel.uploadImage(image: self.curveImageView.asImage(), timeTaken: self.timeTakenToSolve, info: self.writingPadInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
        
        self.writingViewModel.uploadImage(image: self.curveImageView.asImage(), timeTaken: self.timeTakenToSolve, info: self.writingPadInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, completetionBlock: {(state) in
            
            self.answerGiven = true
            self.answerState = state
            if state {
                SpeechManager.shared.speak(message: self.writingPadInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else {
                SpeechManager.shared.speak(message: self.writingPadInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }

            //self.submitUserAnswer(info: info, timeTaken: timeTaken, skip: skip, touchOnEmptyScreenCount: touchOnEmptyScreenCount, request: responseVo.result)
            
        })
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           SpeechManager.shared.setDelegate(delegate: nil)
           UserManager.shared.exitAssessment()
    }
      @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
            skipQuestion = true

            self.writingViewModel.uploadImage(image: self.curveImageView.asImage(), timeTaken: self.timeTakenToSolve, info: self.writingPadInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, completetionBlock: {(state) in
                
                self.answerGiven = true
                self.answerState = false
                if self.answerState {
                    SpeechManager.shared.speak(message: self.writingPadInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                    SpeechManager.shared.speak(message: self.writingPadInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            })

            //self.writingViewModel.uploadImage(image: self.curveImageView.asImage(), timeTaken: self.timeTakenToSolve, info: self.writingPadInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
        }
      }
    
}

// MARK: Public Methods
extension AssessmentWritingOnPadController {
    func setWritingOnPadInfo(info:WritingOnPadInfo,delegate:AssessmentSubmitDelegate) {
        self.writingPadInfo = info
        self.delegate = delegate
    }
}

//MARK:- Private Methods
extension AssessmentWritingOnPadController {
    
    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        Utility.setView(view: self.submitButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        if self.writingPadInfo.image_with_text.count > 0 {
            self.questionImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.writingPadInfo.image_with_text[0].image)
        }
        
        self.questionTitle.text = self.writingPadInfo.question_title
        SpeechManager.shared.speak(message: self.writingPadInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func listenModelClosures() {
        self.writingViewModel.speechClosure = { state in
            DispatchQueue.main.async {
                if state {
                    SpeechManager.shared.speak(message: self.writingPadInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                    SpeechManager.shared.speak(message: self.writingPadInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            }
        }

        self.writingViewModel.dataClosure = {
            DispatchQueue.main.async {
                if let res = self.writingViewModel.accessmentSubmitResponseVO {
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
extension AssessmentWritingOnPadController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .excellentWork {
                self.avatarImageView.animatedImage =  getIdleGif()
            }
        } else {
                self.avatarImageView.animatedImage =  getIdleGif()
        }
        isUserInteraction = true
        
        if(self.answerGiven == true) {
            //self.writingViewModel.uploadImage(image: self.curveImageView.asImage(), timeTaken: self.timeTakenToSolve, info: self.writingPadInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            
            self.writingViewModel.submitUserAnswer(info: self.writingPadInfo, timeTaken: self.timeTakenToSolve, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, request: self.answerState)
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .excellentWork:
                self.avatarImageView.animatedImage =  getExcellentGif()
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage =  getTalkingGif()
    }
}

extension AssessmentWritingOnPadController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentWritingOnPadController: PauseViewDelegate {
    func didTapOnPlay() {
        Utility.hidePauseView()
        self.pauseClicked(self.pauseButton as Any)
    }
    
    @IBAction func pauseClicked(_ sender: Any) {
        if isPaused == false {
            isPaused = true
            //self.stopTimer()
            //RecordingManager.shared.stopRecording()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.pauseButton.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
            Utility.showPauseView(delegate: self)
            self.isUserInteraction = true
        } else {
            isPaused = false
            //AutismTimer.shared.initializeTimer(delegate: self)
            //RecordingManager.shared.startRecording(delegate: self)
            SpeechManager.shared.setDelegate(delegate: self)
            self.pauseButton.setBackgroundImage(UIImage.init(named: "pause"), for: .normal)
        }
    }
}

