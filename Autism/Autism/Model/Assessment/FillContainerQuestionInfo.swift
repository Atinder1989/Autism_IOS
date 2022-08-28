//
//  FillContainerQuestionInfo.swift
//  Autism
//
//  Created by Dilip Technology on 30/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct FillContainerQuestionInfo: Codable {
    var id: String
    
    var question_type: String
    var question_title: String
    var language_code: String
    var trial_time: Int
    var completion_time: Int
    var bucketList_count: Int
    var imagesList_count: Int
    var correct_answer: String
    var correct_object_count: Int

    var req_no: String
    var imagesList: [ImageModel]
    var bucketList: [ImageModel]
    var skill_domain_id: String
    var level:String
    var program_id: String
    var bg_image:String
    
    var correct_text: String = ""
    var incorrect_text: String = ""
    var content_type: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.question_title          = try container.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.trial_time          = try container.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
        self.completion_time          = try container.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
        self.bucketList_count          = try container.decodeIfPresent(Int.self, forKey: .bucketList_count) ?? 0
        self.imagesList_count          = try container.decodeIfPresent(Int.self, forKey: .imagesList_count) ?? 0
        //self.bucketList_count          = try container.decodeIfPresent(String.self, forKey: .bucketList_count) ?? ""
        //self.imagesList_count          = try container.decodeIfPresent(String.self, forKey: .imagesList_count) ?? ""
        
        self.correct_answer = try container.decodeIfPresent(String.self, forKey: .correct_answer) ?? "0"        
        self.correct_object_count          = try container.decodeIfPresent(Int.self, forKey: .correct_object_count) ?? 0        

        self.req_no          = try container.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        self.imagesList          = try container.decodeIfPresent([ImageModel].self, forKey: .imagesList) ?? []
        self.bucketList          = try container.decodeIfPresent([ImageModel].self, forKey: .bucketList) ?? []
        self.skill_domain_id         = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level                  = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.program_id         = ""
        
        self.bg_image            = try container.decodeIfPresent(String.self, forKey: .bg_image) ?? ""
        let video:String            = try container.decodeIfPresent(String.self, forKey: .video) ?? ""        
        if(self.bg_image == "") {
            self.bg_image = video
        }
        self.correct_text          = try container.decodeIfPresent(String.self, forKey: .correct_text) ?? ""
        self.incorrect_text          = try container.decodeIfPresent(String.self, forKey: .incorrect_text) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
