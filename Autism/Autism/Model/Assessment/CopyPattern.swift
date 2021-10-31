//
//  CopyPattern.swift
//  Autism
//
//  Created by Dilip Technology on 20/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct CopyPatternInfo: Codable {
    
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var image: String
    var screen_type: String
    var correct_answer: String
    var trial_time: Int
    var completion_time: Int
    var req_no: String
    var skill_domain_id: String
    
    var sequence_number:Int
    var str_repeat_count:String
    var repeat_count:Int
    var image_count:Int
    
    var images:[ImageModel]    
    var level:String
    var program_id: String

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
        self.trial_time             = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
       self.completion_time         = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.req_no                 = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.images                 = try container.decodeIfPresent([ImageModel].self, forKey: .images) ?? []
        
        self.sequence_number        = try container.decodeIfPresent(Int.self, forKey: .sequence_number) ?? 0
        self.image_count            = self.images.count
        
        self.str_repeat_count       = try container.decodeIfPresent(String.self, forKey: .repeat_count) ?? "0"
        self.repeat_count           = Int(self.str_repeat_count)!
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""

    }

    func encode(to encoder: Encoder) throws {
    }
}
