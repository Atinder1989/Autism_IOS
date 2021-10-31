//
//  BalloonGameQuestionInfo.swift
//  Autism
//
//  Created by Savleen on 21/05/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import Foundation

struct BalloonGameQuestionInfo: Codable {
    var question_type: String
    var id: String
    var question_title: String
    var language_code: String
    var image: String
    var trial_time: Int
    var completion_time: Int
    var level: String
    var req_no: String
    var image_with_text: [ImageModel]
    var skill_domain_id: String
    var program_id: String

    var trial_prompt_type: String
    var prompt_type: String = ""
    var prompt_detail: [ScriptCommandInfo]
    
    var option: Option?
    
    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
         self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
         self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
         self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
         self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.program_id         = ""
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.image_with_text          = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []
        
        self.trial_prompt_type         = try container.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""
        self.prompt_type         = try container.decodeIfPresent(String.self, forKey: .prompt_type) ?? ""
        self.prompt_detail                 = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []

        self.option = try container.decodeIfPresent(Option.self, forKey: .option) ?? nil
      
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
    
}
