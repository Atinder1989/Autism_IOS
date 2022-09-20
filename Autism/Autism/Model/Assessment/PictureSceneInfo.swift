//
//  PictureSceneInfo.swift
//  Autism
//
//  Created by Dilip Saket on 12/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation

struct PictureSceneInfo: Codable
{
//    "question_type": "2-10 items on screen and verbal instruction/question → select 1 item",
//                "_id": "631d8cd023240063a0925a89",
//                "question_title": "Where is the white animal.",
//                "language_code": "en",
//                "level": "5",
//                "screen_type": "picture_scene_touch_object",
//                "video_url": "",
//                "req_no": "vpsmts",
//                "trial_time": 10,
//                "completion_time": 20,
//                "status": "Active",
//                "course_type": "Assessment",
//                "video": "none",
//                "correct_answer": "10",
//                "incorrect_text": "better luck next time..!!",
//                "correct_text": "good job...!!",
//                "order_num": 283,
//                "next_question_order_no": -1,
//                "image_count": 16,
    var id: String
    var content_type: String
    var question_type: String
    var question_title: String
    var language_code: String
    var screen_type: String
    var correct_answer: String
    var trial_time: Int
    var completion_time: Int
    var req_no: String
    var skill_domain_id: String
    var level:String
    
    var bg_image:String
    var image_count:Int
    var image_with_text:[ImageModel]
    var program_id: String

    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.content_type           = try container.decodeIfPresent(String.self, forKey: .content_type) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.question_title         = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        self.correct_answer         = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        self.screen_type            = try container.decodeIfPresent(String.self, forKey: .screen_type) ?? ""
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.trial_time             = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time         = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.req_no                 = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id        = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""

        self.image_with_text                 = try container.decodeIfPresent([ImageModel].self, forKey: .image_with_text) ?? []
        
        self.image_count            = try container.decodeIfPresent(Int.self, forKey: .image_count) ?? 0
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""

        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
        self.bg_image = try container.decodeIfPresent(String.self, forKey: .bg_image) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
