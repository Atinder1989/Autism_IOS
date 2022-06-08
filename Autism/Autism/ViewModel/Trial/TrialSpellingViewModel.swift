//
//  TrialSpellingViewModel.swift
//  Autism
//
//  Created by Dilip Technology on 31/03/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit

class TrialSpellingViewModel: NSObject {
    
    private var scriptManager: ScriptManager!
    var dataClosure : (() -> Void)?
    var startPracticeClosure : (() -> Void)?
    var blinkImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var blinkTextClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var showImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var childActionClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var showTextClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    
    private var matchSpellingQuestionInfo: MatchSpelling? {
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
    
    func setQuestionInfo(info: MatchSpelling) {
        self.matchSpellingQuestionInfo = info
    }
    
    func stopAllCommands() {
        SpeechManager.shared.stopSpeech()
        SpeechManager.shared.setDelegate(delegate: nil)
        RecordingManager.shared.stopRecording()
        self.scriptManager.stopallTimer()
    }
    
    func submitVerbalQuestionDetails(info:MatchSpelling,completeRate:Int,timetaken:Int,skip:Bool,touchOnEmptyScreenCount:Int) {
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
                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount
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
extension TrialSpellingViewModel {
    private func executeCommand() {
        if let commandResponseVO = self.matchSpellingQuestionInfo  {
            if commandResponseVO.prompt_detail.count > 0 {
                if currentCommandIndex < commandResponseVO.prompt_detail.count {
                print("currentCommandIndex === \(currentCommandIndex)")
                    let deadlineTime = DispatchTime.now() + .seconds(learningCommandDelayTime)
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                        let commandInfo = commandResponseVO.prompt_detail[self.currentCommandIndex]
                            self.scriptManager.executeCommand(commandInfo: commandInfo)
                        
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
    
    private func handleBlinkTextCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.blinkTextClosure {
            closure(questionInfo)
        }
    }
    private func handleShowImageCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.showImageClosure {
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
        SpeechManager.shared.speak(message: message, uttrenceRate: 0.35)
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
extension TrialSpellingViewModel: SpeechManagerDelegate {
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

extension TrialSpellingViewModel: ScriptManagerDelegate {
    func get(scriptCommand: ScriptCommand) {
        switch scriptCommand {
        case .blink_image(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleBlinkImageCommand(questionInfo: info)
            }
        case .blink_text(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleBlinkTextCommand(questionInfo: info)
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
        case .show_text(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleShowTextCommand(commandInfo: info)
            }
        case .child_actionStarted(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleChildActionStarted(commandInfo: info)
            }
        case .commandCompleted:
            break
        default:
            break
        }
    }

}
