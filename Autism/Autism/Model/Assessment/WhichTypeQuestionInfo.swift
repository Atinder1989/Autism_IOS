//
//  WhichTypeQuestionInfo.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct WhichTypeQuestionInfo: Codable {
    var question_type: String
    var id: String
    var question_title: String
    var correct_answer: String
    var req_no: String
    var assessment_type: String
    var trial_time: Int
    var level: String
    var completion_time: Int
    var imagesList: [ImageModel]
    var image_with_text: [ImageModel]
    var skill_domain_id: String
    var video_url: String
    var program_id: String
    var show_circle: String

    var selectedIndex = -1

    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)

        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.show_circle          = try container.decodeIfPresent(String.self, forKey: .show_circle) ?? ""
        self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        self.correct_answer          = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.assessment_type          = try container.decodeIfPresent(String.self, forKey: .assessment_type) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.imagesList          = try container.decodeIfPresent([ImageModel].self, forKey: .images) ?? []
        self.image_with_text          = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []
        self.skill_domain_id     = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.video_url     = try container.decodeIfPresent(String.self, forKey: .video_url) ?? ""
        self.program_id         = ""

        self.level = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}


struct MultiArrayQuestionInfo: Codable {
    
    var question_type: String
    var id: String
    var question_title: String
    var correct_answer: String
    var req_no: String
    var assessment_type: String
    var trial_time: Int
    var level: String
    var completion_time: Int
    var time_interval:Int
    var imagesList: [ImageModel]
    var skill_domain_id: String
    var video_url: String
    var program_id: String
    
    var blocks:[WhichTypeQuestionInfo]

    var correct_text: String
    var incorrect_text: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)

        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        self.correct_answer          = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.assessment_type          = try container.decodeIfPresent(String.self, forKey: .assessment_type) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.time_interval          = try container.decodeIfPresent(Int.self, forKey: .time_interval) ?? 0
        self.imagesList          = try container.decodeIfPresent([ImageModel].self, forKey: .images) ?? []
        self.blocks          = try container.decodeIfPresent([WhichTypeQuestionInfo].self, forKey: .block) ?? []
        self.skill_domain_id     = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.video_url     = try container.decodeIfPresent(String.self, forKey: .video_url) ?? ""
        self.program_id         = ""

//        self.imagesList = self.blocks[0].imagesList
        self.level = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}

