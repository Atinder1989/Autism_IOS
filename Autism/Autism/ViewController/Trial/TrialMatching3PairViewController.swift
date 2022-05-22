//
//  TrialMatching3PairViewController.swift
//  Autism
//
//  Created by Dilip Technology on 09/04/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TrialMatching3PairViewController: UIViewController {
    
    private var matchingObjectInfo: MatchingObjectInfo!
    private let matchingObjectViewModel = TrialMatchingObjectViewModel()
    private weak var delegate: TrialSubmitDelegate?
    private var isDragCompletedCount = 0
    private var isDragCompleted = false {
        didSet {
            if isDragCompleted {
                DispatchQueue.main.async { [self] in
                    self.view.isUserInteractionEnabled = false
                    self.questionState = .submit
                    self.success_count = 100
                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            }
        }
    }
    private var isDragStarted = false
    private var initialRightImageViewFrame1: CGRect = CGRect.init()
    private var initialRightImageViewFrame2: CGRect = CGRect.init()
    private var initialRightImageViewFrame3: CGRect = CGRect.init()
    
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var avatarCenterImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarBottomImageView: FLAnimatedImageView!

    @IBOutlet weak var commandImgViewLeft1: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRight1: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRightCopy1: ScriptCommandImageView!
    @IBOutlet weak var imgViewFinger1: UIImageView!
    @IBOutlet weak var dragAnimationView1: UIView!

    @IBOutlet weak var commandImgViewLeft2: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRight2: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRightCopy2: ScriptCommandImageView!
    @IBOutlet weak var imgViewFinger2: UIImageView!
    @IBOutlet weak var dragAnimationView2: UIView!
    
    @IBOutlet weak var commandImgViewLeft3: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRight3: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRightCopy3: ScriptCommandImageView!
    @IBOutlet weak var imgViewFinger3: UIImageView!
    @IBOutlet weak var dragAnimationView3: UIView!

    private var answerIndex = -1
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionCompletionTimer: Timer? = nil
    private var initialState = true
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
        
    private var apiDataState: APIDataState = .notCall
    private var touchOnEmptyScreenCount = 0

    var isFromLearning:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.customSetting()
        self.addGesture()
        self.listenModelClosures()
//        self.commandViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
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
    
extension TrialMatching3PairViewController {
    
    func initializeFrame() {
    
        var wh:CGFloat = 180
        var yRef:CGFloat = 180
        var ySpace:CGFloat = 40
        let xSpace:CGFloat = 60
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            yRef = 80
            wh = 70
            ySpace = 10
        }
        commandImgViewLeft3.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        initialRightImageViewFrame3 = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)

        commandImgViewRight3.frame = initialRightImageViewFrame3
        dragAnimationView3.frame = initialRightImageViewFrame3

        yRef = yRef+wh+ySpace
        
        commandImgViewLeft1.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        initialRightImageViewFrame1 = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)

        commandImgViewRight1.frame = initialRightImageViewFrame1
        dragAnimationView1.frame = initialRightImageViewFrame1

        yRef = yRef+wh+ySpace
        
        commandImgViewLeft2.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        initialRightImageViewFrame2 = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)

        commandImgViewRight2.frame = initialRightImageViewFrame2
        dragAnimationView2.frame = initialRightImageViewFrame2

        yRef = yRef+wh+ySpace
    }
    
