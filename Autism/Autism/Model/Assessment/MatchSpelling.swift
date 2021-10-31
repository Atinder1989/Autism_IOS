//
//  MatchSpelling.swift
//  Autism
//
//  Created by mac on 19/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct MatchSpelling: Codable {
    var success: Bool
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var status: String
    var image: String
    var level: String
    var assessment_type: String
    var req_no: String
    var trial_time: Int
    var completion_time: Int
    var answer: String
    
    var skill_domain_id: String
    var program_id: String

    var trial_prompt_type: String
    var prompt_detail: [ScriptCommandInfo]
    var image_with_text:[ImageModel]
    var prompt_type: String = ""
    var arrKeys:[String] = []
    
    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
         self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        
        
        let array:[String] = self.question_title.components(separatedBy: "<br>")
        if(array.count > 0) {
            self.question_title = array[0]
        }
        if(array.count > 1) {
            
            self.arrKeys = array[1].replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
            self.arrKeys.append("⌫") 
        }
        

        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.status  = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        self.image  = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.assessment_type          = try container.decodeIfPresent(String.self, forKey: .assessment_type) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.answer          = try container.decodeIfPresent(String.self, forKey: .answer) ?? ""
       
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.program_id         = ""

        self.trial_prompt_type                 = try container.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""

        self.prompt_detail                 = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []
        self.image_with_text               = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []
        
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}

