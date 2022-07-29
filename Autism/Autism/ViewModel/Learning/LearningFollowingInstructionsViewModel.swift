//
//  LearningFollowingInstructionsViewModel.swift
//  Autism
//
//  Created by Savleen on 02/06/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import Foundation

class LearningFollowingInstructionsViewModel: NSObject {
    private var scriptManager: ScriptManager!
    var noNetWorkClosure: (() -> Void)?
    var showAvatarClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var clearScreenClosure : (() -> Void)?
    var showSpeechTextClosure : ((_ text: String) -> Void)?
    var talkAvatarClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var moveAvatarClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var showImageClosure  : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var blinkImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var childActionStateClosure : ((Bool) -> Void)?

   
    
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    
    var childActionDict :[String:Any] = [:]
    var childDetailArray :[[String:Any]] = []

    private var currentCommandIndex = 0 {
        didSet{
            self.executeCommand()
        }
    }
    
    private var commandResponseVO: ScriptResponseVO? = nil {
        didSet {
            self.executeCommand()
        }
    }
    
    private var isAnimationCommand = false
     
    override init() {
        super.init()
        scriptManager = ScriptManager.init(delegate: self)
        SpeechManager.shared.setDelegate(delegate: self)
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
    
  
    
    func updateCurrentCommandIndex() {
        isAnimationCommand = false
        if !SpeechManager.shared.isPlaying() {
            self.currentCommandIndex += 1
        }
    }
    
    func calculateChildAction(state:Bool){
        self.saveDataForSubmit()
        self.scriptManager.setChildActionState(state: state)
    }
        
    func fetchLearningQuestionCommands(skillDomainId: String,program: LearningProgramModel) {
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
    
    private func submitLearningMatchingAnswer() {
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
                ServiceParsingKeys.table_name.rawValue:self.program.table_name           ]
            LearningManager.submitLearningMatchingAnswer(parameters: parameters)
        }
        }
    }
    
    
    
    func stopAllCommands() {
        SpeechManager.shared.stopSpeech()
        SpeechManager.shared.setDelegate(delegate: nil)
        self.scriptManager.stopallTimer()
    }
}

extension LearningFollowingInstructionsViewModel {
    private func resetData() {
        self.commandResponseVO = nil
        self.currentCommandIndex = 0
        self.isAnimationCommand = false
        self.childDetailArray.removeAll()
        self.childActionDict.removeAll()
    }
    
    private func executeCommand() {
        if let commandResponseVO = self.commandResponseVO  {
            if commandResponseVO.command_array.count > 0 {
                if currentCommandIndex < commandResponseVO.command_array.count {
                print("currentCommandIndex === \(currentCommandIndex)")
                    let commandInfo = commandResponseVO.command_array[self.currentCommandIndex]
                    self.scriptManager.executeCommand(commandInfo: commandInfo)
                } else {
                    print("Command Array Completed")
                    self.submitLearningMatchingAnswer()
                }
            }
        }
    }
    
    
    private func initializeEmptyDataDictionary(info:ScriptCommandInfo) {
        self.childActionDict.removeAll()
        childActionDict = [
            ServiceParsingKeys.id.rawValue:info.id,
            ServiceParsingKeys.complete_rate.rawValue:0,
            ServiceParsingKeys.time_taken.rawValue:0,
            ServiceParsingKeys.isDragStarted.rawValue:false,
            ServiceParsingKeys.isFaceDetected.rawValue:false,
            ServiceParsingKeys.value.rawValue:info.value,
            ServiceParsingKeys.attemptLevel.rawValue:0
        ]
    }
    
    private func saveDataForSubmit() {
        if let info = self.scriptManager.getChildActionCommandInfo() {
            if let option = info.option {
            childActionDict = [
                ServiceParsingKeys.id.rawValue:info.id,
                ServiceParsingKeys.complete_rate.rawValue:option.complete_percentage,
                ServiceParsingKeys.time_taken.rawValue:self.scriptManager.getTimeTaken(),
                ServiceParsingKeys.isFaceDetected.rawValue:false,
                ServiceParsingKeys.value.rawValue:info.value,
            ]
            }
        }
        childActionDict[ServiceParsingKeys.attemptLevel.rawValue] = self.scriptManager.getChildActionLevel()
        self.childDetailArray.append(childActionDict)
    }
    
    private func handleAvatarCommand(commandInfo:ScriptCommandInfo) {
        if commandInfo.condition == ScriptCommandConditionType.no.rawValue {
            if let option = commandInfo.option {
                if option.avatar_variation == ScriptCommandOptionType.show_avatar.rawValue {
                    if let closure = self.showAvatarClosure {
                        closure(commandInfo)
                    }
                } else if option.avatar_variation == ScriptCommandOptionType.talk_avatar.rawValue {
                    if let closure = self.talkAvatarClosure {
                        closure(commandInfo)
                    }
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
        
        if let user = UserManager.shared.getUserInfo() {
            message = message.replacingOccurrences(of: "(child_name)", with: Utility.deCrypt(text: user.nickname))
        }
        
        SpeechManager.shared.setDelegate(delegate: self)//Speech Issue
        SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func handleMoveAvatarCommand(commandInfo:ScriptCommandInfo) {
        isAnimationCommand = true
        if let closure = self.moveAvatarClosure {
            closure(commandInfo)
        }
    }
    
    private func handleShowImageCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.showImageClosure {
            closure(commandInfo)
        }
    }
    
    private func handleBlinkImageCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.blinkImageClosure {
            closure(commandInfo)
        }
    }
    
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
    
}


// MARK: Speech Manager Delegate Methods
extension LearningFollowingInstructionsViewModel: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        
        if let _ = self.scriptManager.getSequenceCommandInfo() {
            self.scriptManager.updateSequenceCommandIndex()
            return
        }
        
        if !self.isAnimationCommand {
            if self.scriptManager.getIsCommandCompleted() {
                self.currentCommandIndex += 1
            }
        }
    }
    
    func speechDidStart(speechText:String) {
        if let closure = self.showSpeechTextClosure {
            closure(speechText)
        }
    }
}


extension LearningFollowingInstructionsViewModel: ScriptManagerDelegate {
    func get(scriptCommand: ScriptCommand) {
        switch scriptCommand {
        case .text_to_speech(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleTextToSpeechCommand(commandInfo: info)
            }
            break
        case .show_image(commandInfo:  let commandInfo):
            if let info = commandInfo {
                self.handleShowImageCommand(commandInfo: info)
            }
            break
        case .avatar(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleAvatarCommand(commandInfo: info)
            }
            break
        case .move_avatar(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleMoveAvatarCommand(commandInfo: info)
            }
            break
        case .blink_image(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleBlinkImageCommand(commandInfo: info)
            }
        case .child_actionStarted(commandInfo: let commandInfo):
            self.handleChildActionState(state: true, commandInfo: commandInfo)
        case .child_actionEnded:
            self.handleChildActionState(state: false, commandInfo: nil)
        case .clear_screen:
            self.handleClearScreenCommand()
        case .commandCompleted:
            if !isAnimationCommand && !SpeechManager.shared.isPlaying() {
                print("Delegate ===== Command Complete ##################### ")
                self.updateCurrentCommandIndex()
            }
        default:
            break
        }
    }
}