//    private func initializeFrame()
//    {
//        let tW:CGFloat = UIScreen.main.bounds.width
//        let tH:CGFloat = UIScreen.main.bounds.height
//        let topSpace:CGFloat = 140
//        let imgWH:CGFloat = 180
//        let ySpace:CGFloat = (tH-topSpace-(3*imgWH))/3
//
//        var yRef:CGFloat = topSpace
//
//        commandImgViewLeft1.frame = CGRect(x:50, y:yRef, width:imgWH, height:imgWH)
//        initialRightImageViewFrame1 = CGRect(x:tW-imgWH-50, y:yRef, width:imgWH, height:imgWH)
//        commandImgViewRight1.frame = initialRightImageViewFrame1
//        dragAnimationView1.frame = initialRightImageViewFrame1
//
//        yRef = yRef+imgWH+ySpace
//
//        commandImgViewLeft2.frame = CGRect(x:50, y:yRef, width:imgWH, height:imgWH)
//        initialRightImageViewFrame2 = CGRect(x:tW-imgWH-50, y:yRef, width:imgWH, height:imgWH)
//        commandImgViewRight2.frame = initialRightImageViewFrame2
//        dragAnimationView2.frame = initialRightImageViewFrame2
//
//        yRef = yRef+imgWH+ySpace
//
//        commandImgViewLeft3.frame = CGRect(x:50, y:yRef, width:imgWH, height:imgWH)
//        initialRightImageViewFrame3 = CGRect(x:tW-imgWH-50, y:yRef, width:imgWH, height:imgWH)
//        commandImgViewRight3.frame = initialRightImageViewFrame3
//        dragAnimationView3.frame = initialRightImageViewFrame3
//
//
////        commandImgViewLeft.frame = CGRect(x:50, y:(topSpace)/2.0, width:imgWH, height:imgWH)
////        initialRightImageViewFrame1 = CGRect(x:tW-imgWH-50, y:(tH-imgWH)/2.0, width:imgWH, height:imgWH)
////        commandImgViewRight.frame = initialRightImageViewFrame
////        dragAnimationView.frame = initialRightImageViewFrame
//    }
    
    private func customSetting() {
        self.initializeFrame()
        self.isDragCompleted = false
        self.isDragStarted = false
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  getIdleGif()
        self.avatarCenterImageView.isHidden = true
        self.avatarBottomImageView.isHidden = true
        self.view.isUserInteractionEnabled = false

        //Image 1
        self.commandImgViewLeft1.isHidden = true
        self.commandImgViewRight1.isHidden = true
        self.dragAnimationView1.isHidden = true
        self.commandImgViewLeft1.image = nil
        self.commandImgViewRight1.image = nil
        Utility.setView(view: self.commandImgViewLeft1, cornerRadius: 0, borderWidth: 0, color: .clear)
        
        //Image 2
        self.commandImgViewLeft2.isHidden = true
        self.commandImgViewRight2.isHidden = true
        self.dragAnimationView2.isHidden = true
        self.commandImgViewLeft2.image = nil
        self.commandImgViewRight2.image = nil
        Utility.setView(view: self.commandImgViewLeft2, cornerRadius: 0, borderWidth: 0, color: .clear)
        
        //Image 3
        self.commandImgViewLeft3.isHidden = true
        self.commandImgViewRight3.isHidden = true
        self.dragAnimationView3.isHidden = true
        self.commandImgViewLeft3.image = nil
        self.commandImgViewRight3.image = nil
        Utility.setView(view: self.commandImgViewLeft3, cornerRadius: 0, borderWidth: 0, color: .clear)
        
        speechTitle.text = matchingObjectInfo.question_title

        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message:  matchingObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        
        if self.matchingObjectInfo.prompt_detail.count > 0 {
            self.matchingObjectViewModel.setQuestionInfo(info:matchingObjectInfo)
        }
        
        //Image 1
        let url1 = ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[0].image

        self.commandImgViewLeft1.isHidden = false
        self.commandImgViewLeft1.setImageWith(urlString: url1)

        self.commandImgViewRight1.isHidden = false
        self.commandImgViewRight1.setImageWith(urlString: url1)
        self.commandImgViewRightCopy1.setImageWith(urlString: url1)

        
        //Image 2
        let url2 = ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[1].image

        self.commandImgViewLeft2.isHidden = false
        self.commandImgViewLeft2.setImageWith(urlString: url2)

        self.commandImgViewRight2.isHidden = false
        self.commandImgViewRight2.setImageWith(urlString: url2)
        self.commandImgViewRightCopy2.setImageWith(urlString: url2)

        
        //Image 3
        let url3 = ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.block[2].image

        self.commandImgViewLeft3.isHidden = false
        self.commandImgViewLeft3.setImageWith(urlString: url3)

        self.commandImgViewRight3.isHidden = false
        self.commandImgViewRight3.setImageWith(urlString: url3)
        self.commandImgViewRightCopy3.setImageWith(urlString: url3)
        
        self.initializeTimer()
    }
    
    //MARK:- Gesture
    private func addGesture() {
        //Image 1
        let panGesture1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan1))
        self.commandImgViewRight1.addGestureRecognizer(panGesture1)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap1(_:)))
        self.commandImgViewRight1.addGestureRecognizer(tap1)
        
        
        let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan2))
        self.commandImgViewRight2.addGestureRecognizer(panGesture2)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))
        self.commandImgViewRight2.addGestureRecognizer(tap2)
        
        
        let panGesture3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan3))
        self.commandImgViewRight3.addGestureRecognizer(panGesture3)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap3(_:)))
        self.commandImgViewRight3.addGestureRecognizer(tap3)
        
    }
    
    @objc func handleTap1(_ sender: UITapGestureRecognizer? = nil) {
        self.dragAnimationView1.isHidden = true
        isDragStarted = true
        self.imgViewFinger2.isHidden = true
    }
    
    @objc func handleTap2(_ sender: UITapGestureRecognizer? = nil) {
        self.dragAnimationView2.isHidden = true
        isDragStarted = true
        self.imgViewFinger2.isHidden = true
    }
    
    @objc func handleTap3(_ sender: UITapGestureRecognizer? = nil) {
        self.dragAnimationView3.isHidden = true
        isDragStarted = true
        self.imgViewFinger3.isHidden = true
    }
    
    @objc func handlePan1(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            isDragStarted = true
            self.dragAnimationView1.isHidden = true
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            self.commandImgViewRight1.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
                let dropLocation = gestureRecognizer.location(in: view)
                if commandImgViewLeft1.frame.contains(dropLocation) {
                    isDragCompletedCount = isDragCompletedCount+1
                    if(isDragCompletedCount >= 3) {
                        isDragCompleted = true
                    } else {
                        SpeechManager.shared.setDelegate(delegate: self)
                        SpeechManager.shared.speak(message:  SpeechMessage.excellentWork.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

                    }
                    self.commandImgViewRight1.frame = self.commandImgViewLeft1.frame
                    
                } else {
                    self.commandImgViewRight1.frame = initialRightImageViewFrame1
                }
        default:break
        }
    }
    
    @objc func handlePan2(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            isDragStarted = true
            self.dragAnimationView2.isHidden = true
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            self.commandImgViewRight2.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
                let dropLocation = gestureRecognizer.location(in: view)
                if commandImgViewLeft2.frame.contains(dropLocation) {
                    isDragCompletedCount = isDragCompletedCount+1
                    if(isDragCompletedCount >= 3) {
                        isDragCompleted = true
                    } else {
                        SpeechManager.shared.setDelegate(delegate: self)
                        SpeechManager.shared.speak(message:  SpeechMessage.excellentWork.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    }
                    self.commandImgViewRight2.frame = self.commandImgViewLeft2.frame
                    
                } else {
                    self.commandImgViewRight2.frame = initialRightImageViewFrame2
                }
        default:break
        }
    }
    
    @objc func handlePan3(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            isDragStarted = true
            self.dragAnimationView3.isHidden = true
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            self.commandImgViewRight3.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
                let dropLocation = gestureRecognizer.location(in: view)
                if commandImgViewLeft3.frame.contains(dropLocation) {
                    isDragCompletedCount = isDragCompletedCount+1
                    if(isDragCompletedCount >= 3) {
                        isDragCompleted = true
                    } else {
                        SpeechManager.shared.setDelegate(delegate: self)
                        SpeechManager.shared.speak(message:  SpeechMessage.excellentWork.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    }
                    self.commandImgViewRight3.frame = self.commandImgViewLeft3.frame
                    
                } else {
                    self.commandImgViewRight3.frame = initialRightImageViewFrame3
                }
        default:break
        }
    }
    
    
    private func listenModelClosures() {
        
           self.matchingObjectViewModel.dataClosure = {
              DispatchQueue.main.async {
                    if let res = self.matchingObjectViewModel.trialSubmitResponseVO {
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

        self.matchingObjectViewModel.startPracticeClosure = {
                DispatchQueue.main.async {
//                    self.isUserInteraction = true
//                    self.apiDataState = .comandFinished
//                    self.initializeTimer()
                }
            }
        //blink_all_images
        
        self.matchingObjectViewModel.blinkAllImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                self.blink(commandImgViewLeft1, count: 3)
                self.blink(commandImgViewRight1, count: 3)
                
                self.blink(commandImgViewLeft2, count: 3)
                self.blink(commandImgViewRight2, count: 3)
                
                self.blink(commandImgViewLeft3, count: 3)
                self.blink(commandImgViewRight3, count: 3)

            }
        }
        
        self.matchingObjectViewModel.blinkImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                self.blink(commandImgViewLeft1, count: 3)
                self.blink(commandImgViewRight1, count: 3)

//                for i in 0..<self.matchingObjectInfo.image_with_text.count {
//                    let img = self.matchingObjectInfo.image_with_text[i]
//                    if(img.id == questioninfo.value_id) {
//
//                        //Image 1
//                        if(img.name == "Left") {
//                            self.blink(commandImgViewLeft1, count: 3)
//                        } else if(img.name == "Right") {
//                            self.blink(commandImgViewRight1, count: 3)
//                        }
//
//                        //Image 2
//                        if(img.name == "Left") {
//                            self.blink(commandImgViewLeft2, count: 3)
//                        } else if(img.name == "Right") {
//                            self.blink(commandImgViewRight2, count: 3)
//                        }
//
//                        //Image 3
//                        if(img.name == "Left") {
//                            self.blink(commandImgViewLeft3, count: 3)
//                        } else if(img.name == "Right") {
//                            self.blink(commandImgViewRight3, count: 3)
//                        }
//                    }
//                }
             }
        }
        
        //P2
        self.matchingObjectViewModel.showGreenCircleClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                          
                self.green_circle(commandImgViewLeft1, count: 3)
                self.green_circle(commandImgViewRight1, count: 3)
                
