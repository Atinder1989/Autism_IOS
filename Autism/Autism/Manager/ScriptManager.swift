//
//  ScriptManager.swift
//  Autism
//
//  Created by Savleen on 17/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

indirect enum ScriptCommand {
    case show_video(commandInfo:ScriptCommandInfo?)
    case text_to_speech(commandInfo:ScriptCommandInfo?)
    case show_images(commandInfo:ScriptCommandInfo?)
    case show_foil_image(commandInfo:ScriptCommandInfo?)
    case moveToNextCommand
    case commandCompleted
    case show_image(commandInfo:ScriptCommandInfo?)
    case child_action
    case show_finger(commandInfo:ScriptCommandInfo?)
    case move_avatar(commandInfo:ScriptCommandInfo?)
    case blink_image(commandInfo:ScriptCommandInfo?)
    case blink_all_images(commandInfo:ScriptCommandInfo?)
    case avatar(commandInfo:ScriptCommandInfo?)
    case make_bigger(commandInfo:ScriptCommandInfo?)
    case make_image_normal(commandInfo:ScriptCommandInfo?)
    case start_drag_animation(commandInfo:ScriptCommandInfo?)
    case drag_transparent_image(commandInfo:ScriptCommandInfo?)
    case drag_image(commandInfo:ScriptCommandInfo?)
    case clear_screen

    case child_actionStarted(commandInfo:ScriptCommandInfo?)
    case child_actionEnded
    case start_balloon_game_demo(commandInfo:ScriptCommandInfo?)
    case start_balloon_game(commandInfo:ScriptCommandInfo?)
    case drag_game_demo
    case start_drag_game
    
    case green_circle(commandInfo:ScriptCommandInfo?)//P2 Trial
    case show_finger_on_image(commandInfo:ScriptCommandInfo?)//P3 Trial
    case show_tap_fingure_animation(commandInfo:ScriptCommandInfo? = nil)//P4 Trial
    
    case zoom_on_avatar_face//P3 Echoic
    case zomm_on_avatar(commandInfo:ScriptCommandInfo?)
    case blink_text(commandInfo:ScriptCommandInfo?)
    case blink_all_text(commandInfo:ScriptCommandInfo?)
    case show_text(commandInfo:ScriptCommandInfo?)
    case decrease_speed(commandInfo:ScriptCommandInfo?)
    case halt_screen(commandInfo:ScriptCommandInfo?)
    case pop_balloon(commandInfo:ScriptCommandInfo?)
    case play_notification_sound(commandInfo:ScriptCommandInfo?)
    case none
    
    init?(rawValue: String) {
        switch rawValue {
        case "show_video":
            self = .show_video(commandInfo: nil)
        case "text_to_speech":
            self = .text_to_speech(commandInfo: nil)
        case "show_images":
            self = .show_images(commandInfo: nil)
        case "show_foil_image":
            self = .show_foil_image(commandInfo: nil)
        case "show_image":
            self = .show_image(commandInfo: nil)
        case "child_action":
            self = .child_action
        case "start_balloon_game_demo":
            self = .start_balloon_game_demo(commandInfo: nil)
        case "drag_game_demo":
            self = .drag_game_demo
        case "start_drag_game":
            self = .start_drag_game
        case "start_balloon_game":
            self = .start_balloon_game(commandInfo: nil)
        case "show_finger":
            self = .show_finger(commandInfo: nil)
        case "move_avatar":
            self = .move_avatar(commandInfo: nil)
        case "show_tap_fingure_animation":
            self = .show_tap_fingure_animation(commandInfo: nil)
        case "blink_all_images":
            self = .blink_all_images(commandInfo: nil)
        case "avatar":
            self = .avatar(commandInfo: nil)
        case "make_bigger":
            self = .make_bigger(commandInfo: nil)
        case "make_image_normal":
            self = .make_image_normal(commandInfo: nil)
        case "start_drag_animation":
            self = .start_drag_animation(commandInfo: nil)
        case "drag_transparent_image":
            self = .drag_transparent_image(commandInfo: nil)
        case "drag_image":
            self = .drag_image(commandInfo: nil)
        case "clear_screen":
            self = .clear_screen
        case "blink_image":
            self = .blink_image(commandInfo: nil)
        case "green_circle":
            self = .green_circle(commandInfo: nil)
        case "show_finger_on_image":
            self = .show_finger_on_image(commandInfo: nil)
        case "zoom_on_avatar_face":
            self = .zoom_on_avatar_face
        case "zomm_on_avatar":
            self = .zomm_on_avatar(commandInfo: nil)
        case "blink_text":
            self = .blink_text(commandInfo: nil)
        case "blink_all_text":
            self = .blink_all_text(commandInfo: nil)
        case "show_text":
            self = .show_text(commandInfo: nil)
        case "decrease_speed":
            self = .decrease_speed(commandInfo: nil)
        case "halt_screen":
            self = .halt_screen(commandInfo: nil)
        case "pop_balloon":
            self = .pop_balloon(commandInfo: nil)
        case "play_notification_sound":
            self = .play_notification_sound(commandInfo: nil)
        default:
            self = .none
            break
        }
    }
}

