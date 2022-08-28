//
//  MandInfo.swift
//  Autism
//
//  Created by Dilip Saket on 03/07/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation

struct MandInfo: Codable {

    var new_correct_question_till_mand: Int
    var course_type: String
    var content_type: String
    var table_name: String
    
    var force_youtube:Int
    var time_till_no_object_selected:Int
    var response_type: String
    
    var language: String
    var level: String
    
    var array_of_objects:[MandObject]
    
    var question_type: String = ""
    var screen_type: String = ""

    var skill_domain_id: String?
    var program_id: String?

    init(from decoder:Decoder) throws {
        
        let dataContainer = try decoder.container(keyedBy: ServiceParsingKeys.self)
                        
        self.new_correct_question_till_mand = try dataContainer.decodeIfPresent(Int.self, forKey: .new_correct_question_till_mand) ?? 0
        self.course_type = try dataContainer.decodeIfPresent(String.self, forKey: .course_type) ?? ""
        self.content_type = try dataContainer.decodeIfPresent(String.self, forKey: .content_type) ?? ""
        self.table_name = try dataContainer.decodeIfPresent(String.self, forKey: .table_name) ?? ""
        
        self.force_youtube = try dataContainer.decodeIfPresent(Int.self, forKey: .force_youtube) ?? 0
        self.time_till_no_object_selected = try dataContainer.decodeIfPresent(Int.self, forKey: .time_till_no_object_selected) ?? 0
        self.response_type = try dataContainer.decodeIfPresent(String.self, forKey: .response_type) ?? ""
        
        self.language = try dataContainer.decodeIfPresent(String.self, forKey: .language) ?? ""
        self.level = try dataContainer.decodeIfPresent(String.self, forKey: .level) ?? ""
        
        self.array_of_objects = try dataContainer.decodeIfPresent([MandObject].self, forKey: .array_of_objects) ?? []
    }
    

    func encode(to encoder: Encoder) throws {

    }
}



