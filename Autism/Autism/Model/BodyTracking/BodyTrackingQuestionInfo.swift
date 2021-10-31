//
//  BodyTrackingQuestionInfo.swift
//  Autism
//
//  Created by Savleen on 26/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct BodyTrackingQuestionInfo: Codable {
    var question_type: String
    var id: String
    var question_title: String
    var language_code: String
    var trial_time: Int
    var completion_time: Int
    var level: String
    var req_no: String
    var correct_answer: String
    var skill_domain_id: String
    var program_id: String

    var trial_prompt_type: String
    var prompt_type: String = ""
    var prompt_detail: [ScriptCommandInfo]
    
    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
         self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
         self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
         self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.correct_answer          = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.program_id         = ""
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""

        self.trial_prompt_type         = try container.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""
        self.prompt_type         = try container.decodeIfPresent(String.self, forKey: .prompt_type) ?? ""
        self.prompt_detail                 = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []
        
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""      }

    func encode(to encoder: Encoder) throws {
    }
    
}