enum ScriptCommandType:String {
    case multiple
    case single
    case none
}

enum ScriptCommandOptionType: String {
    case show_avatar
    case wave_avatar
    case talk_avatar
    case hide_avatar
    case idle_avatar
    case right
    case left
    case top
    case child_name
    case center
    case bottom
    case right_to_left
    case yes
    case actiontrue
    case actionfalse
    case center_to_right
    case top_and_bottom
    case none
}

enum ScriptCommandConditionType: String {
    case no = "no"
    case yes = "yes"
    case ifcondition = "if"
    case parallel = "parallel"
    case sequence = "sequence"
}

protocol ScriptManagerDelegate: NSObjectProtocol {
    func get(scriptCommand: ScriptCommand)
}

class ScriptManager: NSObject {
    private var parallelCommandInfo : ScriptCommandInfo?
    private var childActionTimer: Timer? = nil
    private var childActionWaitingTime = 0
    private var isCommandCompleted = false
    private weak var delegate: ScriptManagerDelegate?
    private var childActionLevelCount = 0

    private var isChildActionCompleted = false {
        didSet {
            self.stopTimer()
            self.handleChildActionState()
        }
    }
    private var childActionCommandInfo: ScriptCommandInfo? = nil {
        didSet{
            if let _ = self.childActionCommandInfo {
                self.childActionLevelCount += 1
            }
        }
    }
    private var sequenceCommandIndex = -1 {
        didSet{
            if self.sequenceCommandIndex >= 0 {
                
                if let info = self.sequenceCommandInfo {
                    if info.cmd_array.count > 0 {
                        if self.sequenceCommandIndex < info.cmd_array.count {
                            let commandInfo = info.cmd_array[self.sequenceCommandIndex]
                            self.handleCommand(commandInfo: commandInfo)
                            print("sequenceCommandIndex = ", sequenceCommandIndex)
                        } else {
                            print("Sequence Command Array Completed")
                            self.sequenceCommandInfo = nil
                            self.moveToNextCommand()
                        }
                    }
                }
                
            }
        }
    }
    private var sequenceCommandInfo: ScriptCommandInfo? = nil
    
    convenience init(delegate:ScriptManagerDelegate?) {
        self.init()
        self.delegate = delegate
    }
}
// MARK: Public Methods
extension ScriptManager {
    func executeCommand(commandInfo:ScriptCommandInfo) {
        self.resetData()
        self.handleCommand(commandInfo: commandInfo)
    }
    
    func setChildActionState(state:Bool) {
        self.isChildActionCompleted = state
    }
    
    func getIsCommandCompleted() -> Bool {
        return self.isCommandCompleted
    }
    
    func getTimeTaken()->Int {
        return self.childActionWaitingTime
    }
    
    func getChildActionCommandInfo()->ScriptCommandInfo? {
        return self.childActionCommandInfo
    }
    
    func getSequenceCommandInfo()->ScriptCommandInfo? {
        return self.sequenceCommandInfo
    }
    
    func getChildActionLevel()->Int {
        return self.childActionLevelCount
    }
    
    func updateSequenceCommandIndex() {
        self.sequenceCommandIndex += 1
    }
    func stopallTimer() {
        self.stopTimer()
    }
}

// MARK: Private Methods
extension ScriptManager {
    private func resetData() {
        self.sequenceCommandInfo = nil
        self.sequenceCommandIndex = -1
        self.childActionLevelCount = 0
        self.isCommandCompleted = false
        self.isChildActionCompleted = false
        self.parallelCommandInfo = nil
        self.childActionCommandInfo = nil
        self.stopTimer()
    }
    
