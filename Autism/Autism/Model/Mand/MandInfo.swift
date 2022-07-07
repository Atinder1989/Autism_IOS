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
    
    init(from decoder:Decoder) throws {
        
        let dataContainer = try decoder.container(keyedBy: ServiceParsingKeys.self)
                        
        self.new_correct_question_till_mand = try dataContainer.decodeIfPresent(Int.self, forKey: .new_correct_question_till_mand) ?? 0
        self.course_type = try dataContainer.decodeIfPresent(String.self, forKey: .course_type) ?? ""
        self.content_type = try dataContainer.decodeIfPresent(String.self, forKey: .content_type) ?? ""
        self.table_name = try dataContainer.decodeIfPresent(String.self, forKey: .table_name) ?? ""
    }
    

    func encode(to encoder: Encoder) throws {

    }
}