//                for i in 0..<self.matchingObjectInfo.image_with_text.count {
//                    let img = self.matchingObjectInfo.image_with_text[i]
//                    //DILIP self.green_circle(commandImgViewRight, count: 3)
//                    if(img.id == questioninfo.value_id) {
//
//                        //Image 1
//                        if(img.name == "Left") {
//                            self.green_circle(commandImgViewLeft1, count: 3)
//                        } else if(img.name == "Right") {
//                            self.green_circle(commandImgViewRight1, count: 3)
//                        }
//
//                        //Image 2
//                        if(img.name == "Left") {
//                            self.green_circle(commandImgViewLeft2, count: 3)
//                        } else if(img.name == "Right") {
//                            self.green_circle(commandImgViewRight2, count: 3)
//                        }
//
//                        //Image 3
//                        if(img.name == "Left") {
//                            self.green_circle(commandImgViewLeft3, count: 3)
//                        } else if(img.name == "Right") {
//                            self.green_circle(commandImgViewRight3, count: 3)
//                        }
//                    }
//                }
             }
        }
        
        //P3
        
        //showFingerClosure
        self.matchingObjectViewModel.showFingerClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

//                self.show_finger_on_image(commandImgViewLeft1, count: 3)
                self.show_finger_on_image(commandImgViewRight1, count: 3)
             }
        }
        
        self.matchingObjectViewModel.showFingerOnImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                //self.show_finger_on_image(commandImgViewLeft1, count: 3)
                self.show_finger_on_image(commandImgViewRight1, count: 3)
                
