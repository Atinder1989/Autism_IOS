//
//  IntroVideoQuestionInfo.swift
//  Autism
//
//  Created by Savleen on 26/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
struct IntroVideoQuestionInfo: Codable {
    var question_type: String
    var id: String
    var question_title: String
    var language_code: String
    var image: String
    var trial_time: Int
    var completion_time: Int
    var level: String
    var video_url: String
    var req_no: String
    var skill_domain_id: String
    var program_id: String

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
        self.video_url          = try container.decodeIfPresent(String.self, forKey: .video_url) ?? ""
      }

    func encode(to encoder: Encoder) throws {
    }
    
}
