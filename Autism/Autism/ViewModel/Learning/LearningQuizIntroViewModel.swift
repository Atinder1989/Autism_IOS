//
//  LearningQuizIntroViewModel.swift
//  Autism
//
//  Created by Dilip Saket on 21/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation
import AVKit

class LearningQuizIntroViewModel: NSObject {
    private var scriptManager: ScriptManager!
 

    var showSpeechTextClosure : ((_ text: String) -> Void)?
    var clearSpeechTextClosure : (() -> Void)?
    var resetDataClosure : (() -> Void)?
    var noNetWorkClosure: (() -> Void)?
    var clearScreenClosure : (() -> Void)?
    var showVideoClosure : ((_ urlString:String) -> Void)?
    //var showImageClosure  : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    //var blinkImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var talkAvatarClosure : (() -> Void)?
    var showAvatarClosure : (() -> Void)?

    var idleAvatarClosure : (() -> Void)?
    var childActionStateClosure : ((Bool) -> Void)?
    
    var bufferLoaderClosure : (() -> Void)?
    var videoFinishedClosure : (() -> Void)?
    var playerController: PlayerController?

   // private var isAvatar : Bool = false
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var childActionDict :[String:Any] = [:]
    private var childDetailArray :[[String:Any]] = []
    

    
    private var commandResponseVO: ScriptResponseVO? = nil {
        didSet {
            self.executeCommand()
        }
    }
    private var currentCommandIndex = 0 {
        didSet{
            self.executeCommand()
        }
    }
    
    private var currentCommandInfo:ScriptCommandInfo?
    private var isAnimationCommand = false

    override init() {
        super.init()
        scriptManager = ScriptManager.init(delegate: self)
        SpeechManager.shared.setDelegate(delegate: self)
        playerController = PlayerController.init()
        if let controller = self.playerController {
            controller.initializePlayer(delegate: self)
        }
    }
    
    var isBufferLoader: Bool = false {
        didSet {
            if let bufferLoader = self.bufferLoaderClosure {
                bufferLoader()
            }
        }
    }
    func seekToTimePlayer(time: CMTime) {
        if let controller = self.playerController {
            controller.seekToTimeVideoPlayer(time: time)
        }
    }
    
    func playVideo(item: VideoItem) {
        if let controller = self.playerController {
            controller.playVideo(item: item)
        }
    }
    
    func pausePlayer() {
        if let controller = self.playerController {
            controller.playPauseCommandToPlayer()
        }
    }
    
    func stopVideo() {
        if let controller = self.playerController {
            controller.stopVideo()
        }
    }
    
    
    func fetchLearningQuestion(skillDomainId: String,program: LearningProgramModel) {
        
        self.skillDomainId = skillDomainId
        self.program = program
        
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                noNetwork()
            }
            return
        }
        
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getLearningQuestionUrl()
        if let user = UserManager.shared.getUserInfo() {
           service.params = [
            ServiceParsingKeys.user_id.rawValue:user.id,
            ServiceParsingKeys.skill_domain_id.rawValue:self.skillDomainId!,
            ServiceParsingKeys.program_id.rawValue:self.program.program_id,
            ServiceParsingKeys.language_code.rawValue:user.languageCode,
          ]
        }
        ServiceManager.processDataFromServer(service: service, model: ScriptResponseVO.self) { (responseVo, error) in
            if let _ = error {
                 self.commandResponseVO = nil
            } else {
                if let response = responseVo {
                    DispatchQueue.main.async {
                    if response.success {
                        self.commandResponseVO = response
                    } else {
                        
                        Utility.showAlert(title: "Information", message: "Learning Work under progress")
                        UserManager.shared.exitAssessment()
                    }
                    }
                }
            }
        }
    }
    
    func setScriptResponse(command_array:[ScriptCommandInfo],questionid:String,program: LearningProgramModel,skillDomainId: String) {
        self.program = program
        self.skillDomainId = skillDomainId
        var response = ScriptResponseVO.init()
        response.success = true
        response.statuscode = 200
        response.message = ""
        response.command_array = command_array
        response.question_id = questionid
        self.commandResponseVO = response
    }
    
    func getCurrentCommandInfo() -> ScriptCommandInfo? {
        return self.currentCommandInfo
    }
   
    func updateCurrentCommandIndex() {
        isAnimationCommand = false
        if !SpeechManager.shared.isPlaying() {
            self.currentCommandIndex += 1
        }
    }
      
    func calculateChildAction(state:Bool){
        isAnimationCommand = false
        self.saveDataForSubmit()
        self.scriptManager.setChildActionState(state: state)
    }
    
    func handleUserAnswer(text:String) {
        if let info = self.scriptManager.getChildActionCommandInfo() {
            if Utility.sharedInstance.isAnswerMatched(text: text, answer: info.value) {
                
               self.calculateChildAction(state: true)
            } else {
                saveDataForSubmit(isAnswerMatched: false)
                if let closure = self.clearSpeechTextClosure {
                    closure()
                }
                if let closure = self.childActionStateClosure {
                    closure(true)
                }
                
            }
        }
    }
    
    func stopAllCommands() {
        SpeechManager.shared.stopSpeech()
        SpeechManager.shared.setDelegate(delegate: nil)
        RecordingManager.shared.stopRecording()
        self.scriptManager.stopallTimer()
    }
    
    
     func skipLearningSubmitLearningMatchingAnswer() {
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                noNetwork()
            }
            return
        }
        if let res = self.commandResponseVO {
        if let user = UserManager.shared.getUserInfo() {
            var tempArray :[[String:Any]] = []
            var dict :[String:Any] = [:]
            dict = [
                //ServiceParsingKeys.id.rawValue:info.id,
                ServiceParsingKeys.complete_rate.rawValue:100,
                ServiceParsingKeys.time_taken.rawValue:2,
                ServiceParsingKeys.isDragStarted.rawValue:false,
                ServiceParsingKeys.isFaceDetected.rawValue:false,
               // ServiceParsingKeys.value.rawValue:info.value,
                ServiceParsingKeys.attemptLevel.rawValue:0
            ]
            tempArray.append(dict)
            let parameters: [String : Any] = [
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.skill_domain_id.rawValue:self.skillDomainId!,
                ServiceParsingKeys.program_id.rawValue:self.program.program_id,
                ServiceParsingKeys.question_id.rawValue:res.question_id,
                ServiceParsingKeys.childDetail.rawValue:tempArray,
                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
                
                //NewDevelopment
                ServiceParsingKeys.content_type.rawValue:self.program.content_type,
                ServiceParsingKeys.course_type.rawValue:self.program.course_type,
                ServiceParsingKeys.level.rawValue:self.program.level,
                ServiceParsingKeys.bucket.rawValue:self.program.bucket,
                ServiceParsingKeys.table_name.rawValue:self.program.table_name                ]

            LearningManager.submitLearningMatchingAnswer(parameters: parameters)
        }
        }
    }
    
}

