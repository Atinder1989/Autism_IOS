//
//  LearningEyeContactViewModel.swift
//  Autism
//
//  Created by Savleen on 29/03/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import Foundation

class LearningEyeContactViewModel: NSObject {
    private var scriptManager: ScriptManager!
    var showSpeechTextClosure : ((_ text: String) -> Void)?
    var clearSpeechTextClosure : (() -> Void)?
    var clearScreenClosure : (() -> Void)?
    var showAvatarClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var talkAvatarClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var hideAvatarClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var noNetWorkClosure: (() -> Void)?
    
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
        if !SpeechManager.shared.isPlaying() {
            self.currentCommandIndex += 1
        }
    }
    
//    func calculateChildAction(state:Bool, isDragStarted:Bool){
//        self.saveDataForSubmit(isDragStarted: isDragStarted)
//        self.scriptManager.setChildActionState(state: state)
//    }
        
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
            let parameters: [String : Any] = [
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.skill_domain_id.rawValue:self.skillDomainId!,
                ServiceParsingKeys.program_id.rawValue:self.program.program_id,
                ServiceParsingKeys.question_id.rawValue:res.question_id,
                ServiceParsingKeys.childDetail.rawValue:self.childDetailArray,
                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
           ]
            LearningManager.submitLearningMatchingAnswer(parameters: parameters)
        }
        }
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
           ]
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

extension LearningEyeContactViewModel {
    private func resetData() {
        self.commandResponseVO = nil
        self.currentCommandIndex = 0
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
                    //self.submitLearningMatchingAnswer()
                }
            }
        }
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
                } else if option.avatar_variation == ScriptCommandOptionType.hide_avatar.rawValue {
                    if let closure = self.hideAvatarClosure {
                        closure(commandInfo)
                    }
                }
                self.updateCurrentCommandIndex()
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
    
    private func saveDataForSubmit(isDragStarted:Bool) {
        if let info = self.scriptManager.getChildActionCommandInfo() {
            if let option = info.option {
            childActionDict = [
                ServiceParsingKeys.id.rawValue:info.id,
                ServiceParsingKeys.complete_rate.rawValue:option.complete_percentage,
                ServiceParsingKeys.time_taken.rawValue:self.scriptManager.getTimeTaken(),
                ServiceParsingKeys.isDragStarted.rawValue:isDragStarted,
                ServiceParsingKeys.isFaceDetected.rawValue:false,
                ServiceParsingKeys.value.rawValue:info.value,
            ]
            }
        }
        childActionDict[ServiceParsingKeys.attemptLevel.rawValue] = self.scriptManager.getChildActionLevel()
        self.childDetailArray.append(childActionDict)
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
    
    private func handleClearScreenCommand() {
        if let closure = self.clearScreenClosure {
            closure()
        }
    }
    
}


// MARK: Speech Manager Delegate Methods
extension LearningEyeContactViewModel: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
//        if let closure = self.clearSpeechTextClosure {
//            closure()
//        }
            if self.scriptManager.getIsCommandCompleted() {
                self.currentCommandIndex += 1
            }
    }
    
    func speechDidStart(speechText:String) {
        if let closure = self.showSpeechTextClosure {
            closure(speechText)
        }
    }
}


extension LearningEyeContactViewModel: ScriptManagerDelegate {
    func get(scriptCommand: ScriptCommand) {
        switch scriptCommand {
        case .text_to_speech(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleTextToSpeechCommand(commandInfo: info)
            }
            break
        case .avatar(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleAvatarCommand(commandInfo: info)
            }
            break
        case .clear_screen:
            self.handleClearScreenCommand()
        case .commandCompleted:
            if !SpeechManager.shared.isPlaying() {
                print("Delegate ===== Command Complete ##################### ")
            }
        default:
            break
        }
    }
}


