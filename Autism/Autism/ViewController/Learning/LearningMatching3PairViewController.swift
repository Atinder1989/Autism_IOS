//
//  LearningMatching3PairViewController.swift
//  Autism
//
//  Created by Savleen on 10/02/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class LearningMatching3PairViewController: UIViewController {
    private let commandViewModal: LearningMatching3PairViewModel = LearningMatching3PairViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    
    private var isChildAction = false
  
    private var initialFrameOfDraggableView: CGRect?
    private var totalImagesMatched: Int = 0 {
        didSet {
            if self.totalImagesMatched == 3 {
                self.commandViewModal.calculateChildAction(state: true)
            }
        }
    }
    
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var avatarCenterImageView: FLAnimatedImageView!
    @IBOutlet weak var imageViewleft1:  ImageViewWithID!
    @IBOutlet weak var imageViewleft2:  ImageViewWithID!
    @IBOutlet weak var imageViewleft3:  ImageViewWithID!
    @IBOutlet weak var imageViewRight1:  ImageViewWithID!
    @IBOutlet weak var imageViewRight2:  ImageViewWithID!
    @IBOutlet weak var imageViewRight3:  ImageViewWithID!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        self.addGesture()
        if self.command_array.count == 0 {
            self.commandViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.commandViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    
    
}

//MARK:- Public Methods
extension LearningMatching3PairViewController {
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
extension LearningMatching3PairViewController {
    private func initializeFrame()
    {
        let centerY:CGFloat = ((self.view.frame.size.height-180)/2.0)
        let rightX:CGFloat = self.view.frame.size.width-200
        
        let boxSize:CGFloat = 180.0
        let deviceHeight:CGFloat = UIScreen.main.bounds.height
        let bottomPadding:CGFloat = 44
        
        imageViewleft1.frame = CGRect(x: 20, y: (deviceHeight/2) - boxSize - 40, width: boxSize, height: boxSize)
        imageViewleft2.frame = CGRect(x: 20, y: (deviceHeight/2)-20, width: boxSize, height: boxSize)
        imageViewleft3.frame = CGRect(x: 20, y: deviceHeight - boxSize - bottomPadding , width: boxSize, height: boxSize)
        
        imageViewRight1.frame = CGRect(x: rightX, y: (deviceHeight/2) - boxSize - 40, width: boxSize, height: boxSize)
        imageViewRight2.frame = CGRect(x: rightX, y: (deviceHeight/2)-20, width: boxSize, height: boxSize)
        imageViewRight3.frame = CGRect(x: rightX, y: deviceHeight - boxSize - bottomPadding, width: boxSize, height: boxSize)
    }
    
    private func customSetting() {
        self.initializeFrame()
        isChildAction = false
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  idleGif
        self.avatarCenterImageView.isHidden = true
        self.imageViewleft1.isHidden = true
        self.imageViewleft2.isHidden = true
        self.imageViewleft3.isHidden = true
        self.imageViewRight1.isHidden = true
        self.imageViewRight2.isHidden = true
        self.imageViewRight3.isHidden = true
        totalImagesMatched = 0
        self.initialFrameOfDraggableView = nil
    }
    
    private func addGesture() {
        let panGesture1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageViewRight1.addGestureRecognizer(panGesture1)
        
        let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageViewRight2.addGestureRecognizer(panGesture2)

        let panGesture3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageViewRight3.addGestureRecognizer(panGesture3)
    }
    
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if !isChildAction {
            return
        }
        print("handlePan Started===== ")

        if let currentImageView:ImageViewWithID = gestureRecognizer.view as? ImageViewWithID {
        switch gestureRecognizer.state {
        case .began:
            if self.initialFrameOfDraggableView == nil{
                self.initialFrameOfDraggableView = currentImageView.frame
            }
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            currentImageView.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
               // let dropLocation = gestureRecognizer.location(in: view)
//                if commandImgViewLeft.frame.contains(dropLocation) {
//                    isDragCompleted = true
//                    self.commandImgViewRight.frame = self.commandImgViewLeft.frame
//
//                } else {
//                    self.commandImgViewRight.frame = initialRightImageViewFrame
//                }
           // self.handleInvalidDropLocation(currentImageView: currentImageView)
            self.handlaDropLocation(gestureRecognizer: gestureRecognizer, currentImageView: currentImageView)
        default:break
        }
        }
    }
    