    private func handleCommand(commandInfo:ScriptCommandInfo) {
        if commandInfo.condition == ScriptCommandConditionType.no.rawValue {
            self.handleNoConditionCommand(commandInfo: commandInfo)
        } else if commandInfo.condition == ScriptCommandConditionType.parallel.rawValue {
            self.handleParallelConditionCommand(commandInfo: commandInfo)
        } else if commandInfo.condition == ScriptCommandConditionType.ifcondition.rawValue {
            self.handleIfConditionCommand(commandInfo: commandInfo)
        }
    }
    
    private func handleNoConditionCommand(commandInfo:ScriptCommandInfo) {
        self.filterCommand(commandInfo: commandInfo)
        if let _ = self.parallelCommandInfo {
            
        } else if let _ = self.sequenceCommandInfo {
            
        }
        else {
            self.sendCommandCompletedStatus()
        }
    }
    
    private func handleParallelConditionCommand(commandInfo:ScriptCommandInfo) {
        self.parallelCommandInfo = commandInfo
        self.filterCommand(commandInfo: commandInfo)
        for info in commandInfo.cmd_array {
            if info.condition == ScriptCommandConditionType.no.rawValue {
                self.handleNoConditionCommand(commandInfo: info)
            } else if info.condition == ScriptCommandConditionType.ifcondition.rawValue {
                self.handleIfConditionCommand(commandInfo: info)
            } else if info.condition == ScriptCommandConditionType.sequence.rawValue {
                self.handleSequenceConditionCommand(commandInfo: info)
            }
        }
        if self.childActionCommandInfo == nil {
            self.sendCommandCompletedStatus()
        }
    }
    
    private func handleIfConditionCommand(commandInfo:ScriptCommandInfo) {
        switch commandInfo.command {
            case .child_action:
                self.childActionCommandInfo = commandInfo
                self.handleChildActionCommand(commandInfo: commandInfo)
            default:break
        }
    }
    
    private func handleSequenceConditionCommand(commandInfo:ScriptCommandInfo) {
        self.sequenceCommandInfo = commandInfo
        self.sequenceCommandIndex = 0
    }
}

extension ScriptManager {
    private func filterCommand(commandInfo:ScriptCommandInfo) {
        print("commandInfo.command = ", commandInfo.command)
        switch commandInfo.command {
            case .clear_screen:
                self.handleClearScreenCommand(commandInfo: commandInfo)
            case .show_video:
                self.handleShowVideoCommand(commandInfo: commandInfo)
            case .text_to_speech:
                self.handleTextToSpeechCommand(commandInfo: commandInfo)
            case .show_images:
                self.handleShowImagesCommand(commandInfo: commandInfo)
            case .show_foil_image:
                self.handleShowFoilImageCommand(commandInfo: commandInfo)
            case .show_finger:
                self.handleShowFingerCommand(commandInfo: commandInfo)
            case .move_avatar:
                self.handleMoveAvatarCommand(commandInfo: commandInfo)
            case .show_tap_fingure_animation:
                self.handleShowTapFingerAnimationCommand(commandInfo: commandInfo)
            case .blink_all_images:
                self.handleBlinkAllImagesCommand(commandInfo: commandInfo)
            case .show_image:
                self.handleShowImageCommand(commandInfo: commandInfo)
            case .avatar:
                self.handleAvatarCommand(commandInfo: commandInfo)
            case .make_bigger:
                self.handleMakeBiggerCommand(commandInfo: commandInfo)
            case .make_image_normal:
                self.handleMakeImageNormalCommand(commandInfo: commandInfo)
            case .start_drag_animation:
                self.handleStartDragAnimationCommand(commandInfo: commandInfo)
            case .drag_transparent_image:
                self.handleDragTransparentImageCommand(commandInfo: commandInfo)
            case .drag_image:
                self.handleDragImageCommand(commandInfo: commandInfo)
            case .blink_image:
                self.handleBlinkImageCommand(commandInfo: commandInfo)
            case .green_circle:
                self.handleGreenCircleImageCommand(commandInfo: commandInfo)
            case .show_finger_on_image:
                self.handleFingerOnImageCommand(commandInfo: commandInfo)
            case .zoom_on_avatar_face:
                self.handleZoomOnAvatarFaceCommand(commandInfo: commandInfo)
            case .zomm_on_avatar:
                self.handleZommOnAvatarCommand(commandInfo: commandInfo)
            case .blink_text:
                self.handleBlinkTextCommand(commandInfo: commandInfo)
            case .show_text:
                self.handleShowTextCommand(commandInfo: commandInfo)
            case .blink_all_text:
                self.handleBlinkAllTextsCommand(commandInfo: commandInfo)
            case .child_action:
                self.handleChildActionCommand(commandInfo: commandInfo)
            case .start_balloon_game_demo:
                self.handleStartBalloonGameDemoCommand(commandInfo: commandInfo)
            case .drag_game_demo:
                self.handleStartDragGameDemoCommand()
            case .start_drag_game:
                self.handleStartDragGameCommand()
            case .start_balloon_game:
                self.handleStartBalloonGameCommand(commandInfo: commandInfo)
            case .decrease_speed:
                self.handleDecreaseSpeedBalloonGameCommand(commandInfo: commandInfo)
        case .halt_screen:
            self.handleHaltScreenCommand(commandInfo: commandInfo)
        case .pop_balloon:
            self.handlePopBalloonCommand(commandInfo: commandInfo)
        case .play_notification_sound:
            self.handlePlayNotificationSound(commandInfo: commandInfo)
            default:break
        }
    }
    
