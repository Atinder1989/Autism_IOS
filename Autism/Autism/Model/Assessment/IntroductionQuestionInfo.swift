//
//  IntroductionQuestionInfo.swift
//  Autism
//
//  Created by Dilip Technology on 13/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct IntroductionQuestionInfo: Codable {
    
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var trial_time: Int
    var answer: String
    var image: String
    var req_no: String
    var skill_domain_id: String
    var level:String
    var program_id: String

    var correct_text: String = ""
    var incorrect_text: String = ""
    
    var vocabulary_list:VocabularyListModel = VocabularyListModel()
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
         self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
         self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
         self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
         self.answer          = try container.decodeIfPresent(String.self, forKey: .answer) ?? ""
         self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    
        self.vocabulary_list = try container.decodeIfPresent(VocabularyListModel.self, forKey: .vocabulary_list) ?? VocabularyListModel()
    }

    func encode(to encoder: Encoder) throws {
    }
    
}
