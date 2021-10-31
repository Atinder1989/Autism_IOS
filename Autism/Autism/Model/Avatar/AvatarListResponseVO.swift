//
//  AvatarListResponseVO.swift
//  Autism
//
//  Created by Savleen on 30/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct AvatarListResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var list: [ImageModel]
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        
        self.list = try dataContainer.decodeIfPresent([ImageModel].self, forKey: .avtar_list) ?? []
        
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}
