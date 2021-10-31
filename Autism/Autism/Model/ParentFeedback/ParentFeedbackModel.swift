//
//  ParentFeedbackModel.swift
//  Autism
//
//  Created by Savleen on 19/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ParentFeedbackModel: Codable {
    var skill_domain_id: String
    var level: String
    var order: Int
    var language_code: String
    var skill_name: String
    var programTypeList:[ProgramTypeModel]
    
   init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.skill_domain_id          = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.order          = try container.decodeIfPresent(Int.self, forKey: .order) ?? 0
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.skill_name          = try container.decodeIfPresent(String.self, forKey: .skill_name) ?? ""
        self.programTypeList   = try container.decodeIfPresent([ProgramTypeModel].self, forKey: .program_type) ?? []
    }

    func encode(to encoder: Encoder) throws {
    }
}
