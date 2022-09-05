//
//  AssessmentEyeContactViewController.swift
//  Autism
//
//  Created by Savleen on 01/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import ARKit
import SceneKit
import VariousViewsEffects

class AssessmentEyeContactViewController: UIHeadGazeViewController {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var objectTimerLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var questionImageView1: UIImageView!
    @IBOutlet weak var questionImageView2: UIImageView!
    @IBOutlet weak var questionImageView3: UIImageView!
    @IBOutlet weak var questionImageView4: UIImageView!

    private var eyecontactQuestionInfo: EyeContactQuestionInfo!
    private var timeTakenToSolve = 0
    private var eyeContactViewModel = AssessmentEyeContactViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isExploding = false

    private var currentIndex = -1 {
        didSet{
            DispatchQueue.main.async {
                
            
            self.questionImageView1.isHidden = true
            self.questionImageView2.isHidden = true
            self.questionImageView3.isHidden = true
            self.questionImageView4.isHidden = true

            if self.currentIndex == 0 {
                self.questionImageView1.isHidden = false
            } else if self.currentIndex == 1 {
                self.questionImageView2.isHidden = false
            } else if self.currentIndex == 2 {
                self.questionImageView3.isHidden = false
            } else if self.currentIndex == 3 {
                self.questionImageView4.isHidden = false
            }
                SpeechManager.shared.speak(message: self.eyecontactQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

            }
        }
    }

    //Eye Tracking
//    private let eyeTrackManager = EyeTrackManager()
//    private var eyePoint = CGPoint()
//    @IBOutlet var eyeTrackSceneView: ARSCNView!
//    @IBOutlet weak var eyePositionIndicatorView: UIView!
  
    private var touchOnEmptyScreenCount = 0
    private var eyeContactOnTimer: Timer? = nil
//    private var eyeContactTimeOnObject = 0 {
//        didSet {
//            DispatchQueue.main.async {
//               // self.objectTimerLabel.text = "\(self.eyeContactTimeOnObject)"
//            }
//        }
//    }
    //private var frameIndex = 0
   // private var animationFrameArray:[CGRect] = []
    
    // Head Gaze
    private var headNode: SCNNode?
    private var gaze: UIHeadGaze?

    private var apiDataState: APIDataState = .notCall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.customSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
//        Utility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
      //  eyeTrackManager.configureFaceTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
        //  eyeTrackSceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
          self.stopTimer()
          SpeechManager.shared.setDelegate(delegate: nil)
          UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        
        if !skipQuestion {
            self.skipQuestion = true
            self.moveToNextQuestion(message: SpeechMessage.moveForward.getMessage())
        }
    }
    
    override func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        self.headNode = node
    }
    
    /// - Tag: ARFaceGeometryUpdate
    override func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        super.renderer(renderer, didUpdate: node, for: anchor)
    }
}

// MARK: Private Methods
extension AssessmentEyeContactViewController {
    private func listenModelClosures() {
              self.eyeContactViewModel.dataClosure = {
                        DispatchQueue.main.async { [weak self] in
                            if let res = self?.eyeContactViewModel.accessmentSubmitResponseVO {
                                if res.success {
                                    self?.dismiss(animated: true) {
                                        if let del = self?.delegate {
//                                            Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
                                             del.submitQuestionResponse(response: res)
                                        }
                                    }
                                }
                            }
                        }
               }
    }
    
//    private func setAnimationFrameList() {
//        self.animationFrameArray = [
//                       CGRect.init(x:10, y: 150, width: self.questionImageView.frame.width, height: self.questionImageView.frame.height),
//                       CGRect.init(x: UIScreen.main.bounds.width-self.questionImageView.frame.width, y: 150, width: self.questionImageView.frame.width, height: self.questionImageView.frame.height),
//                       CGRect.init(x: 10, y: UIScreen.main.bounds.height-self.questionImageView.frame.width, width: self.questionImageView.frame.width, height: self.questionImageView.frame.height),
//                     CGRect.init(x: UIScreen.main.bounds.width-self.questionImageView.frame.width, y: UIScreen.main.bounds.height-self.questionImageView.frame.width, width: self.questionImageView.frame.width, height: self.questionImageView.frame.height),
//               ]
//    }
    
 
    
