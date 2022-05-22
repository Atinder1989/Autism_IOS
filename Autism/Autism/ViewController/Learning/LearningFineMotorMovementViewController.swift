//
//  LearningFineMotorMovementViewController.swift
//  Autism
//
//  Created by Savleen on 19/01/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation
import ARKit

class LearningFineMotorMovementViewController: UIViewController {
    private let fineMotorViewModel: LearningFineMotorMovementViewModel = LearningFineMotorMovementViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []

    private var videoItem: VideoItem?
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0
           
    private var faceQuestionTypeTag:FaceTrackQuestionTypeTag = .none

    let configuration = ARFaceTrackingConfiguration()

    private var isChildAction = false {
        didSet{
            if isChildAction {
                self.sceneView.isHidden = !isChildAction
                sceneView.session.run(configuration)
            } else {
                sceneView.session.pause()
            }
        }
    }
    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bufferLoaderView: UIView!
    private var bufferLoaderTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneView.delegate = self
        self.addTapGesture()
        self.customSetting()
        if self.command_array.count == 0 {
            self.fineMotorViewModel.fetchLearningQuestion(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView = nil
        self.stopPlayer()
        self.hideBufferLoader()
    }
 
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.fineMotorViewModel.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.fineMotorViewModel.pausePlayer()
        self.fineMotorViewModel.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
//    @IBAction func skipLearningClicked(_ sender: Any) {
//        self.fineMotorViewModel.stopAllCommands()
//        self.fineMotorViewModel.skipLearningSubmitLearningMatchingAnswer()
//    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnStage(_:)))
        self.sceneView.addGestureRecognizer(tap)

    }
    
    @objc private func handleTapOnStage(_ sender: UITapGestureRecognizer? = nil) {
        if let s = sender {
            let location = s.location(in: sceneView)
            let results = sceneView.hitTest(location, options: nil)
            if let result = results.first,
              let node = result.node as? EmojiNode {
                if node.name == FaceTrackQuestionTypeTag.nose.getName() && faceQuestionTypeTag == .nose {
                  self.faceQuestionTypeTag = .none
                  self.isChildAction = false
                  self.fineMotorViewModel.calculateChildAction(state: true)
                }
            }
        }
    }

}

//MARK:- Public Methods
extension LearningFineMotorMovementViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.fineMotorViewModel.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)

        }
    }
}

//MARK:- Private Methods
extension LearningFineMotorMovementViewController {
    private func moveToNextCommand() {
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.fineMotorViewModel.updateCurrentCommandIndex()

    }
    