//                for i in 0..<self.matchingObjectInfo.image_with_text.count {
//                    let img = self.matchingObjectInfo.image_with_text[i]
//
//                    //Image 1
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            self.show_finger_on_image(commandImgViewLeft1, count: 3)
//                        } else if(img.name == "Right") {
//                            self.show_finger_on_image(commandImgViewRight1, count: 3)
//                        }
//                    }
//
//                    //Image 2
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            self.show_finger_on_image(commandImgViewLeft2, count: 3)
//                        } else if(img.name == "Right") {
//                            self.show_finger_on_image(commandImgViewRight2, count: 3)
//                        }
//                    }
//
//                    //Image 3
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            self.show_finger_on_image(commandImgViewLeft3, count: 3)
//                        } else if(img.name == "Right") {
//                            self.show_finger_on_image(commandImgViewRight3, count: 3)
//                        }
//                    }
//                }
             }
        }
        
        //P4 P6
        self.matchingObjectViewModel.showTapFingerAnimationClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                self.show_tap_fingure_animation(commandImgViewLeft1, count: 3)
                self.show_tap_fingure_animation(commandImgViewRight1, count: 3)
                
//                for i in 0..<self.matchingObjectInfo.image_with_text.count {
//                    let img = self.matchingObjectInfo.image_with_text[i]
//
//                    if(img.id == questioninfo.value_id) {
//
//                        //Image 1
//                        if(img.name == "Left") {
//                            self.show_tap_fingure_animation(commandImgViewLeft1, count: 3)
//                        } else if(img.name == "Right") {
//                            self.show_tap_fingure_animation(commandImgViewRight1, count: 3)
//                        }
//
//                        //Image 2
//                        if(img.name == "Left") {
//                            self.show_tap_fingure_animation(commandImgViewLeft2, count: 3)
//                        } else if(img.name == "Right") {
//                            self.show_tap_fingure_animation(commandImgViewRight2, count: 3)
//                        }
//
//                        //Image 3
//                        if(img.name == "Left") {
//                            self.show_tap_fingure_animation(commandImgViewLeft3, count: 3)
//                        } else if(img.name == "Right") {
//                            self.show_tap_fingure_animation(commandImgViewRight3, count: 3)
//                        }
//                    }
//                }
             }
        }
        
        //P5.1
        self.matchingObjectViewModel.makeBiggerClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                Animations.makeBiggerAnimation(imageView: commandImgViewLeft1, questionInfo: questioninfo, completion: { (finished) in
                    self.matchingObjectViewModel.updateCurrentCommandIndex()
                })
//                for i in 0..<self.matchingObjectInfo.image_with_text.count {
//                    let img = self.matchingObjectInfo.image_with_text[i]
//
//                    //Image 1
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            Animations.makeBiggerAnimation(imageView: commandImgViewLeft1, questionInfo: questioninfo, completion: { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            })
//                        } else if(img.name == "Right") {
//                            Animations.makeBiggerAnimation(isLeft:false, imageView: commandImgViewRight1, questionInfo: questioninfo, completion: { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            })
//                        }
//                    }
//
//                    //Image 2
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            Animations.makeBiggerAnimation(imageView: commandImgViewLeft2, questionInfo: questioninfo, completion: { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            })
//                        } else if(img.name == "Right") {
//                            Animations.makeBiggerAnimation(isLeft:false, imageView: commandImgViewRight2, questionInfo: questioninfo, completion: { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            })
//                        }
//                    }
//
//                    //Image 3
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            Animations.makeBiggerAnimation(imageView: commandImgViewLeft3, questionInfo: questioninfo, completion: { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            })
//                        } else if(img.name == "Right") {
//                            Animations.makeBiggerAnimation(isLeft:false, imageView: commandImgViewRight3, questionInfo: questioninfo, completion: { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            })
//                        }
//                    }
//                }
             }
        }
        
        //P5.2
        self.matchingObjectViewModel.makeImageNormalClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                            
                Animations.normalImageAnimation(imageView: commandImgViewLeft1, questionInfo: questioninfo) { (finished) in
                    self.matchingObjectViewModel.updateCurrentCommandIndex()
                }
                
