//
//  AssessmentFaceTrackingViewController.swift
//  Autism
//
//  Created by Savleen on 10/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import ARKit

enum FaceTrackQuestionTypeTag: Int {
    case mouth = 1
    case nose = 2
    case eye = 3
    case leftEye = 4
    case rightEye = 5
    case hat = 6
    case none = 0
    
    func getName() -> String {
        switch self {
        case .mouth:
            return "mouth"
        case .nose:
            return "nose"
        case .eye:
            return "eyes"
        case .leftEye:
            return "leftEye"
        case .rightEye:
            return "rightEye"
        case .hat:
            return "hat"
        case .none:
            return "none"
        }
    }
}

class AssessmentFaceTrackingViewController: UIViewController {

  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet var questionTitle: UILabel!

  private var faceTrackingQuestionInfo: FaceTrackingQuestionInfo!
  private weak var delegate: AssessmentSubmitDelegate?
  private var questionState: QuestionState = .inProgress
  private var timeTakenToSolve = 0
  private var touchOnEmptyScreenCount = 0

  private var faceTrackingViewModel = AssessmentFaceTrackingViewModel()
  private var faceQuestionTypeTag:FaceTrackQuestionTypeTag = .none
    
  override func viewDidLoad() {
    super.viewDidLoad()
    if Utility.sharedInstance.isARFaceTrackingConfigurationOnCurrentDevice() {
        self.listenModelClosures()
        self.customSetting()
        sceneView.delegate = self
    }
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARFaceTrackingConfiguration()
    sceneView.session.run(configuration)
  }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
  
  func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
    for (feature, indices) in zip(features, featureIndices) {
      let child = node.childNode(withName: feature, recursively: false) as? EmojiNode
      let vertices = indices.map { anchor.geometry.vertices[$0] }
      child?.updatePosition(for: vertices)
        
      switch feature {
      case FaceTrackQuestionTypeTag.leftEye.getName():
        let scaleX = child?.scale.x ?? 1.0
        let eyeBlinkValue = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
        self.handleEyeBlink(value: eyeBlinkValue)
      case FaceTrackQuestionTypeTag.rightEye.getName():
        let scaleX = child?.scale.x ?? 1.0
        let eyeBlinkValue = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
        child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
        self.handleEyeBlink(value: eyeBlinkValue)
      case FaceTrackQuestionTypeTag.mouth.getName():
        let jawOpenValue = anchor.blendShapes[.jawOpen]?.floatValue ?? 0.2
        child?.scale = SCNVector3(1.0, 0.8 + jawOpenValue, 1.0)
        if faceQuestionTypeTag == .mouth {
            if jawOpenValue > 0.6 {
                if self.questionState != .submit {
                self.moveToNextQuestion(message: SpeechMessage.hurrayGoodJob.rawValue)
                }
            }
        }
      default:
        break
      }
    }
  }
  
  @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
    let location = sender.location(in: sceneView)
    let results = sceneView.hitTest(location, options: nil)
    if let result = results.first,
      let node = result.node as? EmojiNode {
        if node.name == FaceTrackQuestionTypeTag.nose.getName() && faceQuestionTypeTag == .nose {
            if self.questionState != .submit {
                self.moveToNextQuestion(message: SpeechMessage.hurrayGoodJob.rawValue)
            }
        }

        //node.next()
    }
  }
}

extension AssessmentFaceTrackingViewController: ARSCNViewDelegate {
  
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


// MARK: Private Methods
extension AssessmentFaceTrackingViewController {
    private func handleEyeBlink(value:Float) {
           if faceQuestionTypeTag == .eye {
                      if value > 0.6 {
                          if self.questionState != .submit {
                          self.moveToNextQuestion(message: SpeechMessage.hurrayGoodJob.rawValue)
                          }
                      }
           }
    }
    
    private func listenModelClosures() {
              self.faceTrackingViewModel.dataClosure = {
                        DispatchQueue.main.async {
                            if let res = self.faceTrackingViewModel.accessmentSubmitResponseVO {
                                if res.success {
                                    self.dismiss(animated: true) {
                                        if let del = self.delegate {
                                            Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
                                             del.submitQuestionResponse(response: res)
                                        }
                                    }
                                }
                            }
                        }
               }
    }
    
    private func customSetting() {
        self.questionTitle.text = self.faceTrackingQuestionInfo.question_title
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message: self.faceTrackingQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        if let answer = Int(self.faceTrackingQuestionInfo.correct_answer) {
            self.faceQuestionTypeTag = FaceTrackQuestionTypeTag.init(rawValue: answer)!
        }
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
       
       private func moveToNextQuestion(message:String) {
           self.stopTimer()
           self.questionState = .submit
           SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
       }
       
       @objc private func calculateTimeTaken() {
           self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1

        if self.timeTakenToSolve >= self.faceTrackingQuestionInfo.completion_time  {
               self.moveToNextQuestion(message: SpeechMessage.moveForward.getMessage())
            return
        }
        
        if trailPromptTimeForUser == faceTrackingQuestionInfo.trial_time && self.timeTakenToSolve < faceTrackingQuestionInfo.completion_time {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: self.faceTrackingQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
        
       }
       
      private func stopTimer() {
        AutismTimer.shared.stopTimer()
      }
    
}

// MARK: Public Methods
extension AssessmentFaceTrackingViewController {
    func setFaceTrackingQuestionInfo(info:FaceTrackingQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.faceTrackingQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentFaceTrackingViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.faceTrackingViewModel.submitFaceTrackDetails(info: self.faceTrackingQuestionInfo, timetaken: self.timeTakenToSolve, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            break
        default:
            break
        }
    }
    func speechDidStart(speechText:String) {
    }
}

extension AssessmentFaceTrackingViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
//            if(self.apiDataState == .notCall) {
//                self.listenModelClosures()
//            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentFaceTrackingViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
