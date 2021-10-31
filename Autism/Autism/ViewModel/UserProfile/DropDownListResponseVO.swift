//
//  DropDownListResponseVO.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


struct DropDownListResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var sensoryIssueList: [OptionModel]
    var challengingBehaviourList: [OptionModel]
    var reinforcerList: [OptionModel]
    var dietList: [OptionModel]
    var otherDetail: [OptionModel]

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.sensoryIssueList = try dataContainer.decodeIfPresent([OptionModel].self, forKey: .sensory_issue) ?? []
        self.challengingBehaviourList = try dataContainer.decodeIfPresent([OptionModel].self, forKey: .challenging_behaviour) ?? []
        self.reinforcerList = try dataContainer.decodeIfPresent([OptionModel].self, forKey: .reinforcer) ?? []
        self.dietList = try dataContainer.decodeIfPresent([OptionModel].self, forKey: .diet) ?? []
        self.otherDetail = try dataContainer.decodeIfPresent([OptionModel].self, forKey: .other_detail) ?? []
}
    
    func encode(to encoder: Encoder) throws {
        
    }
 }