extension LearningQuizIntroViewModel {
    private func resetData() {
        self.isAnimationCommand = false
        self.currentCommandInfo = nil
    }
   
    private func executeCommand() {
        if let commandResponseVO = self.commandResponseVO  {
            if commandResponseVO.command_array.count > 0 {
                if currentCommandIndex < commandResponseVO.command_array.count {
                print("currentCommandIndex === \(currentCommandIndex)")
                    self.resetData()
                    let commandInfo = commandResponseVO.command_array[self.currentCommandIndex]
                        self.scriptManager.executeCommand(commandInfo: commandInfo)
                } else {
                    print("Command Array Completed")
//                    self.submitLearningMatchingAnswer()
                }
            }
        }
    }
    
    //private
    func submitLearningMatchingAnswer() {
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                noNetwork()
            }
            return
        }
        if let res = self.commandResponseVO {
        if let user = UserManager.shared.getUserInfo() {
            var CR = "0"
            
            if(self.childDetailArray.count > 0) {
                let lastAction:[String:Any] = self.childDetailArray.last!
                CR = lastAction[ServiceParsingKeys.complete_rate.rawValue] as? String ?? ""
                if(CR == "") {
                    CR = String(lastAction[ServiceParsingKeys.complete_rate.rawValue] as? Int ?? 0)
                }
            }
            
            let parameters: [String : Any] = [
            
                ServiceParsingKeys.complete_rate.rawValue:CR as Any,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.skill_domain_id.rawValue:self.skillDomainId!,
                ServiceParsingKeys.program_id.rawValue:self.program.program_id,
                ServiceParsingKeys.question_id.rawValue:res.question_id,
                ServiceParsingKeys.childDetail.rawValue:self.childDetailArray,
                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
                //NewDevelopment
                ServiceParsingKeys.content_type.rawValue:self.program.content_type,
                ServiceParsingKeys.course_type.rawValue:self.program.course_type,
                ServiceParsingKeys.level.rawValue:self.program.level,
                ServiceParsingKeys.bucket.rawValue:self.program.bucket,
                ServiceParsingKeys.table_name.rawValue:self.program.table_name

                ]
            LearningManager.submitLearningMatchingAnswer(parameters: parameters)
        }
        }
    }
      
    private func handleShowVideoCommand(commandInfo:ScriptCommandInfo) {
        self.currentCommandInfo = commandInfo
        isAnimationCommand = true
        if let closure = self.showVideoClosure {
            closure(commandInfo.value)
        }
    }
    
    private func handleAvatarCommand(commandInfo:ScriptCommandInfo) {

            if let option = commandInfo.option {
                if option.avatar_variation == ScriptCommandOptionType.show_avatar.rawValue {
                  //  isAvatar = true
                    if let closure = self.showAvatarClosure {
                        closure()
                    }
                }
            }
    }
        
    private func handleTextToSpeechCommand(commandInfo:ScriptCommandInfo) {
        var message = commandInfo.value
        if let option = commandInfo.option {
            if option.variables_text == ScriptCommandOptionType.child_name.rawValue {
                if let user = UserManager.shared.getUserInfo() {
                    message =  message + " \(Utility.deCrypt(text: user.nickname))"
                }
            }
        }
        SpeechManager.shared.setDelegate(delegate: self)//Speech Issue
        SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    

    
//    private func handleBlinkImageCommand(commandInfo:ScriptCommandInfo) {
//        isAnimationCommand = true
//        if let closure = self.blinkImageClosure {
//            closure(commandInfo)
//        }
//    }
    
    private func handleChildActionState(state:Bool,commandInfo:ScriptCommandInfo?) {
        if state {
            if let info = commandInfo {
                self.initializeEmptyDataDictionary(info: info)
            }
        }
        if let closure = self.childActionStateClosure {
            closure(state)
        }
    }
    
    private func handleClearScreenCommand() {
        if let closure = self.clearScreenClosure {
            closure()
        }
    }
    
    private func initializeEmptyDataDictionary(info:ScriptCommandInfo) {
        self.childActionDict.removeAll()
        childActionDict = [
            ServiceParsingKeys.id.rawValue:info.id,
            ServiceParsingKeys.complete_rate.rawValue:0,
            ServiceParsingKeys.time_taken.rawValue:0,
            //ServiceParsingKeys.touch.rawValue:false,
            ServiceParsingKeys.isFaceDetected.rawValue:false,
            ServiceParsingKeys.value.rawValue:info.value,
            ServiceParsingKeys.attemptLevel.rawValue:0
        ]
    }
    
    private func saveDataForSubmit(isAnswerMatched:Bool = true) {
        if let info = self.scriptManager.getChildActionCommandInfo() {
            if let option = info.option {
                let completePercentage = isAnswerMatched ? option.complete_percentage : "0"
            childActionDict = [
                ServiceParsingKeys.id.rawValue:info.id,
                ServiceParsingKeys.complete_rate.rawValue:completePercentage,
                ServiceParsingKeys.time_taken.rawValue:self.scriptManager.getTimeTaken(),
                //ServiceParsingKeys.touch.rawValue:touch,
                ServiceParsingKeys.isFaceDetected.rawValue:false,
                ServiceParsingKeys.value.rawValue:info.value,
            ]
            }
        }
        childActionDict[ServiceParsingKeys.attemptLevel.rawValue] = self.scriptManager.getChildActionLevel()
        self.childDetailArray.append(childActionDict)
    }
}

