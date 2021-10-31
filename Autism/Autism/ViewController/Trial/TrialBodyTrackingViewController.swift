//
//  TrialBodyTrackingViewController.swift
//  Autism
//
//  Created by Dilip Technology on 02/06/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import VideoToolbox
import FLAnimatedImage

//enum BodyTrackAnswerTag: Int {
//    case raiseHands = 4
//    case clapYourHands = 5
//    case waiveYourHands = 6
//    case none = 0
//}


class TrialBodyTrackingViewController: UIViewController {
    /// The view the controller uses to visualize the detected poses.
    @IBOutlet private var previewImageView: PoseImageView!
    @IBOutlet private var bodyImageView: UIImageView!

    @IBOutlet private var questionTitle: UILabel!
    
    @IBOutlet private var leftWristLabel: UILabel!
    @IBOutlet private var rightRightLabel: UILabel!
    
    @IBOutlet private var blurEffectViewBG: UIView!
    @IBOutlet weak var imgViewAvatar: FLAnimatedImageView!
    @IBOutlet weak var scrlAvatar: UIScrollView!
    
    var blurEffectView:UIVisualEffectView?
    
    private var bodyTrackingViewModel = TrialBodyTrackingViewModel()
    private weak var delegate: TrialSubmitDelegate?
    private var bodyTrackingQuestionInfo: BodyTrackingQuestionInfo!

    private var questionState: QuestionState = .inProgress
    private let videoCapture = VideoCapture()
    private var bodyTrackAnswerTag:BodyTrackAnswerTag = .none
    private var timeTakenToSolve = 0
    private var poseNet: PoseNet!
    
    private var hipPosition = CGPoint()
    private var leftWristPosition = CGPoint.init()
    private var rightWristPosition = CGPoint.init()
    private var minimumRaiseHandYAxis:CGFloat = 100
    private var maximumRaiseHandYAxis:CGFloat = 180
    private var touchOnEmptyScreenCount = 0
    private var skipQuestion = false

    private var apiDataState: APIDataState = .notCall
    var isFromLearning:Bool = false
    private var completeRate = 0

    
    private var successRate = 0 {
        didSet {
            self.stopTimer()
        }
    }

    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?

    /// The algorithm the controller uses to extract poses from the current frame.
    private var algorithm: Algorithm = .single

    /// The set of parameters passed to the pose builder when detecting poses.
    private var poseBuilderConfiguration = PoseBuilderConfiguration()

   // private var popOverPresentationManager: PopOverPresentationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.customSetting()
        // For convenience, the idle timer is disabled to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true
        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }
        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        Utility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }

    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           self.stopTimer()
           SpeechManager.shared.setDelegate(delegate: nil)
           UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
            
            let w = scrlAvatar.bounds.size.width
            let h = scrlAvatar.bounds.size.height
                    
            self.imgViewAvatar.frame = CGRect(x: 0, y: 0.0, width: w, height: h)

         self.skipQuestion = true
            self.moveToNextQuestion(message: SpeechMessage.moveForward.getMessage())
        }
    }
}


// MARK: Public Methods
extension TrialBodyTrackingViewController {
    func setQuestionInfo(info:BodyTrackingQuestionInfo,delegate:TrialSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.bodyTrackingQuestionInfo = info
        self.delegate = delegate
    }
    
    func setQuestionInfo(info:BodyTrackingQuestionInfo) {
        self.apiDataState = .dataFetched
        self.bodyTrackingQuestionInfo = info
    }
}

