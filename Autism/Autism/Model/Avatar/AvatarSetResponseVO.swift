//
//  AvatarSetResponseVO.swift
//  Autism
//
//  Created by Savleen on 31/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct AvatarSetResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var screen_id: String
    var avtar_variations_List: [AvatarModel]

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        let userDetailContainer = try dataContainer.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .userResult)
        self.screen_id = try userDetailContainer.decodeIfPresent(String.self, forKey: .screen_id) ?? ""
        self.avtar_variations_List = try dataContainer.decodeIfPresent([AvatarModel].self, forKey: .avtar_variations) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}