    private func handleHaltScreenCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .halt_screen(commandInfo:commandInfo))
        }
    }
    private func handlePopBalloonCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .pop_balloon(commandInfo:commandInfo))
        }
    }
    private func handlePlayNotificationSound(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .play_notification_sound(commandInfo:commandInfo))
        }
    }
    private func handleBlinkTextCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .blink_text(commandInfo:commandInfo))
        }
    }
  
    private func handleShowTextCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_text(commandInfo:commandInfo))
        }
    }
    
    private func handleClearScreenCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .clear_screen)
        }
    }
    
    private func handleShowVideoCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_video(commandInfo:commandInfo))
        }
    }
    
    private func handleAvatarCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand:.avatar(commandInfo: commandInfo))
        }
    }
    
    private func handleMakeBiggerCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand:.make_bigger(commandInfo: commandInfo))
        }
    }
    
    private func handleMakeImageNormalCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand:.make_image_normal(commandInfo: commandInfo))
        }
    }
    
    private func handleStartDragAnimationCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand:.start_drag_animation(commandInfo: commandInfo))
        }
    }
    private func handleDragTransparentImageCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand:.drag_transparent_image(commandInfo: commandInfo))
        }
    }
    private func handleDragImageCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand:.drag_image(commandInfo: commandInfo))
        }
    }
    
    private func handleShowFoilImageCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_foil_image(commandInfo: commandInfo))
        }
    }

    private func handleShowImagesCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_images(commandInfo: commandInfo))
        }
    }
    
    private func handleShowImageCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_image(commandInfo: commandInfo))
        }
    }
    
    private func handleTextToSpeechCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .text_to_speech(commandInfo: commandInfo))
        }
    }
    
    private func handleShowFingerCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_finger(commandInfo: commandInfo))
        }
    }
    
    private func handleMoveAvatarCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .move_avatar(commandInfo: commandInfo))
        }
    }
    
    private func handleStartBalloonGameDemoCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .start_balloon_game_demo(commandInfo: commandInfo))
        }
    }
    
    private func handleStartDragGameDemoCommand() {
        if let del = self.delegate {
            del.get(scriptCommand: .drag_game_demo)
        }
    }
    
    private func handleStartDragGameCommand() {
        if let del = self.delegate {
            del.get(scriptCommand: .start_drag_game)
        }
    }
    
    private func handleStartBalloonGameCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .start_balloon_game(commandInfo: commandInfo))
        }
    }
    
    private func handleDecreaseSpeedBalloonGameCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .decrease_speed(commandInfo: commandInfo))
        }
    }
    
    private func handleChildActionCommand(commandInfo:ScriptCommandInfo) {
        DispatchQueue.main.async {
            if let del = self.delegate {
                del.get(scriptCommand: .child_actionStarted(commandInfo: commandInfo))
            }
            self.initializeTimer()
        }
    }

    private func handleShowTapFingerAnimationCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_tap_fingure_animation(commandInfo: commandInfo))
        }
    }
    private func handleBlinkImageCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .blink_image(commandInfo: commandInfo))
        }
    }
    private func handleBlinkAllImagesCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .blink_all_images(commandInfo: commandInfo))
        }
    }
    private func handleBlinkAllTextsCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .blink_all_text(commandInfo: commandInfo))
        }
    }
    //P2
    private func handleGreenCircleImageCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .green_circle(commandInfo: commandInfo))
        }
    }
    //P3
    private func handleFingerOnImageCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .show_finger_on_image(commandInfo: commandInfo))
        }
    }
    //P3 ECHOIC
    private func handleZoomOnAvatarFaceCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .zoom_on_avatar_face)
        }
    }
    private func handleZommOnAvatarCommand(commandInfo:ScriptCommandInfo) {
        if let del = self.delegate {
            del.get(scriptCommand: .zomm_on_avatar(commandInfo: commandInfo))
        }
    }
    
}

