//
//  AssessmentDrawingViewController.swift
//  Autism
//
//  Created by Savleen on 03/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentDrawingViewController: UIViewController {
    @IBOutlet weak var curveImageView: DrawnImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var pauseButton: UIButton!
    
    private var touchOnEmptyScreenCount = 0
    private weak var delegate: AssessmentSubmitDelegate?
    private var drawingInfo: DrawingQuestionInfo!
    private var timeTakenToSolve = 0
    private let drawingViewModel = AssesmentDrawingViewModel()
    private var isUserInteraction = false {
                      didSet {
                          self.view.isUserInteractionEnabled = isUserInteraction
                      }
    }
    private var skipQuestion = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        SpeechManager.shared.speak(message: self.drawingInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        self.drawingViewModel.uploadImage(image: self.view.asImage(), timeTaken: self.timeTakenToSolve, info: self.drawingInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           SpeechManager.shared.setDelegate(delegate: nil)
           UserManager.shared.exitAssessment()
    }
      @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
            skipQuestion = true
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            self.drawingViewModel.uploadImage(image: self.view.asImage(), timeTaken: self.timeTakenToSolve, info: self.drawingInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
        }
      }
    
}

// MARK: Public Methods
extension AssessmentDrawingViewController {
    func setDrawingQuestionInfo(info:DrawingQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.drawingInfo = info
        self.delegate = delegate
    }
}

//MARK:- Private Methods
extension AssessmentDrawingViewController {
    
    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        Utility.setView(view: self.submitButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        self.curveImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.drawingInfo.image)
        self.questionTitle.text = self.drawingInfo.question_title
        SpeechManager.shared.speak(message: self.drawingInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func listenModelClosures() {
        self.drawingViewModel.dataClosure = {
            DispatchQueue.main.async {
                if let res = self.drawingViewModel.accessmentSubmitResponseVO {
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
extension AssessmentDrawingViewController: SpeechManagerDelegate {
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

extension AssessmentDrawingViewController: PauseViewDelegate {
    func didTapOnPlay() {
        Utility.hidePauseView()
        self.pauseClicked(self.pauseButton as Any)
    }
    
    @IBAction func pauseClicked(_ sender: Any) {
        if AutismTimer.shared.isTimerRunning() {
//            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            //RecordingManager.shared.stopRecording()
            self.pauseButton.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
            Utility.showPauseView(delegate: self)
            self.isUserInteraction = true
        } else {
//            AutismTimer.shared.initializeTimer(delegate: self)
            SpeechManager.shared.setDelegate(delegate: self)
            //RecordingManager.shared.startRecording(delegate: self)
            self.pauseButton.setBackgroundImage(UIImage.init(named: "pause"), for: .normal)
        }
    }
}

extension AssessmentDrawingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}