// MARK: Speech Manager Delegate Methods
extension LearningQuizIntroViewModel: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
            if let closure = self.idleAvatarClosure {
                closure()
            }
        
        if !self.isAnimationCommand {
            if let _ = self.scriptManager.getSequenceCommandInfo() {
                self.scriptManager.updateSequenceCommandIndex()
                return
            }
            if self.scriptManager.getIsCommandCompleted() {
                self.currentCommandIndex += 1
            }
        }
    }
    
    func speechDidStart(speechText:String) {
            if let closure = self.talkAvatarClosure {
                closure()
            }
        if let closure = self.showSpeechTextClosure {
            closure(speechText)
        }
    }
}


extension LearningQuizIntroViewModel: ScriptManagerDelegate {
    func get(scriptCommand: ScriptCommand) {
        switch scriptCommand {
        case .avatar(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleAvatarCommand(commandInfo: info)
            }
            break
        case .show_video(commandInfo:  let commandInfo):
            if let info = commandInfo {
                self.handleShowVideoCommand(commandInfo: info)
            }
            break
        
        case .text_to_speech(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleTextToSpeechCommand(commandInfo: info)
            }
            break
//        case .blink_image(commandInfo: let commandInfo):
//            if let info = commandInfo {
//                self.handleBlinkImageCommand(commandInfo: info)
//            }

        case .commandCompleted:
            if !isAnimationCommand && !SpeechManager.shared.isPlaying() {
                print("Delegate ===== Command Complete ##################### ")
                self.updateCurrentCommandIndex()
            }
        case .child_actionStarted(commandInfo: let commandInfo):
            self.handleChildActionState(state: true, commandInfo: commandInfo)
        case .child_actionEnded:
            self.handleChildActionState(state: false, commandInfo: nil)
        case .clear_screen:
            self.handleClearScreenCommand()
        case .moveToNextCommand:
            self.updateCurrentCommandIndex()
        default:
            break
        }
    }

}


// MARK: - PlayerController Delegate
extension LearningQuizIntroViewModel: PlayerControllerDelegate {
    func didChangeJTPlayerStatus(status: VideoPlayerStatus) {
        switch status {
        case .playbackLikelyToKeepUp:
            self.isBufferLoader = false
        case .readyToPlay:
            self.isBufferLoader = false
        case .reachedToEnd:
            if let closure = self.videoFinishedClosure {
                closure()
            }
        case .bufferEmpty:
            self.isBufferLoader = true
        default:
            break
        }
    }
}
