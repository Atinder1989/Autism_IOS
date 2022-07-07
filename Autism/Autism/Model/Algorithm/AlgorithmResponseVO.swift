//
//  AlgorithmResponseVO.swift
//  Autism
//
//  Created by Savleen on 25/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct AlgorithmResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var data : AlgorithmData?
    var showSkillprogram : Bool
    var skillprogramDetail : LearningSkillProgramResponseVO?
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.data = try container.decodeIfPresent(AlgorithmData.self, forKey: .data) ?? nil
        self.showSkillprogram = try container.decodeIfPresent(Bool.self, forKey: .showSkillprogram) ?? false
        if self.showSkillprogram{
            self.skillprogramDetail = try container.decodeIfPresent(LearningSkillProgramResponseVO.self, forKey: .skillprogramDetail) ?? nil
        } else {
            self.skillprogramDetail = nil
        }
     }
    
    func encode(to encoder: Encoder) throws {
        
    }
}

struct AlgorithmData: Codable {
    
    var course_type: CourseModule
    var learninginfo: LearningInfo?
    var trialInfo:TrialInfo?
    var mandInfo:MandInfo?

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.learninginfo = nil
        self.trialInfo = nil
        self.mandInfo = nil
        
        let type = try container.decodeIfPresent(String.self, forKey: .course_type) ?? ""
        if let cType =  CourseModule.init(rawValue: type) {
            self.course_type = cType
        } else {
            self.course_type = .none
        }

        switch self.course_type {
        case .learning:
            self.learninginfo = try container.decodeIfPresent(LearningInfo.self, forKey: .info) ?? nil
            self.learninginfo?.course_type = type
        case .trial:
            self.trialInfo = try container.decodeIfPresent(TrialInfo.self, forKey: .info) ?? nil
            break
        case .mand :
            self.mandInfo = try container.decodeIfPresent(MandInfo.self, forKey: .info) ?? nil
            self.mandInfo?.course_type = type
        default:
            break
        }
        
     }
    
    func encode(to encoder: Encoder) throws {
        
    }
}

struct LearningInfo: Codable {
    
    //New Development
    var course_type: String
    var content_type: String
    var bucket: String
    var index: Int
    var table_name: String
    
    var question_id: String
    var skill_domain_id: String
    var program_id: String
    var label_code: String
    var level: String
    
    var command_array: [ScriptCommandInfo] = []

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        
        self.course_type = try container.decodeIfPresent(String.self, forKey: .course_type) ?? ""
        self.content_type = try container.decodeIfPresent(String.self, forKey: .content_type) ?? ""
        self.bucket = try container.decodeIfPresent(String.self, forKey: .bucket) ?? ""
        self.table_name = try container.decodeIfPresent(String.self, forKey: .table_name) ?? ""
        
        self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
        
        self.question_id = try container.decodeIfPresent(String.self, forKey: .question_id) ?? ""
        self.skill_domain_id = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.program_id = try container.decodeIfPresent(String.self, forKey: .program_id) ?? ""
        self.label_code = try container.decodeIfPresent(String.self, forKey: .label_code) ?? ""
        self.level = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.command_array = try container.decodeIfPresent([ScriptCommandInfo].self, forKey: .command_array) ?? []
     }
    
    func encode(to encoder: Encoder) throws {
        
    }
}


