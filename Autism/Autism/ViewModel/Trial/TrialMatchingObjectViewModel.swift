//
//  TrialMatchingObjectViewModel.swift
//  Autism
//
//  Created by Dilip Technology on 23/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class TrialMatchingObjectViewModel: NSObject {
    private var scriptManager: ScriptManager!

    var dataClosure : (() -> Void)?
    var startPracticeClosure : (() -> Void)?
    
    var showImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var blinkImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P1
    var blinkAllImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P1
    var showGreenCircleClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P2
    var showFingerOnImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P3
    var showFingerClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P3
    var showTapFingerAnimationClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P4
    var makeBiggerClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P5.1
    var makeImageNormalClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P5.1
    var dragImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?//P5.
    
    var startDragAnimationClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    var dragTransparentImageClosure : ((_ questionInfo:ScriptCommandInfo) -> Void)?
    
    private var matchingObjectInfo: MatchingObjectInfo? {
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
    
    func setQuestionInfo(info: MatchingObjectInfo) {
        self.matchingObjectInfo = info
    }
    
    func submitUserAnswer(successCount:Int,info:MatchingObjectInfo,timeTaken:Int,skip:Bool,touchOnEmptyScreenCount:Int,selectedIndex:Int) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.trialQuestionSubmitUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [ ServiceParsingKeys.user_id.rawValue:user.id,
                               ServiceParsingKeys.question_type.rawValue : info.question_type,
                               ServiceParsingKeys.time_taken.rawValue : timeTaken,
                               ServiceParsingKeys.complete_rate.rawValue : successCount,
                               ServiceParsingKeys.success_count.rawValue : successCount,
                               ServiceParsingKeys.question_id.rawValue : info.id,
                               ServiceParsingKeys.language.rawValue:user.languageCode,
                               ServiceParsingKeys.req_no.rawValue:info.req_no,
                               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                               ServiceParsingKeys.level.rawValue:info.level,
                               ServiceParsingKeys.skip.rawValue:skip,
                               ServiceParsingKeys.program_id.rawValue:info.program_id,
                               ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                               ServiceParsingKeys.selectedIndex.rawValue:selectedIndex+1,
                               ServiceParsingKeys.prompt_type.rawValue:info.prompt_type,
                               ServiceParsingKeys.table_name.rawValue:info.question_type
            ]
            print("service.params = ", service.params)
        }
        
        ServiceManager.processDataFromServer(service: service, model: TrialQuestionResponseVO.self) { (responseVo, error) in
            if let _ = error {
                 self.trialSubmitResponseVO = nil
            } else {
                if let response = responseVo {
                    print("response = ", response)
                    self.trialSubmitResponseVO = response
                }
            }
        }
    }
    
    func submitTrialAnswerFromLearning(successCount:Int, info:MatchingObjectInfo, timeTaken:Int, skip:Bool, touchOnEmptyScreenCount:Int, selectedIndex:Int) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.trialAnswerUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [ ServiceParsingKeys.user_id.rawValue:user.id,
                               ServiceParsingKeys.question_type.rawValue : info.question_type,
                               ServiceParsingKeys.time_taken.rawValue : timeTaken,
                               ServiceParsingKeys.complete_rate.rawValue : successCount,
                               ServiceParsingKeys.success_count.rawValue : successCount,
                               ServiceParsingKeys.question_id.rawValue : info.id,
                               ServiceParsingKeys.language.rawValue:user.languageCode,
                               ServiceParsingKeys.req_no.rawValue:info.req_no,
                               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                               ServiceParsingKeys.level.rawValue:info.level,
                               ServiceParsingKeys.skip.rawValue:skip,
                               ServiceParsingKeys.program_id.rawValue:info.program_id,
                               ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                               ServiceParsingKeys.selectedIndex.rawValue:selectedIndex+1,
                               ServiceParsingKeys.prompt_type.rawValue:info.prompt_type

            ]
            print("service.params = ", service.params)
        }
        
        ServiceManager.processDataFromServer(service: service, model: TrialQuestionResponseVO.self) { (responseVo, error) in
            if let _ = error {
                 self.trialSubmitResponseVO = nil
            } else {
                if let response = responseVo {
                    print("response = ", response)
                    self.trialSubmitResponseVO = response
                }
            }
        }
    }

}


