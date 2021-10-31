//
//  ScriptSubmitResponseVO.swift
//  Autism
//
//  Created by Savleen on 04/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ScriptSubmitResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var questionType: String
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.questionType = try dataContainer.decodeIfPresent(String.self, forKey: .questionType) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}