    private func handlaDropLocation(gestureRecognizer: UIPanGestureRecognizer,currentImageView:ImageViewWithID) {
        let dropLocation = gestureRecognizer.location(in: view)
        if let imodel = currentImageView.iModel {
            if let foundImageView = self.findMatchingImageView(id: imodel.id) {
                if foundImageView.frame.contains(dropLocation) {
                    currentImageView.frame = foundImageView.frame
                    self.totalImagesMatched += 1
                } else {
                    handleInvalidDropLocation(currentImageView: currentImageView)
                }
            }
        }
        self.initialFrameOfDraggableView = nil
        
        
    }
    
    private func findMatchingImageView(id:String) -> ImageViewWithID? {
        for subview in self.view.subviews {
            if let imageview = subview as? ImageViewWithID {
                if let commandinfo = imageview.commandInfo {
                    if commandinfo.value_idList.contains(id) {
                        return imageview
                    }
                }
            }
        }
        return nil
    }
    
    
    private func handleInvalidDropLocation(currentImageView:ImageViewWithID){
        DispatchQueue.main.async {
            if let frame = self.initialFrameOfDraggableView {
                currentImageView.frame = frame
            }
        }
    }
    
    
    private func listenModelClosures() {
        self.commandViewModal.waveAvatarClosure = {
             DispatchQueue.main.async {
                self.avatarCenterImageView.isHidden = false
                self.avatarCenterImageView.animatedImage =  hurrayGif
             }
        }
        
        self.commandViewModal.showSpeechTextClosure = { text in
             DispatchQueue.main.async {
                 self.speechTitle.text = text
             }
        }
        
        self.commandViewModal.talkAvatarClosure = {
              DispatchQueue.main.async {
                self.avatarCenterImageView.animatedImage =  talkingGif
              }
        }
        self.commandViewModal.hideAvatarClosure = {
               DispatchQueue.main.async {
                 self.avatarCenterImageView.isHidden = true
               }
        }
        
        self.commandViewModal.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
        
        self.commandViewModal.showImagesClosure = {commandInfo in
            DispatchQueue.main.async {
                var array:[ImageModel] = []
                for (index, element) in commandInfo.valueList.enumerated() {
                    var model = ImageModel.init()
                    model.id = commandInfo.value_idList[index]
                    model.image = element
                    array.append(model)
                }
                if self.imageViewleft1.isHidden {
                    self.imageViewleft1.isHidden = false
                    self.imageViewRight1.isHidden = false
                    self.imageViewleft1.iModel = array[0]
                    self.imageViewleft1.commandInfo = commandInfo
                    self.imageViewRight1.iModel = array[1]
                    self.imageViewleft1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + array[0].image)
                    self.imageViewRight1.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + array[1].image)
                } else if self.imageViewleft2.isHidden {
                    self.imageViewleft2.isHidden = false
                    self.imageViewRight2.isHidden = false
                    self.imageViewleft2.iModel = array[0]
                    self.imageViewleft2.commandInfo = commandInfo
                    self.imageViewRight2.iModel = array[1]
                    self.imageViewleft2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + array[0].image)
                    self.imageViewRight2.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + array[1].image)
                } else if self.imageViewleft3.isHidden {
                    self.imageViewleft3.isHidden = false
                    self.imageViewRight3.isHidden = false
                    self.imageViewleft3.iModel = array[0]
                    self.imageViewleft3.commandInfo = commandInfo
                    self.imageViewRight3.iModel = array[1]
                    self.imageViewleft3.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + array[0].image)
                    self.imageViewRight3.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + array[1].image)
                }
            }
        }
        
        self.commandViewModal.makeBiggerClosure = { questionInfo in
             DispatchQueue.main.async {
                if let imgview = self.findImageViewWith(id: questionInfo.value_id) {
                    self.makeBiggerAnimation(imageView: imgview, questionInfo: questionInfo) { (finished) in
                        self.commandViewModal.updateCurrentCommandIndex()
                    }
                }
             }
        }
        
        self.commandViewModal.makeImageNormalClosure = { questionInfo in
             DispatchQueue.main.async {
                if let imgview = self.findImageViewWith(id: questionInfo.value_id) {
                    self.normalImageAnimation(imageView: imgview, questionInfo: questionInfo) { (finished) in
                        self.commandViewModal.updateCurrentCommandIndex()
                    }
                }
             }
        }
        
        self.commandViewModal.blinkAllImagesClosure = { questionInfo in
            DispatchQueue.main.async {
                var imageviewArray: [UIImageView] = []
                for id in questionInfo.value_idList {
                    if let imgview = self.findImageViewWith(id: id) {
                        imageviewArray.append(imgview)
                    }
                }
                self.blinkAllImages(count:Int(learningAnimationDuration), imageviewArray: imageviewArray)
             }
        }
        
        self.commandViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                self.isChildAction = state
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
                            self.rightToleftAnimation(duration: duration-2)
                    }
                }
             }
        }
        
        self.commandViewModal.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
                 self.commandViewModal.updateCurrentCommandIndex()
             }
        }
         
   }
    
   
    private func findImageViewWith(id:String) -> ImageViewWithID? {
        for subview in self.view.subviews {
            if let imageview = subview as? ImageViewWithID {
                if imageview.iModel?.id == id {
                    return imageview
                }
            }
        }
        return nil
    }
    
    private func blinkAllImages(count: Int,imageviewArray: [UIImageView]) {
        if count == 0 {
            print("blinkAllImages Completed =====")
            self.commandViewModal.updateCurrentCommandIndex()
            return
        }
                UIView.animate(withDuration: 1, animations: {
                    for imageView in imageviewArray {
                        imageView.alpha = 0.2
                    }
                }) { [self] finished in
                    for imageView in imageviewArray {
                        imageView.alpha = 1
                    }
                    self.blinkAllImages(count: count - 1, imageviewArray: imageviewArray)
                }
    }
    
    
    
     
    private func rightToleftAnimation(duration:Int)
    {
        DispatchQueue.main.async {
            UIView.animate(withDuration: TimeInterval(duration*3), animations: {
                self.imageViewRight1.frame = self.imageViewleft1.frame
                self.imageViewRight2.frame = self.imageViewleft2.frame
                self.imageViewRight3.frame = self.imageViewleft3.frame
            }) {  finished in
              self.commandViewModal.updateCurrentCommandIndex()
            }
        }
     }
    
    
    private func makeBiggerAnimation(isLeft:Bool = true, imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(imageView)
        let initialW:CGFloat = imageView.frame.size.width
        var scaleSize:CGFloat = 0.0
        var diffC:CGFloat = 0.0
        if let option = questionInfo.option {
            scaleSize = CGFloat(option.larger_scale.floatValue)
            diffC = (initialW/2.0) * (scaleSize-1)
        }
        let initialC:CGFloat = imageView.center.x
        UIView.animate(withDuration: learningAnimationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            imageView.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize) // Scale your image
            if(isLeft == true) {
                imageView.center = CGPoint(x: initialC+diffC, y: imageView.center.y)
            } else {
                imageView.center = CGPoint(x: initialC-diffC, y: imageView.center.y)
            }
         }) { (finished) in
            completion(finished)
        }
        }
    }
        
    private func normalImageAnimation(isLeft:Bool = true, imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
        let initialW:CGFloat = imageView.frame.size.width
        let xScale:CGFloat = imageView.transform.a;
        let originalW:CGFloat = initialW/xScale
        let diffScale:CGFloat = xScale-1
        let diffC:CGFloat = (originalW/2.0) * diffScale
        UIView.animate(withDuration: learningAnimationDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            imageView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image
            if(isLeft == true) {
                imageView.center = CGPoint(x: imageView.center.x-diffC, y: imageView.center.y)
            } else {
                imageView.center = CGPoint(x: imageView.center.x+diffC, y: imageView.center.y)
            }
         }) { (finished) in
            completion(finished)
         }
        }
     }
    
    

 }

extension LearningMatching3PairViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}
