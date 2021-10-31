//
//  LearningSkillProgramResponseVO.swift
//  Autism
//
//  Created by Savleen on 31/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct LearningSkillProgramResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var id: String
    var skill_domain_id : String
    var skill_domain_name : String
    var skill_domain_image : String
    var learningProgramList : [LearningProgramModel]
    
    init() {
        self.success = false
        self.statuscode = 0
        self.message = ""
        self.id = ""
        self.skill_domain_id = ""
        self.skill_domain_name = ""
        self.skill_domain_image = ""
        self.learningProgramList = []
    
    }
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.id = try dataContainer.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.skill_domain_id = try dataContainer.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.skill_domain_name = try dataContainer.decodeIfPresent(String.self, forKey: .skill_domain_name) ?? ""
        self.skill_domain_image = try dataContainer.decodeIfPresent(String.self, forKey: .skill_domain_image) ?? ""
      
        let programlist = try dataContainer.decodeIfPresent([LearningProgramModel].self, forKey: .program) ?? []
        self.learningProgramList = []
        self.learningProgramList = self.updateProgramLockStatus(programlist: programlist)
    }

    func encode(to encoder: Encoder) throws {

    }
    
    
    private func updateProgramLockStatus(programlist:[LearningProgramModel]) -> [LearningProgramModel] {
        var updatedList = [LearningProgramModel]()
        var isPending = false
        for model in programlist {
            if model.learning_status == .pending && model.trial_status == .pending {
                if !isPending {
                    isPending = true
                    updatedList.append(model)
                } else {
                    var newModel = model
                    newModel.isLocked = true
                    updatedList.append(newModel)
                }
            } else {
                updatedList.append(model)
            }
        }
        return updatedList
    }
    
    
}
