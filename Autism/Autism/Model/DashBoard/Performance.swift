//
//  Performance.swift
//  Autism
//
//  Created by Savleen on 03/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


struct History: Codable {
    var title: String
    var start_date: String
    var end_date: String
    var performanceList: [Performance]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.title          = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.start_date          = try container.decodeIfPresent(String.self, forKey: .start_date) ?? ""
        self.end_date          = try container.decodeIfPresent(String.self, forKey: .end_date) ?? ""
        self.performanceList = try container.decodeIfPresent([Performance].self, forKey: .performance) ?? []
    }

    func encode(to encoder: Encoder) throws {
    }
}

struct Performance: Codable {
    var level: String
    var status: Bool
    var title: String
    var message: String
    var complete_count: Int
    var count: Int

    var performanceDetail: [PerformanceDetail]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.status          = try container.decodeIfPresent(Bool.self, forKey: .status) ?? false

        self.title          = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.message          = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.complete_count          = try container.decodeIfPresent(Int.self, forKey: .complete_count) ?? 0
        self.count          = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        self.performanceDetail          = try container.decodeIfPresent([PerformanceDetail].self, forKey: .detail) ?? []
    }

    func encode(to encoder: Encoder) throws {
    }
}

struct PerformanceDetail: Codable {
    var order: Int
    var skill_domain_id: String
    var key: String
    var level: String
    var assesment_score: Int
    var assesment_status: ModuleStatus
    var assesment_question: Bool

    var progressColor: UIColor = .clear
    var trackColor: UIColor = .clear
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.order          = try container.decodeIfPresent(Int.self, forKey: .order) ?? 0
        self.skill_domain_id          = try container.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.key          = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        self.assesment_score          = try container.decodeIfPresent(Int.self, forKey: .assesment_score) ?? 0
        self.assesment_question          = try container.decodeIfPresent(Bool.self, forKey: .assesment_question) ?? false

        
        let status = try container.decodeIfPresent(String.self, forKey: .assesment_status) ?? ""
        if let value =  ModuleStatus.init(rawValue: status) {
            self.assesment_status = value
        } else {
            self.assesment_status = .none
        }
        let tuple = self.getColor()
        self.progressColor = tuple.progressColor
        self.trackColor = tuple.trackColor
   }

    func encode(to encoder: Encoder) throws {
    }
    
    private func getColor () -> (progressColor:UIColor,trackColor: UIColor) {
        var tuple:(progressColor:UIColor,trackColor: UIColor) = (progressColor:.clear,trackColor:.clear)
            if self.assesment_score < 50 // Red
            {
                tuple.progressColor = UIColor.init(red: 255/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
                tuple.trackColor = UIColor.init(red: 247/255.0, green: 228/255.0, blue: 234/255.0, alpha: 1)
            } else if self.assesment_score >= 50 && self.assesment_score <= 60 // Yellow
            {
                tuple.progressColor = UIColor.init(red: 255/255.0, green: 177/255.0, blue: 29/255.0, alpha: 1)
                tuple.trackColor = UIColor.init(red: 247/255.0, green: 239/255.0, blue: 230/255.0, alpha: 1)
            } else {
                tuple.progressColor = UIColor.init(red: 82/255.0, green: 232/255.0, blue: 140/255.0, alpha: 1)
                tuple.trackColor = UIColor.init(red: 229/255.0, green: 245/255.0, blue: 241/255.0, alpha: 1)
            }
        return tuple
    }
}


