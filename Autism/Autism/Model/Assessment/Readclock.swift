//
//  Readclock.swift
//  Autism
//
//  Created by mac on 19/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct Readclock: Codable {
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
    var answer_time: String
    var hour: String
    var minute: String
    var answere: [VideoAnswer]
    var skill_domain_id: String
    var program_id: String

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
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.assessment_type          = try container.decodeIfPresent(String.self, forKey: .assessment_type) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.answer_time          = try container.decodeIfPresent(String.self, forKey: .answer_time) ?? ""
        self.minute          = try container.decodeIfPresent(String.self, forKey: .minute) ?? ""
        self.hour          = try container.decodeIfPresent(String.self, forKey: .hour) ?? ""
                
        self.answer_time = (self.hour.count==1 ? "0"+self.hour:self.hour+":")+":"+(self.minute.count==1 ? "0"+self.minute:self.minute)
         
        self.answere    = try container.decodeIfPresent([VideoAnswer].self, forKey: .answers) ?? []
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.program_id         = ""

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}


