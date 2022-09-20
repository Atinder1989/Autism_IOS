//
//  AssessmentPictureSceneViewController.swift
//  Autism
//
//  Created by Dilip Saket on 12/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentPictureSceneViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var pauseButton: UIButton!

    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnSkip: UIButton!

    private var pictureSceneInfo:PictureSceneInfo!
    private let pictureSceneViewModel = AssessmentPictureScenceViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var skipQuestion = false
    private var answerIndex = -1
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var initialState = true
    private var questionState: QuestionState = .inProgress
    private var initialFrame: CGRect?
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    private var touchOnEmptyScreenCount = 0
    
    var w:CGFloat = 100*1.22
    var h:CGFloat = 100

    var x:CGFloat = 0.0
    var y:CGFloat = 0.0

    var viewSceneCorrect:PictureSceneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
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

extension AssessmentPictureSceneViewController {
    func setPictureSceneInfo(info:PictureSceneInfo,delegate:AssessmentSubmitDelegate) {
        self.pictureSceneInfo = info
        self.delegate = delegate
    }
}

extension AssessmentPictureSceneViewController {
    private func customSetting() {
        self.isUserInteraction = false
        self.labelTitle.text = self.pictureSceneInfo.question_title

        let space:CGFloat = 0.0

        var matrixOf:CGFloat = 4

        if(self.pictureSceneInfo.image_with_text.count == 4) {
            matrixOf = 2
        } else if(self.pictureSceneInfo.image_with_text.count == 9) {
            matrixOf = 3
        }

        let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let screenHeight:CGFloat = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        
        let screenW4:CGFloat = screenWidth/matrixOf
        let screenH4:CGFloat = screenHeight/matrixOf
        
        var cW:CGFloat = 100*1.22
        var cH:CGFloat = 100

        var xRef:CGFloat = 100.0
        var yRef:CGFloat = 220.0

        if(((screenH4*1.22)*matrixOf) > screenWidth) {
            cW = screenW4
            cH = screenW4*0.45
        } else {
            cH = screenH4
            cW = screenH4*2.22
        }

        xRef = (screenWidth-(cW*matrixOf))/2.0
        yRef = (screenHeight-(cH*matrixOf))/2.0
                
        self.x = xRef
        self.y = yRef
        self.w = cW
        self.h = cH

        var index:Int = 0

        for i in 0..<Int(matrixOf) {

            for j in 0..<Int(matrixOf) {

                let iModel:ImageModel = self.pictureSceneInfo.image_with_text[index]

                let viewScene = PictureSceneView()
                viewScene.iModel = iModel
                viewScene.tag = index
                viewScene.frame =  CGRect(x:xRef, y: yRef, width: cW, height: cH)
                viewScene.tag = Int(i*Int(matrixOf))+j
                viewScene.backgroundColor = .white
                viewScene.clipsToBounds = true
                self.view.addSubview(viewScene)

                if(iModel.isCorrectAnswer == true) {
                    self.viewSceneCorrect = viewScene
                }
                
                let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + iModel.image
                viewScene.setImageWith(urlString: urlString)

                xRef = xRef+space+cW

                index = index+1
            }
            xRef = (screenWidth-(cW*4.0))/2.0
            yRef = yRef+cH+space
        }

        self.view.bringSubviewToFront(self.viewSceneCorrect)
        self.view.bringSubviewToFront(self.labelTitle)
        self.view.bringSubviewToFront(self.pauseButton)
        self.view.bringSubviewToFront(self.btnHome)
        self.view.bringSubviewToFront(self.btnSkip)

        
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message:  pictureSceneInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        labelTitle.text = pictureSceneInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(touchOnEmptyScreenCount > 0) {
            return
        }

        if let touch = touches.first {
            let position = touch.location(in: view)
            print(position)
            if(viewSceneCorrect != nil) {
                touchOnEmptyScreenCount += 1
                if(self.viewSceneCorrect!.frame.contains(position)) {
                    self.success_count = 100
                    self.questionState = .submit
                    SpeechManager.shared.speak(message: self.pictureSceneInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                } else {
                    self.success_count = 0
                    self.questionState = .submit
                    self.animateTheRightImage(imageView: self.viewSceneCorrect)
                }
            }
        }
    }

    @objc func animateTheRightImage(imageView:PictureSceneView) {
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(imageView)
            let scaleSize:CGFloat = 1.5
            
            let animationDuration:TimeInterval = 3
            UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                // SCALE
                imageView.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize) // Scale your image
            }) { [self] (finished) in
                UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    // NORMAL
                    imageView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image
                }) { (finished) in
                    self.perform(#selector(self.incorrectTextSpeechSubmit), with: nil, afterDelay: 1)
                }
            }
        }
    }
            
    @objc func incorrectTextSpeechSubmit() {
        SpeechManager.shared.speak(message: self.pictureSceneInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }

    private func listenModelClosures() {
       self.pictureSceneViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.pictureSceneViewModel.accessmentSubmitResponseVO {
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

extension AssessmentPictureSceneViewController {
   
    @objc private func calculateTimeTaken() {
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1
        if trailPromptTimeForUser == pictureSceneInfo.trial_time && self.timeTakenToSolve < pictureSceneInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.pictureSceneInfo.completion_time  {
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
extension AssessmentPictureSceneViewController: SpeechManagerDelegate {
    
    
    func speechDidFinish(speechText: String) {

        switch self.questionState {
        case .submit:
            let imagesCount:Int = self.pictureSceneInfo.image_with_text.count
            if(self.success_count == imagesCount) {
                self.success_count = 100
            } else {
                let perPer = 100/imagesCount
                self.success_count = self.success_count*perPer
            }
            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
          
            self.pictureSceneViewModel.submitUserAnswer(info: self.pictureSceneInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, successCount: self.success_count)
            break
        default:
            self.isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false

    }
}

class PictureSceneView : UIImageView {
    var iModel : ImageModel?
}

extension AssessmentPictureSceneViewController: PauseViewDelegate {
    func didTapOnPlay() {
        Utility.hidePauseView()
        self.pauseClicked(self.pauseButton as Any)
    }
    
    @IBAction func pauseClicked(_ sender: Any) {
        if AutismTimer.shared.isTimerRunning() {
            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            //RecordingManager.shared.stopRecording()
            self.pauseButton.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
            Utility.showPauseView(delegate: self)
            self.isUserInteraction = true
        } else {
            AutismTimer.shared.initializeTimer(delegate: self)
            SpeechManager.shared.setDelegate(delegate: self)
            //RecordingManager.shared.startRecording(delegate: self)
            self.pauseButton.setBackgroundImage(UIImage.init(named: "pause"), for: .normal)
        }
    }


}

extension AssessmentPictureSceneViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentPictureSceneViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