//                for i in 0..<self.matchingObjectInfo.image_with_text.count {
//                    let img = self.matchingObjectInfo.image_with_text[i]
//
//                    //Image 1
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            Animations.normalImageAnimation(imageView: commandImgViewLeft1, questionInfo: questioninfo) { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            }
//                        } else if(img.name == "Right") {
//                            Animations.normalImageAnimation(isLeft:false, imageView: commandImgViewRight1, questionInfo: questioninfo) { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            }
//                            }
//                        }
//
//                    //Image 2
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            Animations.normalImageAnimation(imageView: commandImgViewLeft2, questionInfo: questioninfo) { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            }
//                        } else if(img.name == "Right") {
//                            Animations.normalImageAnimation(isLeft:false, imageView: commandImgViewRight2, questionInfo: questioninfo) { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            }
//                            }
//                        }
//
//                    //Image 3
//                    if(img.id == questioninfo.value_id) {
//                        if(img.name == "Left") {
//                            Animations.normalImageAnimation(imageView: commandImgViewLeft3, questionInfo: questioninfo) { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            }
//                        } else if(img.name == "Right") {
//                            Animations.normalImageAnimation(isLeft:false, imageView: commandImgViewRight3, questionInfo: questioninfo) { (finished) in
//                                self.matchingObjectViewModel.updateCurrentCommandIndex()
//                            }
//                            }
//                        }
//                    }
                }
             }
        
        self.matchingObjectViewModel.dragTransparentImageClosure = { questionInfo in
            DispatchQueue.main.async {
                
                //Image 1
                if let option = questionInfo.option {
                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
                        var duration = 0
                        if option.time_in_second.count > 0 {
                            duration = Int(option.time_in_second) ?? 0
                        }
                        self.isDragStarted = false
                        self.dragAnimationView1.isHidden = false
                        self.dragAnimationView1.isUserInteractionEnabled = false
                        if !self.isDragCompleted {
                            self.rightToleftTransparentAnimation(duration: duration-2)
                        }
                    } else {
                        var duration = 0
                        if option.time_in_second.count > 0 {
                            duration = Int(option.time_in_second) ?? 0
                        }
                        self.isDragStarted = false
                        self.dragAnimationView1.isHidden = false
                        self.dragAnimationView1.isUserInteractionEnabled = false
                        if !self.isDragCompleted {
                            self.rightToleftTransparentAnimation(duration: duration-2)
                        }
                    }
                }
                
//                //Image 2
//                if let option = questionInfo.option {
//                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView2.isHidden = false
//                        self.dragAnimationView2.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftTransparentAnimation(duration: duration-2)
//                        }
//                    } else {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView2.isHidden = false
//                        self.dragAnimationView2.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftTransparentAnimation(duration: duration-2)
//                        }
//                    }
//                }
//
//                //Image 3
//                if let option = questionInfo.option {
//                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView3.isHidden = false
//                        self.dragAnimationView3.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftTransparentAnimation(duration: duration-2)
//                        }
//                    } else {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView3.isHidden = false
//                        self.dragAnimationView3.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftTransparentAnimation(duration: duration-2)
//                        }
//                    }
//                }
             }
        }
        
        self.matchingObjectViewModel.startDragAnimationClosure = { questionInfo in
            DispatchQueue.main.async {

                //Image 1
                if let option = questionInfo.option {
                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
                        var duration = 0
                        if option.time_in_second.count > 0 {
                            duration = Int(option.time_in_second) ?? 0
                        }
                        self.isDragStarted = false
                        self.dragAnimationView1.isHidden = false
                        self.dragAnimationView1.isUserInteractionEnabled = false
                        if !self.isDragCompleted {
                            self.rightToleftAnimation(duration: duration)
                        }
                    }
                }
                
//                //Image 2
//                if let option = questionInfo.option {
//                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView2.isHidden = false
//                        self.dragAnimationView2.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftAnimation(duration: duration)
//                        }
//                    }
//                }
//                
//                //Image 3
//                if let option = questionInfo.option {
//                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
//                        var duration = 0
//                        if option.time_in_second.count > 0 {
//                            duration = Int(option.time_in_second) ?? 0
//                        }
//                        self.isDragStarted = false
//                        self.dragAnimationView3.isHidden = false
//                        self.dragAnimationView3.isUserInteractionEnabled = false
//                        if !self.isDragCompleted {
//                            self.rightToleftAnimation(duration: duration)
//                        }
//                    }
//                }
             }
        }
        
        self.matchingObjectViewModel.showImageClosure = { questionInfo in
            DispatchQueue.main.async {
            }
        }
        
        self.matchingObjectViewModel.dragImageClosure = { questionInfo in
            DispatchQueue.main.async {
                self.dragImageRightToLeft(duration: 1)
            }
        }
        
                    
   }
    
    private func findImageViewWith(id:String) -> ScriptCommandImageView? {
        for subview in self.view.subviews {
            if let cmdImageView = subview as? ScriptCommandImageView {
                if cmdImageView.commandInfo?.value_id == id {
                    return cmdImageView
                }
            }
        }
        return nil
    }
    
    
    private func blinkAllImages(count: Int) {
//        if count == 0 {
//            self.commandViewModal.updateCurrentCommandIndex()
//            return
//        }
                UIView.animate(withDuration: 1, animations: {
                    for subview in self.view.subviews {
                        if let cmdImageView = subview as? ScriptCommandImageView {
                            cmdImageView.alpha = 0.2
                        }
                    }
                }) { [self] finished in
                    for subview in self.view.subviews {
                        if let cmdImageView = subview as? ScriptCommandImageView {
                            cmdImageView.alpha = 1
                        }
                    }
                    self.blinkAllImages(count: count - 1)
                    //self.commandViewModal.updateCurrentCommandIndex()
                }
        
    }
    
    
    //MARK:- Methods animation
    //P1
    private func blink(_ imageView: UIImageView, count: Int) {
        if count == 0 {
            self.matchingObjectViewModel.updateCurrentCommandIndex()
            return
        }
        DispatchQueue.main.async {

            UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                imageView.alpha = 0.2
            }) { [self] finished in
                UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                    imageView.alpha = 1.0
                }) { [self] finished in
                    blink(imageView, count: count - 1)
                }
            }
        }
    }
    
    //P2
    private func green_circle(_ imageView: UIImageView, count: Int) {
//        if count == 0 {
//            self.matchingObjectViewModel.updateCurrentCommandIndex()
//            return
//        }
//        self.is_green_circle = true
//        self.selectedIndex = self.answerIndex
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            self.is_green_circle = false
//            self.selectedIndex = -1
//        })
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
//            self.green_circle(imageView, count: count - 1)
//        })
    }
    
    
    //P3
    private func show_finger_on_image(_ imageView: UIImageView, count: Int) {
        if count == 0 {
            self.matchingObjectViewModel.updateCurrentCommandIndex()
            return
        }
         
//        let width = imageView.frame.size.width
//        let widthHalf = width/2.0
//
//        let height = imageView.frame.height
//        let heightHalf = height/2.0
        
        //Image 1
//        self.imgViewFinger1.frame = CGRect(x: imageView.frame.origin.x+(widthHalf/2), y: imageView.frame.origin.y+(heightHalf+30), width: widthHalf, height: widthHalf)
        self.imgViewFinger1.isHidden =  false
        dragAnimationView1.isHidden = false
        dragAnimationView1.backgroundColor = .clear
        
        self.perform(#selector(hideImage(_:)), with: imgViewFinger1, afterDelay: TimeInterval(count))
        self.perform(#selector(hideView(_:)), with: imgViewFinger1, afterDelay: TimeInterval(count))
//        //Image 2
//        self.imgViewFinger2.frame = CGRect(x: imageView.frame.origin.x+(widthHalf/2), y: imageView.frame.origin.y+(heightHalf+30), width: widthHalf, height: widthHalf)
//        self.imgViewFinger2.isHidden =  false
//
//        //Image 3
//        self.imgViewFinger3.frame = CGRect(x: imageView.frame.origin.x+(widthHalf/2), y: imageView.frame.origin.y+(heightHalf+30), width: widthHalf, height: widthHalf)
//        self.imgViewFinger3.isHidden =  false

    }
    @objc func hideImage(_ imgView:UIImageView) {
        imgView.isHidden =  true
    }
    @objc func hideView(_ dview:UIView) {
        dview.isHidden =  true
    }
    //P4 & P6
    private func show_tap_fingure_animation(_ imageView: UIImageView, count: Int) {
        if count == 0 {
            self.matchingObjectViewModel.updateCurrentCommandIndex()
            return
        }
               
        let width = imageView.frame.size.width
        let widthHalf = width/2.0

        DispatchQueue.main.async {

            //Image 1
            self.imgViewFinger1.frame = CGRect(x: self.view.center.x, y: self.view.center.y+self.view.center.y-widthHalf, width: widthHalf, height: widthHalf)
            self.imgViewFinger1.isHidden =  false

            UIView.animate(withDuration: learningAnimationDuration, animations: {
                self.imgViewFinger1.frame = CGRect(x: imageView.frame.origin.x+(widthHalf-(widthHalf/2)), y: imageView.frame.origin.y+(widthHalf-(widthHalf/2)), width: widthHalf, height: widthHalf)
            }) { [self] finished in
                UIView.animate(withDuration: learningAnimationDuration, animations: {
                    imageView.alpha = 1.0
                }) { [self] finished in
                    self.imgViewFinger1.isHidden = true
                    self.imgViewFinger1.frame = CGRect(x: widthHalf-(widthHalf/2), y: width, width: widthHalf, height: widthHalf)
                    self.show_tap_fingure_animation(imageView, count: count - 1)
                }
            }
            
        }
    }
    
    private func rightToleftTransparentAnimation(duration:Int)
    {
        print("rightToleftTransparentAnimation ============ \(duration)")
        DispatchQueue.main.async {
            if duration == 0 {
                self.matchingObjectViewModel.updateCurrentCommandIndex()
                return
            }
            
            //Image 1
            self.commandImgViewRightCopy1.alpha = 0.5
            self.commandImgViewRight1.isHidden = false
            UIView.animate(withDuration: 3, animations: {
                self.dragAnimationView1.frame = self.commandImgViewLeft1.frame
            }) {  finished in
                if !self.isDragCompleted && !self.isDragStarted {
                    self.dragAnimationView1.frame = self.initialRightImageViewFrame1
                    self.rightToleftTransparentAnimation(duration: duration-1)
                } else if !self.isDragCompleted && self.isDragStarted   {
                    self.dragAnimationView1.isHidden = true
                }
            }
            
//            //Image 2
//            self.commandImgViewRightCopy2.alpha = 0.5
//            self.commandImgViewRight2.isHidden = false
//            UIView.animate(withDuration: 3, animations: {
//                self.dragAnimationView2.frame = self.commandImgViewLeft2.frame
//            }) {  finished in
//                if !self.isDragCompleted && !self.isDragStarted {
//                    self.dragAnimationView2.frame = self.initialRightImageViewFrame2
//                    self.rightToleftTransparentAnimation(duration: duration-1)
//                } else if !self.isDragCompleted && self.isDragStarted   {
//                    self.dragAnimationView2.isHidden = true
//                }
//            }
//
//            //Image 3
//            self.commandImgViewRightCopy3.alpha = 0.5
//            self.commandImgViewRight3.isHidden = false
//            UIView.animate(withDuration: 3, animations: {
//                self.dragAnimationView3.frame = self.commandImgViewLeft3.frame
//            }) {  finished in
//                if !self.isDragCompleted && !self.isDragStarted {
//                    self.dragAnimationView3.frame = self.initialRightImageViewFrame3
//                    self.rightToleftTransparentAnimation(duration: duration-1)
//                } else if !self.isDragCompleted && self.isDragStarted   {
//                    self.dragAnimationView3.isHidden = true
//                }
//            }
        }
     }

    private func rightToleftAnimation(duration:Int)
    {
        print("rightToleftAnimation ============ \(duration)")
        DispatchQueue.main.async {
            if duration == 0 {
                self.matchingObjectViewModel.updateCurrentCommandIndex()
                return
            }

            //Image 1
            self.commandImgViewRightCopy1.alpha = 1.0
            self.commandImgViewRight1.isHidden = true
            UIView.animate(withDuration: 3, animations: {
                self.dragAnimationView1.frame = self.commandImgViewLeft1.frame
            }) {  finished in
                self.commandImgViewRight1.isHidden = false
                if !self.isDragCompleted && !self.isDragStarted {
                    self.dragAnimationView1.frame = self.initialRightImageViewFrame1
                    self.rightToleftAnimation(duration: duration-1)
                } else if !self.isDragCompleted && self.isDragStarted   {
                    self.dragAnimationView1.isHidden = true
                }
            }
            
//            //Image 2
//            self.commandImgViewRightCopy2.alpha = 1.0
//            self.commandImgViewRight2.isHidden = true
//            UIView.animate(withDuration: 3, animations: {
//                self.dragAnimationView2.frame = self.commandImgViewLeft2.frame
//            }) {  finished in
//                self.commandImgViewRight2.isHidden = false
//                if !self.isDragCompleted && !self.isDragStarted {
//                    self.dragAnimationView2.frame = self.initialRightImageViewFrame2
//                    self.rightToleftAnimation(duration: duration-1)
//                } else if !self.isDragCompleted && self.isDragStarted   {
//                    self.dragAnimationView2.isHidden = true
//                }
//            }
//
//            //Image 3
//            self.commandImgViewRightCopy3.alpha = 1.0
//            self.commandImgViewRight3.isHidden = true
//            UIView.animate(withDuration: 3, animations: {
//                self.dragAnimationView3.frame = self.commandImgViewLeft3.frame
//            }) {  finished in
//                self.commandImgViewRight3.isHidden = false
//                if !self.isDragCompleted && !self.isDragStarted {
//                    self.dragAnimationView3.frame = self.initialRightImageViewFrame3
//                    self.rightToleftAnimation(duration: duration-1)
//                } else if !self.isDragCompleted && self.isDragStarted   {
//                    self.dragAnimationView3.isHidden = true
//                }
//            }
        }
     }
    
    func dragImageRightToLeft(duration:Int) {
        print("rightToleftDrag ============ \(duration)")
        DispatchQueue.main.async {
            if duration == 0 {
                self.isDragCompletedCount = self.isDragCompletedCount+1
                self.matchingObjectViewModel.updateCurrentCommandIndex()
                return
            }

            //Image 1
            self.commandImgViewRightCopy1.alpha = 1.0
            self.commandImgViewRight1.isHidden = true
            self.dragAnimationView1.isHidden = false
            UIView.animate(withDuration: 3, animations: {
                self.dragAnimationView1.frame = self.commandImgViewLeft1.frame
            }) {  finished in
                //self.commandImgViewRight1.isHidden = false
                if !self.isDragCompleted && !self.isDragStarted {
//                    self.dragAnimationView1.frame = self.initialRightImageViewFrame1
                    self.dragImageRightToLeft(duration: duration-1)
                } else if !self.isDragCompleted && self.isDragStarted   {
                    self.dragAnimationView1.isHidden = true
                }
            }
        }
     }
 }

extension TrialMatching3PairViewController {
    func setMatchingObjectInfo(info:MatchingObjectInfo,delegate:TrialSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
    
    func setMatchingObjectInfo(info:MatchingObjectInfo) {
        self.apiDataState = .dataFetched
        self.matchingObjectInfo = info
    }
}

extension TrialMatching3PairViewController {
    
    private func moveToNextQuestion() {
          self.stopQuestionCompletionTimer()
          self.questionState = .submit
          self.success_count = 0
          SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func initializeTimer() {
        questionCompletionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        print("Match Object")
        self.timeTakenToSolve += 1
        print(timeTakenToSolve)
        if self.timeTakenToSolve == self.matchingObjectInfo.trial_time {
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.matchingObjectInfo.completion_time {
            self.moveToNextQuestion()
    }
}

    private func stopQuestionCompletionTimer() {
    if let timer = self.questionCompletionTimer {
              timer.invalidate()
        self.questionCompletionTimer = nil
    }
}
    
    func submitTrialMatchingAnswer(info:MatchingObjectInfo) {
//        if !Utility.isNetworkAvailable() {
//            if let noNetwork = self.noNetWorkClosure {
//                noNetwork()
//            }
//            return
//        }

        if let user = UserManager.shared.getUserInfo() {

//            {
//                "user_id":"5f857e8af43653754167c1c6",
//                "question_id":"5f97a65b7ea8177fddb09944",
//                "question_type":"color_trace_table",
//                "skill_domain_id" : "5f3696756a47807a001de5b1",
//                "program_id" : "5f3684ba05bde342aec23ffc",
//                "level" : "1",
//                "complete_rate":80,
//                "language":"en",
//                "course_type" : "Trial",
//                "req_no" : "SD3P3L1",
//                "time_taken":"17",
//                "image_url" : "",
//                "skip" : false,
//                "prompt_type" : ""
//
//            }
            let parameters: [String : Any] = [
               ServiceParsingKeys.user_id.rawValue :user.id,
                ServiceParsingKeys.question_id.rawValue :info.id,
               ServiceParsingKeys.question_type.rawValue :info.question_type,
                ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                ServiceParsingKeys.program_id.rawValue:info.program_id,
                ServiceParsingKeys.level.rawValue:info.level,
                ServiceParsingKeys.complete_rate.rawValue :success_count,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.course_type.rawValue:"Trial",
                ServiceParsingKeys.req_no.rawValue:info.req_no,
               ServiceParsingKeys.time_taken.rawValue :self.timeTakenToSolve,
                ServiceParsingKeys.image_url.rawValue :"",
               ServiceParsingKeys.skip.rawValue:skipQuestion,
                ServiceParsingKeys.prompt_type.rawValue:info.prompt_type,
                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
            ]
            LearningManager.submitTrialMatchingAnswer(parameters: parameters)
        }
//        }
    }
}

// MARK: Speech Manager Delegate Methods
extension TrialMatching3PairViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            
            if(self.isFromLearning == false) {
                self.matchingObjectViewModel.submitUserAnswer(successCount: self.success_count, info: self.matchingObjectInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, selectedIndex: 0)
            } else {
                self.submitTrialMatchingAnswer(info: self.matchingObjectInfo)
            }
            
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


extension TrialMatching3PairViewController: NetworkRetryViewDelegate {
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

