//
//  FindObject.swift
//  Autism
//
//  Created by mac on 18/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


struct FindObject: Codable {
    var success: Bool
    var id: String
    var question_type: String
    var question_title: String
    var language_code: String
    var status: String
    var bg_image: String
    var level: String
    var assessment_type: String
    var req_no: String
    var trial_time: Int
    var completion_time: Int
    var correct_answer: String
    var correct_answer_TapCount: Int

    var images: [ImageModel]
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
        self.bg_image  = try container.decodeIfPresent(String.self, forKey: .bg_image) ?? ""
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.assessment_type          = try container.decodeIfPresent(String.self, forKey: .assessment_type) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.correct_answer          = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        
        let arrayFromApi    = try container.decodeIfPresent([ImageModel].self, forKey: .images) ?? []
        var array = [ImageModel]()
        for _ in 0...11 {
            let model = ImageModel.init()
            array.append(model)
        }
        var tapCount = 0
        for model in arrayFromApi {
            if let positionIndex = Int(model.position) {
                array.remove(at: positionIndex - 1)
                array.insert(model, at: positionIndex - 1)
            }
            if model.name == self.correct_answer {
                tapCount += 1
            }
            
        }
        self.images = array
        self.correct_answer_TapCount = tapCount
        self.program_id         = ""

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
