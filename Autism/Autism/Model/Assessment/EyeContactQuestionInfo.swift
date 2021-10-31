//
//  EyeContactQuestionInfo.swift
//  Autism
//
//  Created by Savleen on 01/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct EyeContactQuestionInfo: Codable {
    var question_type: String
    var id: String
    var image_count: String
    var question_title: String
    var language_code: String
    var req_no: String
    var trial_time: Int
    var completion_time: Int
    var level:String
   // var image: String
    var skill_domain_id: String
    //var moving: String
    var program_id: String
    var image_with_text: [ImageModel]

    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.image_count          = try container.decodeIfPresent(String.self, forKey: .image_count) ?? ""

         self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
         self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
         self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
         self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
       //  self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
      //  self.moving                  = try container.decodeIfPresent(String.self, forKey: .moving) ?? ""
        self.program_id         = ""
        self.image_with_text          = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []
     
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
    
}
