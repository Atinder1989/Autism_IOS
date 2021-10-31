//
//  DashboardPerformanceResponseVO.swift
//  Autism
//
//  Created by Savleen on 03/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct DashboardPerformanceResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var assessment_status : ModuleStatus
    var learning_status : ModuleStatus
    var history: [History]
    var all_dates: [AllDates]

    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.history = try dataContainer.decodeIfPresent([History].self, forKey: .history) ?? []
        self.all_dates = try dataContainer.decodeIfPresent([AllDates].self, forKey: .all_dates) ?? []

        let aStatus = try dataContainer.decodeIfPresent(String.self, forKey: .assessment_status) ?? ""
        if let status =  ModuleStatus.init(rawValue: aStatus) {
            self.assessment_status = status
        } else {
            self.assessment_status = .none
        }
        
        let lStatus = try dataContainer.decodeIfPresent(String.self, forKey: .learning_status) ?? ""
        if let status =  ModuleStatus.init(rawValue: lStatus) {
            self.learning_status = status
        } else {
            self.learning_status = .none
        }
        
    }

    func encode(to encoder: Encoder) throws {

    }
}


struct AllDates: Codable {
    var title: String
    var start_date: String
    var end_date: String
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.start_date = try container.decodeIfPresent(String.self, forKey: .start_date) ?? ""
        self.end_date = try container.decodeIfPresent(String.self, forKey: .end_date) ?? ""
    }
}
