//
//  WritingOnPadInfo.swift
//  Autism
//
//  Created by Singh, Atinderpal on 28/08/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation

struct WritingOnPadInfo: Codable {
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var trial_time: Int
    var completion_time: Int
    var req_no: String
    var skill_domain_id: String
    var level:String
    var program_id: String

    var correct_text: String = ""
    var incorrect_text: String = ""
    var correct_image_name: String
    var image_with_text: [ImageModel]


    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
       self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
        self.correct_image_name          = try container.decodeIfPresent(String.self, forKey: .correct_image_name) ?? ""
        self.image_with_text          = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []

    }

    func encode(to encoder: Encoder) throws {
    }
}

