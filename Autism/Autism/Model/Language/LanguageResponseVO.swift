//
//  LanguageResponseVO.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/12.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct LanguageResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var list: [LanguageModel]

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.list    = try dataContainer.decodeIfPresent([LanguageModel].self, forKey: .docs) ?? []
     }
    
    func encode(to encoder: Encoder) throws {
        
    }
}