// MARK: Private Methods
extension TrialBodyTrackingViewController {
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }
            self.videoCapture.delegate = self
            self.videoCapture.startCapturing()
        }
    }
    
    private func handleRaiseHands(joint:Joint) {
       // print(self.bodyImageView.frame)
        if joint.isValid {
            
        if joint.name == .leftHip {
            self.hipPosition = joint.position
        }
        if joint.name == .leftWrist  {
            self.leftWristPosition = joint.position
        }
        if joint.name == .rightWrist  {
            self.rightWristPosition = joint.position
        }
        if UIDevice.current.orientation == .portrait {
            
            let deviceheight = (UIScreen.main.bounds.height / 4)
            print("deviceheight === \(deviceheight)")
            print("Right position === \(leftWristPosition.y)")
            print("left position === \(rightWristPosition.y)")

           // if hipPosition.y >= (yAxis - 150) && hipPosition.y < yAxis{
                if !SpeechManager.shared.isPlaying() {
                if (self.leftWristPosition .y >= 50 && self.leftWristPosition.y <= deviceheight) && (self.rightWristPosition .y >= 50 && self.rightWristPosition.y <= deviceheight)  {
                    print("success ===========")
                    
                    if self.questionState == .inProgress {
                    self.questionState = .submit
                    self.successRate = 100
                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.rawValue, uttrenceRate:  AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    }
                    
                }
                }
           // }
            
        }
            
            
        }

    }
    
    private func handleClapYourHands(joint:Joint) {
        if joint.isValid {
            if joint.name == .leftHip {
                self.hipPosition = joint.position
            }
            if joint.name == .leftWrist  {
                self.leftWristPosition = joint.position
            }
            if joint.name == .rightWrist  {
                self.rightWristPosition = joint.position
            }
      //  print("hip Positioin === \(hipPosition)")
            if UIDevice.current.orientation == .portrait {
                
                let deviceheight = (UIScreen.main.bounds.height / 4)
                print("deviceheight === \(deviceheight)")
                print("Right position === \(leftWristPosition.y)")
                print("left position === \(rightWristPosition.y)")

                
               // let yAxis = (UIScreen.main.bounds.height / 2)
             //   if hipPosition.y >= (yAxis - 150) && hipPosition.y < yAxis {
                    if !SpeechManager.shared.isPlaying() {
                        let difference = abs(self.leftWristPosition.x - self.rightWristPosition.x)
                        print("difference ==== \(difference)")
                        //if (difference >= 20 && difference <= 60) && ((leftWristPosition.y >= 250 && leftWristPosition.y <= 350) && (rightWristPosition.y >= 250 && rightWristPosition.y <= 350) ) {
                            
                        if difference >= 20 && difference <= 80 {
                            if self.questionState == .inProgress {
                                print("success ==========")
                                self.questionState = .submit
                                self.successRate = 100
                                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.rawValue, uttrenceRate:  AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                                                                
                            }
                        }
                    }
               // }
            }
        }
    }
    
    private func handleWaiveYourRightHand(joint:Joint) {
        if joint.isValid {
            if joint.name == .leftHip {
                self.hipPosition = joint.position
            }
            if joint.name == .leftWrist  {
                self.leftWristPosition = joint.position
            }
            if joint.name == .rightWrist  {
                self.rightWristPosition = joint.position
            }
        print("hip Positioin === \(hipPosition)")
            if UIDevice.current.orientation == .portrait {
                
                let deviceheight = (UIScreen.main.bounds.height / 4)
                print("deviceheight === \(deviceheight)")
                print("Right position === \(leftWristPosition.y)")
                print("left position === \(rightWristPosition.y)")

                
               // let yAxis = (UIScreen.main.bounds.height / 2)
               // if hipPosition.y >= (yAxis - 150) && hipPosition.y < yAxis {
                    print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                    if !SpeechManager.shared.isPlaying() {
                        //if self.videoCapture.cameraPostion == .front {
                          //  if (self.leftWristPosition.x > 300 && self.leftWristPosition.x < 500 ) && (self.leftWristPosition.y > 100 && self.leftWristPosition.y < 500)
                            
                            if (self.leftWristPosition .y >= 50 && self.leftWristPosition.y <= deviceheight)
                            
                            {
                                self.submitSuccessForWaiveHands()
                                
                            }
                       // }
//                            else {
//                            if (self.rightWristPosition.x > 300 && self.rightWristPosition.x < 500 ) && (self.rightWristPosition.y > 100 && self.rightWristPosition.y < 500) {
//                               print("success")
//                                self.submitSuccessForWaiveHands()
//                            }
                      //  }
                    }
                //}
            }
        }
        
    }
    
    private func submitSuccessForWaiveHands() {
        if self.questionState == .inProgress {
            self.questionState = .submit
            self.successRate = 100
            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.rawValue, uttrenceRate:  AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
    
        
    private func listenModelClosures() {
        
        self.bodyTrackingViewModel.dataClosure = {
          DispatchQueue.main.async {
              if let res = self.bodyTrackingViewModel.trialSubmitResponseVO {
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
        
        self.bodyTrackingViewModel.startPracticeClosure = {
            DispatchQueue.main.async {
                self.apiDataState = .comandFinished
              AutismTimer.shared.initializeTimer(delegate: self)
                //self.imgViewAvatar.animatedImage =  hurrayGif
//              self.isUserInteraction = true
            }
        }
        
            self.bodyTrackingViewModel.avatar = { questioninfo in
                DispatchQueue.main.async { [self] in
                    self.avatarAnimation(questioninfo)
                 }
            }
            self.bodyTrackingViewModel.zommOnAvatar = { questioninfo in
                DispatchQueue.main.async { [self] in
                    self.zoomOnAvatar(questioninfo)
                 }
            }
       }
    
    private func zoomOnAvatar(_ questionInfo:ScriptCommandInfo) {
        DispatchQueue.main.async { [self] in

            if(questionInfo.option!.background == "blur") {
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView!.effect = blurEffect
                blurEffectView!.frame = view.bounds
                blurEffectView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.blurEffectViewBG.addSubview(blurEffectView!)
                self.blurEffectViewBG.bringSubviewToFront(self.scrlAvatar)
            }
            
            if(questionInfo.option!.zoom_on == "face") {
                        
                self.imgViewAvatar.isHidden = false
                
                let w = scrlAvatar.bounds.size.width
                let h = scrlAvatar.bounds.size.height

                UIView.animate(withDuration: 1, animations: {
                    self.imgViewAvatar.frame = CGRect(x: -0.5*w, y: 0.0, width: 2.0*w, height: 2.0*h)
                }) { [self] finished in
                    
                    if(questionInfo.option!.time_in_second != "") {
                        self.perform(#selector(self.hideImage(_:)), with: self.imgViewAvatar, afterDelay: TimeInterval(Int(questionInfo.option!.time_in_second)!))
                    } else {
                        self.perform(#selector(self.hideImage(_:)), with: self.imgViewAvatar, afterDelay: TimeInterval(1))
                    }
                }
                
            } else if(questionInfo.option!.zoom_on == "hand") {
                self.imgViewAvatar.isHidden = false
                
                let w = scrlAvatar.bounds.size.width
                let h = scrlAvatar.bounds.size.height
                        
                UIView.animate(withDuration: 1, animations: {
                    self.imgViewAvatar.frame = CGRect(x: -0.5*w, y: 0.0, width: 2.0*w, height: 2.0*h)
                }) { [self] finished in
                    
                    if(questionInfo.option!.time_in_second != "") {
                        self.perform(#selector(self.hideImage(_:)), with: self.imgViewAvatar, afterDelay: TimeInterval(Int(questionInfo.option!.time_in_second)!))
                    } else {
                        self.perform(#selector(self.hideImage(_:)), with: self.imgViewAvatar, afterDelay: TimeInterval(1))
                    }
                }
            }
        }
    }
    
    private func avatarAnimation(_ questionInfo:ScriptCommandInfo) {
        
        
        DispatchQueue.main.async { [self] in

            if(questionInfo.option!.avatar_variation == "show_avatar") {
                self.imgViewAvatar.isHidden = false
                if(questionInfo.option!.time_in_second != "") {
                    self.perform(#selector(self.hideImage(_:)), with: self.imgViewAvatar, afterDelay: TimeInterval(Int(questionInfo.option!.time_in_second)!))
                } else {
                    self.bodyTrackingViewModel.updateCurrentCommandIndex()
                }
            } else {
                self.bodyTrackingViewModel.updateCurrentCommandIndex()
            }
        }
    }
    
    @objc func hideImage(_ imgView:UIImageView) {
        imgView.isHidden =  true
        self.bodyTrackingViewModel.updateCurrentCommandIndex()
        if(blurEffectView?.superview != nil) {
            blurEffectView!.removeFromSuperview()
        }
    }
    
    func nkjkj()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.effect = blurEffect
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)

    }
    
    private func customSetting() {
        
        imgViewAvatar.frame = scrlAvatar.bounds
        
        if(self.bodyTrackingQuestionInfo.correct_answer == "4") {
            self.imgViewAvatar.animatedImage =  raiseHandGif
        } else {
            self.imgViewAvatar.animatedImage =  talkingGif
        }
        
        self.imgViewAvatar.isHidden = true
        
        self.questionTitle.text = self.bodyTrackingQuestionInfo.question_title
        
          SpeechManager.shared.setDelegate(delegate: self)
          SpeechManager.shared.speak(message: self.bodyTrackingQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
          if let answer = Int(self.bodyTrackingQuestionInfo.correct_answer) {
              self.bodyTrackAnswerTag = BodyTrackAnswerTag.init(rawValue: answer)!
          }
        AutismTimer.shared.initializeTimer(delegate: self)
    }
         
         
    private func moveToNextQuestion(message:String) {
        self.successRate = 0
        self.stopTimer()
        self.questionState = .submit
        self.imgViewAvatar.animatedImage =  talkingGif
        SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
         
         @objc private func calculateTimeTaken() {
           self.timeTakenToSolve += 1
           trailPromptTimeForUser += 1

          if self.timeTakenToSolve >= self.bodyTrackingQuestionInfo.completion_time  {
            self.moveToNextQuestion(message: SpeechMessage.moveForward.getMessage())
              return
          }
            if trailPromptTimeForUser == bodyTrackingQuestionInfo.trial_time && self.timeTakenToSolve < bodyTrackingQuestionInfo.completion_time {
                trailPromptTimeForUser = 0
              SpeechManager.shared.speak(message: self.bodyTrackingQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
          }
          
         }
         
        private func stopTimer() {
            AutismTimer.shared.stopTimer()
        }
}


// MARK: - VideoCaptureDelegate

extension TrialBodyTrackingViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        poseNet.predict(image)
    }
}

// MARK: - PoseNetDelegate

extension TrialBodyTrackingViewController: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }

        guard let currentFrame = currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let poses = algorithm == .single
            ? [poseBuilder.pose]
            : poseBuilder.poses
        
        DispatchQueue.main.async {
            if self.questionState == .inProgress {
                for pose in poses {
                    for joint in pose.joints.values {
                    if self.bodyTrackAnswerTag == .raiseHands {
                        self.handleRaiseHands(joint: joint)
                    } else if self.bodyTrackAnswerTag == .clapYourHands {
                        self.handleClapYourHands(joint: joint)
                    } else if self.bodyTrackAnswerTag == .waiveYourHands {
                        self.handleWaiveYourRightHand(joint: joint)
                    }
                  }
                }
            }
            self.previewImageView.show(poses: poses, on: currentFrame)
        }
    }
    
    func submitTrialMatchingAnswer(info:BodyTrackingQuestionInfo) {
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
    }

}

// MARK: Speech Manager Delegate Methods
extension TrialBodyTrackingViewController: SpeechManagerDelegate
{
    
    func speechDidFinish(speechText:String)
    {
        self.perform(#selector(self.hideImage(_:)), with: self.imgViewAvatar, afterDelay: 1)

        self.imgViewAvatar.isHidden = true
        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob {
                self.imgViewAvatar.animatedImage =  idleGif
            }
        }
        else {
            if(self.bodyTrackingQuestionInfo.correct_answer == "4") {
                self.imgViewAvatar.animatedImage =  raiseHandGif
            } else {
                self.imgViewAvatar.animatedImage =  idleGif
            }
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
//            self.stopSpeechAndRecorder()
            if(self.isFromLearning == false) {
                self.bodyTrackingViewModel.submitFaceTrackDetails(info: self.bodyTrackingQuestionInfo, completeRate: completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
//                self.bodyTrackingViewModel.submitBalloonGameQuestionDetails(info: self.balloonGameQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
                self.submitTrialMatchingAnswer(info: self.bodyTrackingQuestionInfo)
            }
            break
        default:
            
            if(apiDataState == .dataFetched) {
                if self.bodyTrackingQuestionInfo.prompt_detail.count > 0 {
                    apiDataState = .comandRunning
                    self.bodyTrackingViewModel.setQuestionInfo(info:self.bodyTrackingQuestionInfo)
                } else {
//                    self.startRec()
                    self.bodyTrackingViewModel.setQuestionInfo(info:self.bodyTrackingQuestionInfo)
                }
            } else if(apiDataState == .comandRunning) {
                DispatchQueue.main.async {
                    self.bodyTrackingViewModel.updateCurrentCommandIndex()
                }
            } else if(apiDataState == .comandFinished) {
                //self.startRec()
            }
            
            break
        }
    }

    func speechDidStart(speechText:String) {
        self.imgViewAvatar.isHidden = false
    }
}

extension TrialBodyTrackingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension TrialBodyTrackingViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
