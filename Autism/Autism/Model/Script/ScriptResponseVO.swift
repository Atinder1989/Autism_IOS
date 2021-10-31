//
//  ScriptResponseVO.swift
//  Autism
//
//  Created by Dilip Technology on 22/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ScriptResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var command_array: [ScriptCommandInfo] = []
    var question_id: String
    
    init() {
        self.success = false
        self.statuscode = 0
        self.message = ""
        self.command_array = []
        self.question_id = ""
    }

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.command_array = []
        self.question_id = ""
        if self.success {
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.question_id = try dataContainer.decodeIfPresent(String.self, forKey: .question_id) ?? ""
        self.command_array = try dataContainer.decodeIfPresent([ScriptCommandInfo].self, forKey: .command_array) ?? []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}