extension TrialMatchingObjectViewModel {
    private func executeCommand() {
        if let commandResponseVO = self.matchingObjectInfo  {
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
            }
        }
    }
    
    private func handleBlinkAllImageCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.blinkAllImageClosure {
            closure(questionInfo)
        }
    }
    private func handleBlinkImageCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.blinkImageClosure {
            closure(questionInfo)
        }
    }
    
    private func handleDragTransparentImageCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.dragTransparentImageClosure {
            closure(questionInfo)
        }
    }
    
    private func handleStartDragAnimationCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.startDragAnimationClosure {
            closure(questionInfo)
        }
    }
    
    private func handleShowImageCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.showImageClosure {
            closure(commandInfo)
        }
    }
    //P2
    private func handleGreenCircleCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.showGreenCircleClosure {
            closure(questionInfo)
        }
    }
    //P3
    private func handleShowFingerOnImageCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.showFingerOnImageClosure {
            closure(questionInfo)
        }
    }

    private func handleShowFingerCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.showFingerClosure {
            closure(questionInfo)
        }
    }

    //P4
    private func handleShowTapFingerAnimationCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.showTapFingerAnimationClosure {
            closure(questionInfo)
        }
    }
    
    //P5.1
    private func handleMakeBiggerAnimationCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.makeBiggerClosure {
            closure(questionInfo)
        }
    }
    
    //P5.2
    private func handleMakeImageNormalAnimationCommand(questionInfo:ScriptCommandInfo) {
        if let closure = self.makeImageNormalClosure {
            closure(questionInfo)
        }
    }
    
    private func handleDragImageCommand(commandInfo:ScriptCommandInfo) {
        if let closure = self.dragImageClosure {
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
    
    func updateCurrentCommandIndex() {
        //isAnimationCommand = false
        self.currentCommandIndex += 1
    }
}

// MARK: Speech Manager Delegate Methods
extension TrialMatchingObjectViewModel: SpeechManagerDelegate {
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


extension TrialMatchingObjectViewModel: ScriptManagerDelegate {
    func get(scriptCommand: ScriptCommand) {
        switch scriptCommand {
        
        case .drag_transparent_image(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleDragTransparentImageCommand(questionInfo: info)
            }
        case .start_drag_animation(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleStartDragAnimationCommand(questionInfo: info)
            }
        case .show_image(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleShowImageCommand(commandInfo: info)
            }
        case .blink_image(commandInfo: let commandInfo)://p1
            if let info = commandInfo {
                self.handleBlinkImageCommand(questionInfo: info)
            }
        case .blink_all_images(commandInfo: let commandInfo)://p1
            if let info = commandInfo {
                self.handleBlinkAllImageCommand(questionInfo: info)
            }
        case .drag_image(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleDragImageCommand(commandInfo: info)
            }
        case .green_circle(commandInfo: let commandInfo)://p2
            if let info = commandInfo {
                self.handleGreenCircleCommand(questionInfo: info)
            }
        case .show_finger_on_image(commandInfo: let commandInfo)://p3
            if let info = commandInfo {
                self.handleShowFingerOnImageCommand(questionInfo: info)
            }
        case .show_finger(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleShowFingerCommand(questionInfo: info)
            }
        case .show_tap_fingure_animation(commandInfo: let commandInfo)://p4
            if let info = commandInfo {
                self.handleShowTapFingerAnimationCommand(questionInfo: info)
            }
        case .make_bigger(commandInfo: let commandInfo)://p4
            if let info = commandInfo {
                self.handleMakeBiggerAnimationCommand(questionInfo: info)
            }
        case .make_image_normal(commandInfo: let commandInfo)://p4
            if let info = commandInfo {
                self.handleMakeImageNormalAnimationCommand(questionInfo: info)
            }
        case .text_to_speech(commandInfo: let commandInfo):
            if let info = commandInfo {
                self.handleTextToSpeechCommand(commandInfo: info)
            }
            break
        case .commandCompleted:
            break
        default:
            break
        }
    }

}
