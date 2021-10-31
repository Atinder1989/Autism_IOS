//
//  CommonMessageResponseVO.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/14.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct CommonMessageResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var screenid: String
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.screenid = try dataContainer.decodeIfPresent(String.self, forKey: .screen_id) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}