    private func customSetting() {
        self.sceneView.isHidden = true
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.bufferLoaderView.isHidden = true
    }
    
    
    private func listenModelClosures() {
        self.fineMotorViewModel.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.fineMotorViewModel.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.fineMotorViewModel.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
        self.fineMotorViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
            
        self.fineMotorViewModel.showVideoClosure = { urlString in
            DispatchQueue.main.async {
             self.customSetting()
             self.addPlayer(urlString: urlString)
            }
        }
        
       self.fineMotorViewModel.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
        
        self.fineMotorViewModel.childActionStateClosure = { state,commandInfo in
             DispatchQueue.main.async {
                self.isChildAction = state
                if let option = commandInfo.option {
                    if option.child_actions == "open_mouth" {
                        self.faceQuestionTypeTag = .mouth
                    } else if option.child_actions == "touch_nose" {
                        self.faceQuestionTypeTag = .nose
                    }
                }
                
             }
        }
        
       self.fineMotorViewModel.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
         
    }
       
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = fineMotorViewModel.playerController {
            if let avplayerController = playerController.avPlayerController {
                self.playerView.isHidden = false
                self.playerView.addSubview(avplayerController.view)
                avplayerController.view.frame = self.playerView.bounds
                self.videoItem = VideoItem.init(url: string)
                self.playVideo()
                self.thumbnailImage = Utility.getThumbnailImage(urlString: string, time: CMTimeMake(value: 5, timescale: 2))
            }
        }
    }
    
    private func showBufferLoader() {
        self.playerView.bringSubviewToFront(self.bufferLoaderView)

        self.bufferLoaderView.isHidden = false
        if let timer = self.bufferLoaderTimer {
            timer.invalidate()
        }
        self.bufferLoaderTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.2),
                        target: self,
                        selector: #selector(self.startBufferLoaderAnimation),
                        userInfo: nil, repeats: true)
    }

    @objc private func startBufferLoaderAnimation () {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {() -> Void in
                self.bufferLoaderView.transform = self.bufferLoaderView.transform.rotated(by: CGFloat(Double.pi))
            }, completion: {(_ finished: Bool) -> Void in
            })
        }
    }

    private func hideBufferLoader() {
        if let timer = self.bufferLoaderTimer {
            self.bufferLoaderView.isHidden = true
            timer.invalidate()
            self.bufferLoaderTimer = nil
        }
    }
    
    
    private func playVideo() {
        if let item = self.videoItem {
        fineMotorViewModel.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
      
    }
    
    @objc private func videoFinished() {
        self.restartButton.isHidden = false
        self.nextButton.isHidden = false

        if let image = self.thumbnailImage {
            self.thumnailImageView.image = image
            self.thumnailImageView.isHidden = false
        }
        self.initializeTimer()
    }
    
    func stopPlayer() {
        self.fineMotorViewModel.stopVideo()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.fineMotorViewModel.getCurrentCommandInfo(),let option = info.option {
            let time = Int(option.switch_command_time) ?? 0
            if self.videoFinishWaitingTime >= time  {
                self.moveToNextCommand()
            }
        }
    }
    
    private func stopTimer() {
        if let timer = self.videoFinishTimer {
            print("Video Timer Stop ======== ")
            timer.invalidate()
            self.videoFinishTimer = nil
            self.videoFinishWaitingTime = 0
        }
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        print("updateFeatures ===== ")
      for (feature, indices) in zip(features, featureIndices) {
        let child = node.childNode(withName: feature, recursively: false) as? EmojiNode
        let vertices = indices.map { anchor.geometry.vertices[$0] }
        child?.updatePosition(for: vertices)
          
        switch feature {
        case FaceTrackQuestionTypeTag.leftEye.getName():
          let scaleX = child?.scale.x ?? 1.0
          let eyeBlinkValue = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
          child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
        //  self.handleEyeBlink(value: eyeBlinkValue)
        case FaceTrackQuestionTypeTag.rightEye.getName():
          let scaleX = child?.scale.x ?? 1.0
          let eyeBlinkValue = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
          child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
         // self.handleEyeBlink(value: eyeBlinkValue)
        case FaceTrackQuestionTypeTag.mouth.getName():
          let jawOpenValue = anchor.blendShapes[.jawOpen]?.floatValue ?? 0.2
          child?.scale = SCNVector3(1.0, 0.8 + jawOpenValue, 1.0)
          if faceQuestionTypeTag == .mouth {
              if jawOpenValue > 0.6 {
                self.faceQuestionTypeTag = .none
                self.isChildAction = false
                self.fineMotorViewModel.calculateChildAction(state: true)
              }
          }
        default:
          break
        }
      }
    }
    

 }

extension LearningFineMotorMovementViewController: ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    guard let faceAnchor = anchor as? ARFaceAnchor,
          let device = sceneView.device else { return nil }
    let faceGeometry = ARSCNFaceGeometry(device: device)
    let node = SCNNode(geometry: faceGeometry)
    node.geometry?.firstMaterial?.fillMode = .lines
    
    node.geometry?.firstMaterial?.transparency = 0.0
    let noseNode = EmojiNode(with: noseOptions)
    noseNode.name = FaceTrackQuestionTypeTag.nose.getName()
    node.addChildNode(noseNode)
    
    let leftEyeNode = EmojiNode(with: eyeOptions)
    leftEyeNode.name = FaceTrackQuestionTypeTag.leftEye.getName()
    leftEyeNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(180.0))
    node.addChildNode(leftEyeNode)
    
    let rightEyeNode = EmojiNode(with: eyeOptions)
    rightEyeNode.name = FaceTrackQuestionTypeTag.rightEye.getName()
    node.addChildNode(rightEyeNode)
    
    let mouthNode = EmojiNode(with: mouthOptions)
    mouthNode.name = FaceTrackQuestionTypeTag.mouth.getName()
    node.addChildNode(mouthNode)
    
    let hatNode = EmojiNode(with: hatOptions)
    hatNode.name = FaceTrackQuestionTypeTag.hat.getName()
    node.addChildNode(hatNode)
    
    updateFeatures(for: node, using: faceAnchor)
    return node
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
    
    faceGeometry.update(from: faceAnchor.geometry)
    updateFeatures(for: node, using: faceAnchor)
  }
}


extension LearningFineMotorMovementViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


