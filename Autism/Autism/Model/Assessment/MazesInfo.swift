//
//  MazesInfo.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct MazesInfo: Codable {
    var success: Bool
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var status: String
    var image: String
    
    var assessment_type: String
    var verbalQuestionInfo: VerbalQuestionInfo?
    var req_no: String
    var trial_time: Int
    var completion_time: Int
    var skill_domain_id: String
    var level:String
    var maze_id:String
    var goal_image:String
    var objejct_image:String
    var bg_image:String
    
    var program_id: String

    var trial_prompt_type: String
    var prompt_type: String = ""
    var prompt_detail: [ScriptCommandInfo]
    
    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
         self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
         
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.status  = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        self.image  = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.assessment_type          = try container.decodeIfPresent(String.self, forKey: .assessment_type) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.maze_id                = try container.decodeIfPresent(String.self, forKey: .maze_id) ?? ""
        
        self.objejct_image = try container.decodeIfPresent(String.self, forKey: .objejct_image) ?? ""
        self.goal_image = try container.decodeIfPresent(String.self, forKey: .goal_image) ?? ""
        self.bg_image = try container.decodeIfPresent(String.self, forKey: .bg_image) ?? ""
        
        self.program_id         = ""

        self.trial_prompt_type         = try container.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""
        self.prompt_type         = try container.decodeIfPresent(String.self, forKey: .prompt_type) ?? ""
        self.prompt_detail                 = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []
        
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
