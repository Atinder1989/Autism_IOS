//
//  SequenceResponseInfo.swift
//  Autism
//
//  Created by Savleen on 07/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct SequenceResponseInfo: Codable {
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var trial_time: Int
    var completion_time: Int
    var word_count: String
    var option_count: String
    var screen_type: String
    var req_no: String
    var skill_domain_id: String
    var optionList: [ImageModel]
    var level:String
    var program_id: String

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
        self.word_count          = try container.decodeIfPresent(String.self, forKey: .word_count) ?? ""
        self.option_count          = try container.decodeIfPresent(String.self, forKey: .option_count) ?? ""
        self.screen_type          = try container.decodeIfPresent(String.self, forKey: .screen_type) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.optionList          = try container.decodeIfPresent([ImageModel].self, forKey: .option) ?? []
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
