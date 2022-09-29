//
//  LearningProgramModel.swift
//  Autism
//
//  Created by Savleen on 31/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct LearningProgramModel: Codable {
    
    //New Parameters
    var vocabulary_list:VocabularyListModel = VocabularyListModel()
    var course_type: String = ""
    var content_type: String = ""
    var bucket: String = ""
    var index: Int = 0
    var table_name: String = ""
    
    var level: String = ""
    
    
    var program_id: String
    var label_code: ProgramCode
    var program_name: String
    var program_image: String
    var program_order: Int
    var assement_complete_rate: Int
    var trial_complete_rate: Int
    var learning_complete_rate: Int
    
    var assement_attempt_status: Bool
    var learning_attempt_status: Bool
    var trial_attempt_status: Bool

    
    var learning_current_status: ModuleStatus
    var learning_status: ModuleStatus
    var trial_status: ModuleStatus
    var isLocked: Bool
    var tag: Int

    
    init() {
        
        self.course_type = ""
        self.content_type = ""
        self.bucket = ""
        self.level = ""
        
        self.index = 0
        self.table_name = ""

        self.program_id = ""
        self.label_code = .none
        self.program_name = ""
        self.program_image = ""
        self.program_order = 0
        self.assement_complete_rate = 0
        self.trial_complete_rate = 0
        self.learning_complete_rate = 0
        self.learning_current_status = .none
        self.learning_status = .none
        self.trial_status = .none
        self.isLocked = false
        self.learning_attempt_status = false
        self.trial_attempt_status = false
        self.assement_attempt_status = false
        self.tag = 0
    }
    
   init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.program_id          = try container.decodeIfPresent(String.self, forKey: .program_id) ?? ""
        let labelCode = try container.decodeIfPresent(String.self, forKey: .label_code) ?? ""
        if let code =  ProgramCode.init(rawValue: labelCode) {
            self.label_code = code
        } else {
            self.label_code = .none
        }
        self.program_name          = try container.decodeIfPresent(String.self, forKey: .program_name) ?? ""
        self.program_image = ""
      //  self.program_image          = try container.decodeIfPresent(String.self, forKey: .program_image) ?? ""
        self.program_order          = try container.decodeIfPresent(Int.self, forKey: .program_order) ?? 0
        self.assement_complete_rate          = try container.decodeIfPresent(Int.self, forKey: .assement_complete_rate) ?? 0
        self.trial_complete_rate          = try container.decodeIfPresent(Int.self, forKey: .trial_complete_rate) ?? 0
        self.learning_complete_rate          = try container.decodeIfPresent(Int.self, forKey: .learning_complete_rate) ?? 0
    
        self.assement_attempt_status          = try container.decodeIfPresent(Bool.self, forKey: .assement_attempt_status) ?? false

        self.learning_attempt_status          = try container.decodeIfPresent(Bool.self, forKey: .learning_attempt_status) ?? false
        self.trial_attempt_status          = try container.decodeIfPresent(Bool.self, forKey: .trial_attempt_status) ?? false

        let lcStatus = try container.decodeIfPresent(String.self, forKey: .learning_current_status) ?? ""
        let lStatus = try container.decodeIfPresent(String.self, forKey: .learning_status) ?? ""
        let tStatus = try container.decodeIfPresent(String.self, forKey: .trial_status) ?? ""
        
        if let status =  ModuleStatus.init(rawValue: lcStatus) {
            self.learning_current_status = status
        } else {
            self.learning_current_status = .none
        }
        
        if let status =  ModuleStatus.init(rawValue: lStatus) {
            self.learning_status = status
        } else {
            self.learning_status = .none
        }
        
        if let status =  ModuleStatus.init(rawValue: tStatus) {
            self.trial_status = status
        } else {
            self.trial_status = .none
        }
        self.isLocked = false
        self.tag = 0
    
    }

    func encode(to encoder: Encoder) throws {
    }
}

struct VocabularyListModel: Codable {

    var id: String = ""
    var name: String = ""
    var value: String = ""

    init() {
        self.id = ""
        self.name = ""
        self.value = ""
    }
    
   init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id             = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.name           = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.value          = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}

