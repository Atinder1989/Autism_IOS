//
//  VerbalQuestionInfo.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct VerbalQuestionInfo: Codable {
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var trial_time: Int
    var time_interval: Int
    var answer: String
    var image: String
    var req_no: String
    var skill_domain_id: String
    var level:String
    var program_id: String
    var trial_prompt_type: String
    var prompt_detail: [ScriptCommandInfo]
    var image_with_text:[ImageModel]
    var prompt_type: String = ""
    var reinforce :[ImageModel]
    
    var correct_text: String = ""
    var incorrect_text: String = ""
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
         self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
         self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
         self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.time_interval        = try container.decodeIfPresent(Int.self, forKey: .time_interval) ?? 0
         self.answer          = try container.decodeIfPresent(String.self, forKey: .answer) ?? ""
         self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""

        self.trial_prompt_type                 = try container.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""

        self.prompt_detail                 = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []
        self.image_with_text               = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []
        
        if(self.answer == "") {
            self.answer = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        }
        self.reinforce                 = try container.decodeIfPresent([ImageModel].self, forKey: .reinforce) ?? []
    
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""

    }

    func encode(to encoder: Encoder) throws {
    }
    
}

