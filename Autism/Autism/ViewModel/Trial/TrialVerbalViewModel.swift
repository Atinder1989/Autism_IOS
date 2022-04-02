//
//  TrialVerbalViewModel.swift
//  Autism
//
//  Created by Dilip Technology on 28/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class TrialVerbalViewModel:NSObject {
 
    private var scriptManager: ScriptManager!
    var dataClosure : (() -> Void)?
    var startPracticeClosure : (() -> Void)?
    var blinkImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var showImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    
    var zoomOnAvatarFaceClosure : (() -> Void)?
    var showTextClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var blinkTextClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var childActionClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var playNotificationSoundClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    
    private var verbalQuestionInfo: VerbalQuestionInfo? {
        didSet {
            self.executeCommand()
        }
    }
    
    private var currentCommandIndex = 0 {
        didSet{
            self.executeCommand()
        }
    }
    var trialSubmitResponseVO: TrialQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
    
    override init() {
        super.init()
        scriptManager = ScriptManager.init(delegate: self)
        SpeechManager.shared.setDelegate(delegate: self)
    }
    
    func setQuestionInfo(info: VerbalQuestionInfo) {
        self.verbalQuestionInfo = info
    }
    
    func submitVerbalQuestionDetails(info:VerbalQuestionInfo,completeRate:Int,timetaken:Int,skip:Bool,touchOnEmptyScreenCount:Int) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.trialQuestionSubmitUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
               ServiceParsingKeys.user_id.rawValue :user.id,
               ServiceParsingKeys.question_type.rawValue :info.question_type,
               ServiceParsingKeys.time_taken.rawValue :timetaken,
               ServiceParsingKeys.complete_rate.rawValue :completeRate,
               ServiceParsingKeys.success_count.rawValue : completeRate,
               ServiceParsingKeys.question_id.rawValue :info.id,
               ServiceParsingKeys.language.rawValue:user.languageCode,
               ServiceParsingKeys.req_no.rawValue:info.req_no,
               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
               ServiceParsingKeys.level.rawValue:info.level,
               ServiceParsingKeys.skip.rawValue:skip,
                ServiceParsingKeys.program_id.rawValue:info.program_id,
                ServiceParsingKeys.prompt_type.rawValue:info.prompt_type,
//                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
//                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                ServiceParsingKeys.table_name.rawValue:"verbal_with_multiple"
            ]
        }
        print("trial submit service = ", service)
        ServiceManager.processDataFromServer(service: service, model: TrialQuestionResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let response = responseVo {
                    self.trialSubmitResponseVO = response
                }
            }
        }
    }
}

extension TrialVerbalViewModel {
    private func executeCommand() {
        if let commandResponseVO = self.verbalQuestionInfo  {
            if commandResponseVO.prompt_detail.count > 0 {
                if currentCommandIndex < commandResponseVO.prompt_detail.count {
                print("currentCommandIndex === \(currentCommandIndex)")
                    print("commandResponseVO.prompt_detail.count === \(commandResponseVO.prompt_detail.count)")
                    let deadlineTime = DispatchTime.now() + .seconds(learningCommandDelayTime)
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                        
                        if self.currentCommandIndex < commandResponseVO.prompt_detail.count {
                            let commandInfo = commandResponseVO.prompt_detail[self.currentCommandIndex]
                            self.scriptManager.executeCommand(commandInfo: commandInfo)
                        }
                    }
                } else {
                    print("Main Array khtm ho gya")
                    if let closure = self.startPracticeClosure {
                        closure()
                    }
                }
            } else if let closure = self.startPracticeClosure {
                print("No prompt")
                closure()
            }
        }
    }
    
    
    private func handleBlinkImageCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.blinkImageClosure {
            closure(questionInfo)
        }
    }
    
    private func handleShowImageCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.showImageClosure {
            closure(commandInfo)
        }
    }
    private func handleZoomOnAvatarFaceCommand() {
        if let closure = self.zoomOnAvatarFaceClosure {
            closure()
        }
    }
    private func handleBlinkTextCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.blinkTextClosure {
            closure(commandInfo)
        }
    }
    private func handlePlayNotificationSoundComand(commandInfo:ScriptCommandInfo) {
        if let closure = self.playNotificationSoundClosure {
            closure(commandInfo)
        }
    }
    private func handleShowTextCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.showTextClosure {
            closure(commandInfo)
        }
    }
    private func handleTextToSpeechCommand(commandInfo:ScriptCommandInfo) {
        let message = commandInfo.value
//        if let option = commandInfo.option {
//            if option.variables_text == ScriptCommandOptionType.child_name.rawValue {
//                if let user = UserManager.shared.getUserInfo() {
//                    message =  message + " \(user.nickname)"
//                }
//            }
//        }
        if let option = commandInfo.option {
            
            if(option.sound == "slow") {
                SpeechManager.shared.speak(message: message, uttrenceRate: 0.01)
            } else if(option.sound == "loud") {
                
            } else if(option.child_actions == "verbal") {
                //option.time_in_second
            }
            
        } else {
            SpeechManager.shared.speak(message: message, uttrenceRate: 0.35)
        }
    }
        
    private func handleChildActionStarted(commandInfo:ScriptCommandInfo) {
        if let closure = self.childActionClosure {
            closure(commandInfo)
        }
    }
    
    func updateCurrentCommandIndex() {
        //isAnimationCommand = false
        self.currentCommandIndex += 1
    }
    
}

// MARK: Speech Manager Delegate Methods
extension TrialVerbalViewModel: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        if self.scriptManager.getIsCommandCompleted() {
            self.currentCommandIndex += 1
        }
    }
    
    func speechDidStart(speechText:String) {
//        if let closure = self.showSpeechTextClosure {
//            closure(speechText)
//        }
    }
}

extension TrialVerbalViewModel: ScriptManagerDelegate {
    func get(scriptCommand: ScriptCommand) {
        switch scriptCommand {
        case .blink_image(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleBlinkImageCommand(questionInfo: info)
            }
        case .text_to_speech(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleTextToSpeechCommand(commandInfo: info)
            }
            break
        case .show_image(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleShowImageCommand(commandInfo: info)
            }
        case .commandCompleted:
            break
        case .zoom_on_avatar_face:
            self.handleZoomOnAvatarFaceCommand()
            break
        case .blink_text(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleBlinkTextCommand(commandInfo: info)
            }
        case .play_notification_sound(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handlePlayNotificationSoundComand(commandInfo: info)
            }
        case .show_text(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleShowTextCommand(commandInfo: info)
            }
        case .child_actionStarted(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleChildActionStarted(commandInfo: info)
            }
        default:
            break
        }
    }

}
