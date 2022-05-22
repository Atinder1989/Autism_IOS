//
//  LearningMatchingViewController.swift
//  Autism
//
//  Created by Savleen on 08/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class ScriptCommandImageView : UIImageView {
    var commandInfo : ScriptCommandInfo?
}

class LearningMatchingViewController: UIViewController {
    private let commandViewModal: LearningMatchingViewModel = LearningMatchingViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    
    private var command_array: [ScriptCommandInfo] = []
    
    private var isChildAction = false
    private var isDragCompleted = false {
        didSet {
            if isDragCompleted {
                DispatchQueue.main.async { [self] in
                    self.commandViewModal.calculateChildAction(state: self.isDragCompleted, isDragStarted: isDragStarted)
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
    @IBOutlet weak var dragAnimationView: UIView!
    @IBOutlet weak var skipLearningButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.skipLearningButton.isHidden = isSkipLearningHidden
        self.customSetting()
        self.addGesture()
        if self.command_array.count == 0 {
            self.commandViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
//    @IBAction func backClicked(_ sender: Any) {
//        self.commandViewModal.stopAllCommands()
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.commandViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipLearningClicked(_ sender: Any) {
        self.commandViewModal.stopAllCommands()
        self.commandViewModal.skipLearningSubmitLearningMatchingAnswer()
    }
}

//MARK:- Public Methods
extension LearningMatchingViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()

        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.commandViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
        }
    }
}

//MARK:- Private Methods
extension LearningMatchingViewController {
    private func initializeFrame()
    {
        let tW:CGFloat = UIScreen.main.bounds.width
        let tH:CGFloat = UIScreen.main.bounds.height
        
        var imgWH:CGFloat = 220
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            imgWH = 120
        }
        commandImgViewLeft.frame = CGRect(x:50, y:(tH-imgWH)/2.0, width:imgWH, height:imgWH)
        initialRightImageViewFrame = CGRect(x:tW-imgWH-50, y:(tH-imgWH)/2.0, width:imgWH, height:imgWH)
        commandImgViewRight.frame = initialRightImageViewFrame
        dragAnimationView.frame = initialRightImageViewFrame
    }
    
    private func customSetting() {
        self.initializeFrame()
        isChildAction = false
        self.isDragCompleted = false
        self.isDragStarted = false
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  getIdleGif()
        self.avatarCenterImageView.isHidden = true
        self.commandImgViewLeft.isHidden = true
        self.commandImgViewRight.isHidden = true
        self.avatarBottomImageView.isHidden = true
        self.dragAnimationView.isHidden = true
       // self.view.isUserInteractionEnabled = false
        self.commandImgViewLeft.image = nil
        self.commandImgViewRight.image = nil
        Utility.setView(view: self.commandImgViewLeft, cornerRadius: 0, borderWidth: 0, color: .clear)
    }
    
    private func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.commandImgViewRight.addGestureRecognizer(panGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.commandImgViewRight.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !isChildAction {
            return
        }
        self.dragAnimationView.isHidden = true
        isDragStarted = true
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if !isChildAction {
            return
        }
        
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
       self.commandViewModal.clearScreenClosure = {
            DispatchQueue.main.async {
                self.customSetting()
                self.commandViewModal.updateCurrentCommandIndex()
            }
       }
        
       self.commandViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
                
       self.commandViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.commandViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
        
       self.commandViewModal.showAvatarClosure = { commandInfo in
           DispatchQueue.main.async {
            if let option = commandInfo.option {
                if option.Position == ScriptCommandOptionType.center.rawValue {
                    self.avatarCenterImageView.isHidden = false
                }
            }
           }
       }
      
       self.commandViewModal.waveAvatarClosure = {
            DispatchQueue.main.async {
                self.avatarCenterImageView.animatedImage =  getHurrayGif()
            }
       }
        
        self.commandViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
               // self.view.isUserInteractionEnabled = state
                self.isChildAction = state
             }
        }
        
       self.commandViewModal.talkAvatarClosure = { commandInfo in
             DispatchQueue.main.async {
                if let option = commandInfo.option {
                    if option.Position == ScriptCommandOptionType.center.rawValue {
                        self.avatarCenterImageView.isHidden = false
                        self.avatarCenterImageView.animatedImage =  getTalkingGif()
                    } else if option.Position == ScriptCommandOptionType.bottom.rawValue {
                        self.avatarBottomImageView.isHidden = false
                        self.avatarBottomImageView.animatedImage =  getTalkingGif()
                    }
                }
             }
       }
        
