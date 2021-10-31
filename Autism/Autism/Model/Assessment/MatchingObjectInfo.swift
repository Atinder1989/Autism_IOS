//
//  MatchingObjectInfo.swift
//  Autism
//
//  Created by Dilip Technology on 16/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct MatchingObjectInfo: Codable {
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var image: String
    var bg_image: String
    var screen_type: String
    var correct_answer: String
    var trial_time: Int
    var completion_time: Int
    var req_no: String
    var skill_domain_id: String
    var images:[ImageModel]
    var block:[ImageModel]
    var image_with_text:[ImageModel]
    var level: String
    var program_id: String
    var trial_prompt_type: String
    var prompt_detail: [ScriptCommandInfo]
    var prompt_type: String = ""

    
    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.question_title         = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        self.correct_answer         = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        self.screen_type            = try container.decodeIfPresent(String.self, forKey: .screen_type) ?? ""
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.image                  = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.bg_image               = try container.decodeIfPresent(String.self, forKey: .bg_image) ?? ""
        self.trial_time             = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time         = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.req_no                 = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.images                 = try container.decodeIfPresent([ImageModel].self, forKey: .images) ?? []
        self.block                 = try container.decodeIfPresent([ImageModel].self, forKey: .block) ?? []
        self.image_with_text                 = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []
        self.level            = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""
        
        self.trial_prompt_type                 = try container.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""

        self.prompt_detail                 = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []

        if(images.count == 0) {
            self.images = self.image_with_text
        }
        
        if(block.count == 0) {
            if(self.image_with_text.count > 1) {
                if(self.image_with_text[0].name == "Left") {
                    self.block.append(self.image_with_text[1])
                    self.block[0].empty_image = self.image_with_text[0].image
                } else if(self.image_with_text[1].name == "Left") {
                    self.block.append(self.image_with_text[0])
                    self.block[0].empty_image = self.image_with_text[1].image
                }
                
            }
        }
        if(bg_image == "") {
            self.bg_image                 = try container.decodeIfPresent(String.self, forKey: .video_url) ?? ""
        }
        
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""

    }

    func encode(to encoder: Encoder) throws {
    }
}