// MARK: Timer Methods
extension ScriptManager {
    private func initializeTimer() {
        if(childActionTimer != nil) {
            if(childActionTimer?.isValid == true)
            {
                childActionTimer?.invalidate()
                childActionTimer = nil
            }
        }
        childActionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        childActionWaitingTime += 1
        print("Script Manager Timer Start == \(childActionWaitingTime)")
        if let info = self.childActionCommandInfo,let option = info.option {
            let time = Int(option.time_in_second) ?? 0
            if self.childActionWaitingTime >= time  {
                self.isChildActionCompleted = false
            }
        }
    }
    
    private func stopTimer() {
        if let timer = self.childActionTimer {
            print("Script Manager Timer Stop ======== ")
            if(timer.isValid == true) {
                timer.invalidate()
            }
            self.childActionTimer = nil
            self.childActionWaitingTime = 0
            if let del = self.delegate {
                del.get(scriptCommand: .child_actionEnded)
            }
        }
    }
}


// MARK: Private Methods for Handling Child Action State
extension ScriptManager {
    private func handleChildActionState() {
        if let childInfo = self.childActionCommandInfo {
            self.childActionCommandInfo = nil
            self.sequenceCommandInfo = nil
            if self.isChildActionCompleted {
                self.handleChildActionCompleted(childInfo: childInfo)
            } else {
                self.handleChildActionNotCompleted(childInfo: childInfo)
            }
        }
    }
    //Need to confirm from atinder for secuence no answer command
    private func handleChildActionCompleted(childInfo:ScriptCommandInfo) {
        for info in childInfo.cmd_array {
            if info.condition == ScriptCommandConditionType.sequence.rawValue && info.child_condition == ScriptCommandConditionType.yes.rawValue {
                if info.cmd_array.count > 0 {
                    self.handleSequenceConditionCommand(commandInfo: info)
                }
            } else if info.condition == ScriptCommandConditionType.no.rawValue {
                self.handleNoConditionCommand(commandInfo: info)
            }
        }
        self.sendCommandCompletedStatus()
       
    }
    
    private func handleChildActionNotCompleted(childInfo:ScriptCommandInfo) {
        for info in childInfo.cmd_array {
            if info.condition == ScriptCommandConditionType.sequence.rawValue && info.child_condition == ScriptCommandConditionType.no.rawValue {
                if info.cmd_array.count > 0 {
                    self.handleSequenceConditionCommand(commandInfo: info)
                }
            } else if info.condition != ScriptCommandConditionType.sequence.rawValue && info.condition != ScriptCommandConditionType.no.rawValue {
                self.handleChildActionNotCompletedNextStage(childInfo: info)
            }
        }
    }
    
    private func handleChildActionNotCompletedNextStage(childInfo:ScriptCommandInfo) {
        if childInfo.condition == ScriptCommandConditionType.parallel.rawValue {
            self.handleParallelConditionCommand(commandInfo: childInfo)
        } else if childInfo.condition == ScriptCommandConditionType.ifcondition.rawValue {
            self.handleIfConditionCommand(commandInfo: childInfo)
        }
    }
    
    private func sendCommandCompletedStatus() {
        if let del = self.delegate{
            self.isCommandCompleted = true
            del.get(scriptCommand: .commandCompleted)
        }
    }
    
    private func moveToNextCommand() {
        if let del = self.delegate {
            del.get(scriptCommand: .moveToNextCommand)
        }
    }
    
}
