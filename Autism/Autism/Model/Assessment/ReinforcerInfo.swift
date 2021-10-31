//
//  ReinforcerInfo.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ReinforcerInfo: Codable {
    var id: String
    var name: String
    var info: String
    var language_code: String
    var image: String
    var questionTitle: String
    var req_no: String
    var skill_domain_id: String
    var level:String
    var program_id: String
    var trial_time: Int
    var completion_time: Int

    var correct_text: String = ""
    var incorrect_text: String = ""
    

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.info          = try container.decodeIfPresent(String.self, forKey: .info) ?? ""
        self.name          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.questionTitle = ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""
        self.trial_time             = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time         = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
