//
//  ParentFeedbackListResponseVO.swift
//  Autism
//
//  Created by Savleen on 19/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ParentFeedbackListResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var feedbackList: [ParentFeedbackModel]
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        let array = try dataContainer.decodeIfPresent([ParentFeedbackModel].self, forKey: .performance) ?? []
      
        var feedbackModelArray = [ParentFeedbackModel]()
        for feedbackModel in array {
            var programTypeArray = [ProgramTypeModel]()
            for (i, program) in feedbackModel.programTypeList.enumerated() {
                if i == 0 {
                    var p = program
                    p.isrowDisable = false
                    programTypeArray.append(p)
                } else {
                    programTypeArray.append(program)
                }
            }
            var m = feedbackModel
            m.programTypeList = programTypeArray
            feedbackModelArray.append(m)
        }
        self.feedbackList = feedbackModelArray
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}
