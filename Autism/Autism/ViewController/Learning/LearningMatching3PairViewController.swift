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
    private var isChildAction1 = false
    private var isChildAction2 = false
    private var isChildAction3 = false
  
    private var initialFrameOfDraggableView: CGRect?
    private var noOfImages: Int = 3
    private var totalImagesMatched: Int = 0 {
        didSet {
            if self.totalImagesMatched == noOfImages {
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

    private var frameImageViewRight1: CGRect = .zero
    private var frameImageViewRight2: CGRect = .zero
    private var frameImageViewRight3: CGRect = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        self.addGesture()
        if self.command_array.count == 0 {
            self.commandViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.commandViewModal.stopAllCommands()
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
        var wh:CGFloat = 180
        var yRef:CGFloat = 180
        var ySpace:CGFloat = 40
        let xSpace:CGFloat = 60
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            yRef = 80
            wh = 70
            ySpace = 10
        }
        
        imageViewleft1.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        imageViewRight1.frame = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)
        
        yRef = yRef+wh+ySpace
        
        imageViewleft2.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        imageViewRight2.frame = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)

        yRef = yRef+wh+ySpace
        
        imageViewleft3.frame = CGRect(x: xSpace, y: yRef, width: wh, height: wh)
        imageViewRight3.frame = CGRect(x: UIScreen.main.bounds.width-wh-xSpace, y: yRef, width: wh, height: wh)

        yRef = yRef+wh+ySpace

        
        frameImageViewRight1 = imageViewRight1.frame
        frameImageViewRight2 = imageViewRight2.frame
        frameImageViewRight3 = imageViewRight3.frame
        
    }
    
    private func customSetting() {
        self.initializeFrame()
        isChildAction = false
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  getIdleGif()
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
            
            if(self.isChildAction1 == true && currentImageView != self.imageViewRight1) {
                return
            }
            if(self.isChildAction2 == true && currentImageView != self.imageViewRight2) {
                return
            }
            if(self.isChildAction3 == true && currentImageView != self.imageViewRight3) {
                return
            }
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
            if (currentImageView == self.imageViewRight1) {
                self.imageViewRight1.frame = self.frameImageViewRight1
            } else if (currentImageView == self.imageViewRight2) {
                self.imageViewRight2.frame = self.frameImageViewRight2
            } else if (currentImageView == self.imageViewRight3) {
                self.imageViewRight3.frame = self.frameImageViewRight3
            }
        }
    }
    
    
    private func listenModelClosures() {
        self.commandViewModal.waveAvatarClosure = {
             DispatchQueue.main.async {
                self.avatarCenterImageView.isHidden = false
                self.avatarCenterImageView.animatedImage =  getHurrayGif()
             }
        }
        
        self.commandViewModal.showSpeechTextClosure = { text in
             DispatchQueue.main.async {
                 self.speechTitle.text = text
             }
        }
        
        self.commandViewModal.talkAvatarClosure = {
              DispatchQueue.main.async {
                self.avatarCenterImageView.animatedImage =  getTalkingGif()
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
        
        self.commandViewModal.childActionStateClosure = { state, questionInfo in
             DispatchQueue.main.async {
                self.isChildAction = state
//                 self.isChildAction1 = state
                 if let imgview = self.findImageViewWith(id: questionInfo?.value_id ?? "") {
                     self.isChildAction = state
                     self.noOfImages = 1

                     self.isChildAction1 = false
                     self.isChildAction2 = false
                     self.isChildAction3 = false

                     if(imgview == self.imageViewRight1) {
                         self.totalImagesMatched = 0
                         self.isChildAction1 = state
                     } else if(imgview == self.imageViewRight2) {
                         self.totalImagesMatched = 0
                         self.isChildAction2 = state
                     } else if(imgview == self.imageViewRight3) {
                         self.totalImagesMatched = 0
                         self.isChildAction3 = state
                     }
                 } else {
                     if(state == true) {
                         self.noOfImages = 3
                         self.isChildAction = state
                         self.isChildAction1 = false
                         self.isChildAction2 = false
                         self.isChildAction3 = false
                     }
                 }
              }
        }
        
        self.commandViewModal.startDragAnimationClosure = { questionInfo in
            DispatchQueue.main.async {
                
                if let imgview = self.findImageViewWith(id: questionInfo.value_id) {
                    if let option = questionInfo.option {
                        if  option.drag_direction == ScriptCommandOptionType.right_to_left.rawValue  {
                            var duration = 0
                            if option.time_in_second.count > 0 {
                                duration = Int(option.time_in_second) ?? 0
                            }
                            self.rightToleftAnimation(duration: duration-2, imageView:imgview)
                        }
                    }
                } else {
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
    
    
    private func rightToleftAnimation(duration:Int, imageView:UIImageView)
    {
        DispatchQueue.main.async {
            UIView.animate(withDuration: TimeInterval(duration*3), animations: {
                if(imageView == self.imageViewRight1) {
                    self.imageViewRight1.frame = self.imageViewleft1.frame
                }
                if(imageView == self.imageViewRight2) {
                    self.imageViewRight2.frame = self.imageViewleft2.frame
                }
                if(imageView == self.imageViewRight3) {
                    self.imageViewRight3.frame = self.imageViewleft3.frame
                }
                
            }) {  finished in
              self.commandViewModal.updateCurrentCommandIndex()
            }
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
