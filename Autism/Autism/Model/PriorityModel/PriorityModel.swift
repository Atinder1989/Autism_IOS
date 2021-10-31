//
//  PriorityModel.swift
//  Autism
//
//  Created by mac on 23/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct PriorityModel: Codable {
    var id: String
    var name: String
    var email: String
    var verified: Bool
    var verification: String
    var token: String
    var language: String
    var screen_id: String
    var priority: Int
    var level: String
   

    
    init() {
        self.id = ""
        self.name = ""
        self.email = ""
        self.verified = false
        self.verification = ""
        self.token = ""
        self.language = ""
        self.screen_id = ""
        self.priority = 0
        self.level = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.name          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.email          = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.verified          = try container.decodeIfPresent(Bool.self, forKey: .verified) ?? false
        self.verification          = try container.decodeIfPresent(String.self, forKey: .verification) ?? ""
        self.screen_id          = try container.decodeIfPresent(String.self, forKey: .screen_id) ?? ""
        self.priority          = try container.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        self.level          = try container.decodeIfPresent(String.self, forKey: .level) ?? ""
        print(screen_id)
        self.token = ""
        self.language = ""
     }

    func encode(to encoder: Encoder) throws {
    }
    
}