    private func customSetting() {
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = eyecontactQuestionInfo.question_title

        if(UIDevice.current.userInterfaceIdiom == .pad) {
            Utility.setView(view: self.questionImageView1, cornerRadius: 125, borderWidth: 2, color: .darkGray)
            Utility.setView(view: self.questionImageView2, cornerRadius: 125, borderWidth: 2, color: .darkGray)
            Utility.setView(view: self.questionImageView3, cornerRadius: 125, borderWidth: 2, color: .darkGray)
            Utility.setView(view: self.questionImageView4, cornerRadius: 125, borderWidth: 2, color: .darkGray)
        } else {
            Utility.setView(view: self.questionImageView1, cornerRadius: 75, borderWidth: 0, color: .darkGray)
            Utility.setView(view: self.questionImageView2, cornerRadius: 75, borderWidth: 0, color: .darkGray)
            Utility.setView(view: self.questionImageView3, cornerRadius: 75, borderWidth: 0, color: .darkGray)
            Utility.setView(view: self.questionImageView4, cornerRadius: 75, borderWidth: 0, color: .darkGray)
        }
        
        if self.eyecontactQuestionInfo.image_count == "4" {
            ImageDownloader.sharedInstance.downloadImage(urlString: self.eyecontactQuestionInfo.image_with_text[0].image, imageView: self.questionImageView1, callbackAfterNoofImages: 4, delegate: self)
            ImageDownloader.sharedInstance.downloadImage(urlString: self.eyecontactQuestionInfo.image_with_text[1].image, imageView: self.questionImageView2, callbackAfterNoofImages: 4, delegate: self)
            ImageDownloader.sharedInstance.downloadImage(urlString: self.eyecontactQuestionInfo.image_with_text[2].image, imageView: self.questionImageView3, callbackAfterNoofImages: 4, delegate: self)
            ImageDownloader.sharedInstance.downloadImage(urlString: self.eyecontactQuestionInfo.image_with_text[3].image, imageView: self.questionImageView4, callbackAfterNoofImages: 4, delegate: self)
        }
        

        //self.setSceneViewDelegate()
        self.setUpHeadGazeTracking()
        self.view.bringSubviewToFront(self.skipButton)
        self.view.bringSubviewToFront(self.homeButton)

    }
    
    private func setUpHeadGazeTracking() {
        super.sceneview?.isHidden = true
        
        let headGazeRecognizer = UIHeadGazeRecognizer()
        super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
        headGazeRecognizer.move = { [weak self] gaze in
            if let this = self {
                this.gaze = gaze
                
                if !this.isExploding {
            if let gz = this.gaze {
                let localCursorPos = gz.location(in: this.view)
                if this.currentIndex == 0 {
                    if this.questionImageView1.frame.contains(localCursorPos) {
                        this.explodeImage(imageView: this.questionImageView1)
                    }
                } else if this.currentIndex == 1 {
                    if this.questionImageView2.frame.contains(localCursorPos) {
                        this.explodeImage(imageView: this.questionImageView2)
                    }
                } else if this.currentIndex == 2 {
                    if this.questionImageView3.frame.contains(localCursorPos) {
                        this.explodeImage(imageView: this.questionImageView3)
                    }
                } else if this.currentIndex == 3 {
                    if this.questionImageView4.frame.contains(localCursorPos) {
                        this.explodeImage(imageView: this.questionImageView4)
                    }
                }
            }
                
                }
                
                
            }
            
        }
    }
    
    private func explodeImage(imageView:UIImageView){
        self.isExploding = true
        DispatchQueue.main.async {
            imageView.explode(completion: {
                self.isExploding = false
                    let index = self.currentIndex+1
                if index == self.eyecontactQuestionInfo.image_with_text.count{
                    self.moveToNextQuestion(message: self.eyecontactQuestionInfo.correct_text)
                } else {
                    self.currentIndex = index
                }
                
            })
        }
    }

    private func moveToNextQuestion(message:String) {
        self.stopTimer()
        self.questionState = .submit
        SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    @objc private func calculateTimeTaken() {
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1
        if self.timeTakenToSolve == eyecontactQuestionInfo.completion_time  {
            self.moveToNextQuestion(message: self.eyecontactQuestionInfo.correct_text)
        } else if trailPromptTimeForUser == eyecontactQuestionInfo.trial_time && self.timeTakenToSolve < eyecontactQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
   private func stopTimer() {
    AutismTimer.shared.stopTimer()
   }
    
}


// MARK: Public Methods
extension AssessmentEyeContactViewController {
    func setEyeContactQuestionInfo(info:EyeContactQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.eyecontactQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentEyeContactViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
//        if speechText == self.eyecontactQuestionInfo.question_title {
////            if self.eyecontactQuestionInfo.moving == "Enable" {
////                self.setAnimationFrameList()
////                self.perform(#selector(self.startMovingAnimation), with: nil, afterDelay: 0.5)
////            }
//            return
//        }
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.eyeContactViewModel.submitEyecontactDetails(info: self.eyecontactQuestionInfo, timetaken: self.timeTakenToSolve, skip: self.skipQuestion,touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            break
        default:
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        
    }
}


extension AssessmentEyeContactViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
          
            self.currentIndex = 0
            
        }
    }
}

extension AssessmentEyeContactViewController: NetworkRetryViewDelegate {
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

extension AssessmentEyeContactViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
