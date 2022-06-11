//
//  TrialMatchingOnePairViewController.swift
//  Autism
//
//  Created by Dilip Technology on 27/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TrialMatchingOnePairViewController: UIViewController {
    
    private var matchingObjectInfo: MatchingObjectInfo!
    private let matchingObjectViewModel = TrialMatchingObjectViewModel()
    private weak var delegate: TrialSubmitDelegate?
    
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
    private var initialRightImageViewFrame: CGRect = CGRect.init()
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var avatarCenterImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarBottomImageView: FLAnimatedImageView!
    @IBOutlet weak var commandImgViewLeft: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRight: ScriptCommandImageView!
    @IBOutlet weak var commandImgViewRightCopy: ScriptCommandImageView!
    
    @IBOutlet weak var imgViewFinger: UIImageView!
    
    @IBOutlet weak var dragAnimationView: UIView!

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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.matchingObjectViewModel.stopAllCommands()
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
    
extension TrialMatchingOnePairViewController {
    private func initializeFrame()
    {
        let tW:CGFloat = UIScreen.main.bounds.width
        let tH:CGFloat = UIScreen.main.bounds.height
        
        var imgWH:CGFloat = 220
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            imgWH = 140
        }
        
        commandImgViewLeft.frame = CGRect(x:50, y:(tH-imgWH)/2.0, width:imgWH, height:imgWH)
        initialRightImageViewFrame = CGRect(x:tW-imgWH-50, y:(tH-imgWH)/2.0, width:imgWH, height:imgWH)
        commandImgViewRight.frame = initialRightImageViewFrame
        dragAnimationView.frame = initialRightImageViewFrame
    }
    
    private func customSetting() {
        self.initializeFrame()
        self.isDragCompleted = false
        self.isDragStarted = false
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  getIdleGif()
        self.avatarCenterImageView.isHidden = true
        self.commandImgViewLeft.isHidden = true
        self.commandImgViewRight.isHidden = true
        self.avatarBottomImageView.isHidden = true
        self.dragAnimationView.isHidden = true
        self.view.isUserInteractionEnabled = false
        self.commandImgViewLeft.image = nil
        self.commandImgViewRight.image = nil
        Utility.setView(view: self.commandImgViewLeft, cornerRadius: 0, borderWidth: 0, color: .clear)
        
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message:  matchingObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        speechTitle.text = matchingObjectInfo.question_title
        
        self.commandImgViewLeft.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.bg_image)
        
        if self.matchingObjectInfo.prompt_detail.count > 0 {
            self.matchingObjectViewModel.setQuestionInfo(info:matchingObjectInfo)
        }
        
        let url = ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.bg_image

        self.commandImgViewLeft.isHidden = false
        self.commandImgViewLeft.setImageWith(urlString: url)

        self.commandImgViewRight.isHidden = false
        self.commandImgViewRight.setImageWith(urlString: url)
        self.commandImgViewRightCopy.setImageWith(urlString: url)

        self.initializeTimer()
    }
    
    //MARK:- Gesture
    private func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.commandImgViewRight.addGestureRecognizer(panGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.commandImgViewRight.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dragAnimationView.isHidden = true
        isDragStarted = true
        self.imgViewFinger.isHidden = true
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            isDragStarted = true
            self.dragAnimationView.isHidden = true
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            self.commandImgViewRight.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
                let dropLocation = gestureRecognizer.location(in: view)
                if commandImgViewLeft.frame.contains(dropLocation) {
                    isDragCompleted = true
                    self.commandImgViewRight.frame = self.commandImgViewLeft.frame
                    
                } else {
                    self.commandImgViewRight.frame = initialRightImageViewFrame
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
                    //self.customSetting()
                }
            }
                    
        self.matchingObjectViewModel.blinkImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    if(img.id == questioninfo.value_id) {
                        if(img.name == "Left") {
                            self.blink(commandImgViewLeft, count: 3)
                        } else if(img.name == "Right") {
                            self.blink(commandImgViewRight, count: 3)
                        }
                    }
                }
             }
        }
        
        //P2
        self.matchingObjectViewModel.showGreenCircleClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    self.green_circle(commandImgViewRight, count: 3)
                    if(img.id == questioninfo.value_id) {
                        if(img.name == "Left") {
                            self.green_circle(commandImgViewLeft, count: 3)
                        } else if(img.name == "Right") {
                            self.green_circle(commandImgViewRight, count: 3)
                        }
                    }
                }
             }
        }
        
        //P3
        self.matchingObjectViewModel.showFingerOnImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    
                    if(img.id == questioninfo.value_id) {
                        if(img.name == "Left") {
                            self.show_finger_on_image(commandImgViewLeft, count: 3)
                        } else if(img.name == "Right") {
                            self.show_finger_on_image(commandImgViewRight, count: 3)
                        }
                    }
                }
             }
        }
        
        //P4 P6
        self.matchingObjectViewModel.showTapFingerAnimationClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    
                    if(img.id == questioninfo.value_id) {
                        if(img.name == "Left") {
                            self.show_tap_fingure_animation(commandImgViewLeft, count: 3)
                        } else if(img.name == "Right") {
                            self.show_tap_fingure_animation(commandImgViewRight, count: 3)
                        }
                    }
                }
             }
        }
        
        //P5.1
        self.matchingObjectViewModel.makeBiggerClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]

                    if(img.id == questioninfo.value_id) {
                        if(img.name == "Left") {
                            Animations.makeBiggerAnimation(imageView: commandImgViewLeft, questionInfo: questioninfo, completion: { (finished) in
                                self.matchingObjectViewModel.updateCurrentCommandIndex()
                            })
                        } else if(img.name == "Right") {
                            Animations.makeBiggerAnimation(isLeft:false, imageView: commandImgViewRight, questionInfo: questioninfo, completion: { (finished) in
                                self.matchingObjectViewModel.updateCurrentCommandIndex()
                            })
                        }
                    }
                }
             }
        }
        
        //P5.2
        self.matchingObjectViewModel.makeImageNormalClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                                    
                    if(img.id == questioninfo.value_id) {
                        if(img.name == "Left") {
                            Animations.normalImageAnimation(imageView: commandImgViewLeft, questionInfo: questioninfo) { (finished) in
                                self.matchingObjectViewModel.updateCurrentCommandIndex()
                            }
                        } else if(img.name == "Right") {
                            Animations.normalImageAnimation(isLeft:false, imageView: commandImgViewRight, questionInfo: questioninfo) { (finished) in
                                self.matchingObjectViewModel.updateCurrentCommandIndex()
                            }
                            }
                        }
                    }
                }
             }
        
        self.matchingObjectViewModel.dragTransparentImageClosure = { questionInfo in
            DispatchQueue.main.async {
                
                if let option = questionInfo.option {
                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
                        var duration = 0
                        if option.time_in_second.count > 0 {
                            duration = Int(option.time_in_second) ?? 0
                        }
                        self.isDragStarted = false
                        self.dragAnimationView.isHidden = false
                        self.dragAnimationView.isUserInteractionEnabled = false
                        if !self.isDragCompleted {
                            self.rightToleftTransparentAnimation(duration: duration-2)
                        }
                    } else {
                        var duration = 0
                        if option.time_in_second.count > 0 {
                            duration = Int(option.time_in_second) ?? 0
                        }
                        self.isDragStarted = false
                        self.dragAnimationView.isHidden = false
                        self.dragAnimationView.isUserInteractionEnabled = false
                        if !self.isDragCompleted {
                            self.rightToleftTransparentAnimation(duration: duration-2)
                        }
                    }
                }
             }
        }
        
        self.matchingObjectViewModel.startDragAnimationClosure = { questionInfo in
            DispatchQueue.main.async {

                if let option = questionInfo.option {
                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
                        var duration = 0
                        if option.time_in_second.count > 0 {
                            duration = Int(option.time_in_second) ?? 0
                        }
                        self.isDragStarted = false
                        self.dragAnimationView.isHidden = false
                        self.dragAnimationView.isUserInteractionEnabled = false
                        if !self.isDragCompleted {
                            self.rightToleftAnimation(duration: duration)
                        }
                    }
                }
             }
        }
        
        self.matchingObjectViewModel.showImageClosure = { questionInfo in
            DispatchQueue.main.async {
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
         
        let width = imageView.frame.size.width
        let widthHalf = width/2.0

        let height = imageView.frame.height
        let heightHalf = height/2.0
        
        self.imgViewFinger.frame = CGRect(x: imageView.frame.origin.x+(widthHalf/2), y: imageView.frame.origin.y+(heightHalf+30), width: widthHalf, height: widthHalf)
        self.imgViewFinger.isHidden =  false
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

            self.imgViewFinger.frame = CGRect(x: self.view.center.x, y: self.view.center.y+self.view.center.y-widthHalf, width: widthHalf, height: widthHalf)
            self.imgViewFinger.isHidden =  false

            UIView.animate(withDuration: learningAnimationDuration, animations: {
                self.imgViewFinger.frame = CGRect(x: imageView.frame.origin.x+(widthHalf-(widthHalf/2)), y: imageView.frame.origin.y+(widthHalf-(widthHalf/2)), width: widthHalf, height: widthHalf)
            }) { [self] finished in
                UIView.animate(withDuration: learningAnimationDuration, animations: {
                    imageView.alpha = 1.0
                }) { [self] finished in
                    self.imgViewFinger.isHidden = true
                    self.imgViewFinger.frame = CGRect(x: widthHalf-(widthHalf/2), y: width, width: widthHalf, height: widthHalf)
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
                return
            }
            self.commandImgViewRightCopy.alpha = 0.5
            self.commandImgViewRight.isHidden = false
            UIView.animate(withDuration: 3, animations: {
                self.dragAnimationView.frame = self.commandImgViewLeft.frame
            }) {  finished in
                if !self.isDragCompleted && !self.isDragStarted {
                    self.dragAnimationView.frame = self.initialRightImageViewFrame
                    self.rightToleftTransparentAnimation(duration: duration-1)
                } else if !self.isDragCompleted && self.isDragStarted   {
                    self.dragAnimationView.isHidden = true
                }
            }
            
        }
     }

    private func rightToleftAnimation(duration:Int)
    {
        print("rightToleftAnimation ============ \(duration)")
        DispatchQueue.main.async {
            if duration == 0 {
                return
            }
            self.commandImgViewRightCopy.alpha = 1.0
            self.commandImgViewRight.isHidden = true
            UIView.animate(withDuration: 3, animations: {
                self.dragAnimationView.frame = self.commandImgViewLeft.frame
            }) {  finished in
                self.commandImgViewRight.isHidden = false
                if !self.isDragCompleted && !self.isDragStarted {
                    self.dragAnimationView.frame = self.initialRightImageViewFrame
                    self.rightToleftAnimation(duration: duration-1)
                } else if !self.isDragCompleted && self.isDragStarted   {
                    self.dragAnimationView.isHidden = true
                }
            }
            
        }
     }
 }

extension TrialMatchingOnePairViewController {
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

extension TrialMatchingOnePairViewController {
    
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
        if let user = UserManager.shared.getUserInfo() {

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
    }
}

// MARK: Speech Manager Delegate Methods
extension TrialMatchingOnePairViewController: SpeechManagerDelegate {
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


extension TrialMatchingOnePairViewController: NetworkRetryViewDelegate {
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