       self.commandViewModal.hideAvatarClosure = {
              DispatchQueue.main.async {
                self.avatarCenterImageView.isHidden = true
              }
       }
        
       self.commandViewModal.showImageClosure = { questionInfo in
            DispatchQueue.main.async {
                if let option = questionInfo.option {
                    let url = ServiceHelper.baseURL.getMediaBaseUrl() + questionInfo.value
                    if option.Position == ScriptCommandOptionType.left.rawValue {
                        self.commandImgViewLeft.isHidden = false
                        self.commandImgViewLeft.commandInfo = questionInfo
                        self.commandImgViewLeft.setImageWith(urlString: url)
                    } else if option.Position == ScriptCommandOptionType.right.rawValue {
                        self.commandImgViewRight.isHidden = false
                        self.commandImgViewRight.commandInfo = questionInfo
                        self.commandImgViewRight.setImageWith(urlString: url)
                        self.commandImgViewRightCopy.setImageWith(urlString: url)
                    }
                    
                    if option.image_border == ScriptCommandOptionType.yes.rawValue {
                        if(UIDevice.current.userInterfaceIdiom == .pad) {
                            Utility.setView(view: self.commandImgViewLeft, cornerRadius: 110, borderWidth: 3, color: .greenBorderColor)
                        } else {
                            Utility.setView(view: self.commandImgViewLeft, cornerRadius: 60, borderWidth: 2, color: .greenBorderColor)
                        }
                    }
                }
            }
       }
        
        self.commandViewModal.makeBiggerClosure = { questionInfo in
             DispatchQueue.main.async {
                if let imgview = self.findImageViewWith(id: questionInfo.value_id) {
                    Animations.makeBiggerAnimation(imageView: imgview, questionInfo: questionInfo) { (finished) in
                        self.commandViewModal.updateCurrentCommandIndex()
                    }
                }
             }
        }
        
        self.commandViewModal.makeImageNormalClosure = { questionInfo in
             DispatchQueue.main.async {
                if let imgview = self.findImageViewWith(id: questionInfo.value_id) {
                    Animations.normalImageAnimation(imageView: imgview, questionInfo: questionInfo) { (finished) in
                        self.commandViewModal.updateCurrentCommandIndex()
                    }
                }
             }
        }
        
        self.commandViewModal.blinkAllImagesClosure = { questionInfo in
            DispatchQueue.main.async {
                if let option = questionInfo.option {
                    self.blinkAllImages(count: Int(option.time_in_second) ?? Int(learningAnimationDuration))
                }
             }
        }
        
        self.commandViewModal.startDragAnimationClosure = { questionInfo in
            DispatchQueue.main.async {
                
                if let option = questionInfo.option {
                    if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
                        var duration = 0
                        if option.time_in_second.count > 0 {
                            duration = Int(option.time_in_second) ?? 0
                        }
                        self.isDragStarted = false
                        self.dragAnimationView.isHidden = false
                        if !self.isDragCompleted {
                            self.rightToleftAnimation(duration: duration-2)
                        }
                    }
                }
             }
        }
        
        self.commandViewModal.dragImageClosure = { questionInfo in
            DispatchQueue.main.async {
                if let option = questionInfo.option {
                    if option.Position == ScriptCommandOptionType.right.rawValue && option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
                        self.dragAnimationView.isHidden = true
                        
                        if let imgview = self.findImageViewWith(id: questionInfo.value_id) {
                        Animations.dragImageAnimation(leftImageView: self.commandImgViewLeft, rightImageView: imgview) { (finished) in
                            print("Question Completed ========== ")
                            self.commandViewModal.calculateChildAction(state: false, isDragStarted: self.isDragStarted)
                            self.commandViewModal.updateCurrentCommandIndex()
                        }
                        }
                    }
                }
                
                
                
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
        if count == 0 {
            self.commandViewModal.updateCurrentCommandIndex()
            return
        }
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
     
    private func rightToleftAnimation(duration:Int)
    {
        print("rightToleftAnimation ============ \(duration)")
        DispatchQueue.main.async {
            if duration == 0 {
                return
            }
            UIView.animate(withDuration: 1, animations: {
                self.dragAnimationView.frame = self.commandImgViewLeft.frame
            }) {  finished in
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

extension LearningMatchingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}
