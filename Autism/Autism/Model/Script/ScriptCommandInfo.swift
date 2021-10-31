//
//  ScriptCommandInfo.swift
//  Autism
//
//  Created by Dilip Technology on 22/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import UIKit

struct ScriptCommandInfo: Codable {
    var id: String 
    var condition: String
    var child_condition: String
    var type: String
    var cmd_type: String

    var command: ScriptCommand = .none
    var value: String
    var valueList: [String]
    var value_id: String
    
    var value_idList: [String]

//    var isExpanded: Bool
    var cmd_array: [ScriptCommandInfo]
    var option: Option?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.condition          = try container.decodeIfPresent(String.self, forKey: .condition) ?? ""
        self.child_condition          = try container.decodeIfPresent(String.self, forKey: .child_condition) ?? ""
        self.type          = try container.decodeIfPresent(String.self, forKey: .type) ?? ""

        self.cmd_type          = try container.decodeIfPresent(String.self, forKey: .cmd_type) ?? ""
         
       let name         = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        if let cmd = ScriptCommand.init(rawValue: name){
            command = cmd
        }
        self.value = ""
        self.value_id = ""
        self.valueList = []
        self.value_idList = []

        self.cmd_array = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .cmd_array) ?? []
        self.option = try container.decodeIfPresent(Option.self, forKey: .option) ?? nil

        if cmd_type == ScriptCommandType.multiple.rawValue {
            self.valueList          = try container.decodeIfPresent([String].self, forKey: .value) ?? []
            do {
                self.value_idList          = try container.decodeIfPresent([String].self, forKey: .value_id) ?? []
            } catch {
                
            }
        } else {
            self.value          = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
            self.value_id = try container.decodeIfPresent(String.self, forKey: .value_id) ?? ""
        }
    }

    func encode(to encoder: Encoder) throws {
    }
}



struct Option: Codable {
    var avatar_variation: String
    var Position: String
    var larger_scale: String
    var variables_text: String
    var drag_direction: String
    var time_in_second: String
    var image_border: String
    var child_action_duration: String
    var child_action: String
    var is_complete: String
    var bounce_direction: String
    var color_code: String
    var correct_option: String
    var complete_percentage: String
    var switch_command_time: String
    var show_circle: String
    var image_count: String
    var avatar_move: String
    var zoom_on: String
    var background: String

    var child_actions: String
    var sound: String
    
    var transparent:String
    var position_of_finger:String
    var blink:String
    var blink_count:String
    
    init() {
        self.avatar_variation = ""
        self.Position = ""
        self.larger_scale = ""
        self.variables_text = ""
        self.drag_direction = ""
        self.time_in_second = ""
        self.image_border = ""
        self.child_action_duration = ""
        self.child_action = ""
        self.is_complete = ""
        self.bounce_direction = ""
        self.color_code = ""
        self.correct_option = ""
        self.complete_percentage = ""
        self.switch_command_time = ""
        self.show_circle = ""
        self.image_count = ""
        self.child_actions = ""
        self.time_in_second = ""
        self.sound = ""
        self.transparent = ""
        self.position_of_finger = ""
        self.blink = ""
        self.blink_count = ""
        self.avatar_move = ""
        self.zoom_on = ""
        self.background = ""
    }

    
   
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.avatar_variation           = try container.decodeIfPresent(String.self, forKey: .avatar_variation) ?? ""
        self.Position           = try container.decodeIfPresent(String.self, forKey: .Position) ?? ""
        self.larger_scale           = try container.decodeIfPresent(String.self, forKey: .larger_scale) ?? ""
        self.variables_text           = try container.decodeIfPresent(String.self, forKey: .variables_text) ?? ""
        self.drag_direction           = try container.decodeIfPresent(String.self, forKey: .drag_direction) ?? ""
        self.time_in_second           = try container.decodeIfPresent(String.self, forKey: .time_in_second) ?? ""
        self.image_border           = try container.decodeIfPresent(String.self, forKey: .image_border) ?? ""
        self.image_count          = try container.decodeIfPresent(String.self, forKey: .image_count) ?? ""

        self.child_action_duration           = try container.decodeIfPresent(String.self, forKey: .child_action_duration) ?? ""
        self.child_action           = try container.decodeIfPresent(String.self, forKey: .child_action) ?? ""
        self.is_complete           = try container.decodeIfPresent(String.self, forKey: .is_complete) ?? ""
        self.bounce_direction           = try container.decodeIfPresent(String.self, forKey: .bounce_direction) ?? ""
        self.correct_option           = try container.decodeIfPresent(String.self, forKey: .correct_option) ?? ""
        self.complete_percentage           = try container.decodeIfPresent(String.self, forKey: .complete_percentage) ?? ""

        self.color_code = ""
        let text_colorString = try container.decodeIfPresent(String.self, forKey: .color_code) ?? ""
        if text_colorString.count > 0 {
            let array = text_colorString.components(separatedBy: "#")
            if array.count == 2 {
                self.color_code = array[1]
            }
        }
        
        self.switch_command_time           = try container.decodeIfPresent(String.self, forKey: .switch_command_time) ?? ""
        self.avatar_move           = try container.decodeIfPresent(String.self, forKey: .avatar_move) ?? ""
        self.zoom_on           = try container.decodeIfPresent(String.self, forKey: .zoom_on) ?? ""
        self.background           = try container.decodeIfPresent(String.self, forKey: .background) ?? ""
        self.show_circle           = try container.decodeIfPresent(String.self, forKey: .show_circle) ?? ""
        
        //Echoic
        self.child_actions = try container.decodeIfPresent(String.self, forKey: .child_actions) ?? ""
        self.sound = try container.decodeIfPresent(String.self, forKey: .sound) ?? ""

        self.transparent = try container.decodeIfPresent(String.self, forKey: .transparent) ?? ""
        self.position_of_finger = try container.decodeIfPresent(String.self, forKey: .position_of_finger) ?? ""
        self.blink = try container.decodeIfPresent(String.self, forKey: .blink) ?? ""
        self.blink_count = try container.decodeIfPresent(String.self, forKey: .blink_count) ?? ""
    }
}


