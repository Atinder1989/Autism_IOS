//
//  ReinforceMultiChoiceInfo.swift
//  Autism
//
//  Created by Dilip Technology on 12/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ReinforceMultiChoiceInfo: Codable {
    
    var correct_answer: String
    var enable_reinforcer:Bool = false
    var level: String
    var program_id: String
    var question_title: String
    var question_type: String
    var req_no: String
    var skill_domain_id: String
    
    
    var imagesList: [ImageModel]
    var answerImage: ImageModel
    
    var questionData:ReinforceMultiChoiceData
    
    //Extra
    var id: String
//    var assessment_type: String
    var trial_time: Int
    var completion_time: Int
//
//    var video_url: String


    var correct_text: String = ""
    var incorrect_text: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)

        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""

//        self.correct_answer          = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? ""
        self.level = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id =  try container.decodeIfPresent(String.self, forKey: .program_id) ?? ""
        self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.skill_domain_id     = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        
        
        self.imagesList          = try container.decodeIfPresent([ImageModel].self, forKey: .rein_force_non_preferreds) ?? []
        
        self.answerImage         = try container.decodeIfPresent(ImageModel.self, forKey: .correct_image) ?? ImageModel()
        self.questionData        = try container.decodeIfPresent(ReinforceMultiChoiceData.self, forKey: .questionData) ?? ReinforceMultiChoiceData()
        
        self.imagesList.append(self.answerImage)
        
        self.enable_reinforcer = try container.decodeIfPresent(Bool.self, forKey: .enable_reinforcer) ?? false

        self.correct_answer = String(self.imagesList.count)
                
        self.trial_time = questionData.trial_time
        self.completion_time = questionData.completion_time
        self.id = questionData.id
    
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}

struct ReinforceMultiChoiceData: Codable {
    
    var id: String
    var completion_time: Int
    var course_type:String
    var trial_time: Int
    var screen_type: String
    
    var video_url: String

    init() {
        self.completion_time = 0
        self.id = ""
        self.course_type = ""
        self.trial_time = 0
        
        self.screen_type = ""
        self.video_url = ""
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)

        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.course_type          = try container.decodeIfPresent(String.self, forKey: .course_type) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.screen_type     = try container.decodeIfPresent(String.self, forKey: .screen_type) ?? ""
        self.video_url     = try container.decodeIfPresent(String.self, forKey: .video_url) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
