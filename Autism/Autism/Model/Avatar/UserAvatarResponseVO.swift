//
//  UserAvatarResponseVO.swift
//  Autism
//
//  Created by Savleen on 02/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct UserAvatarResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var avatar: ImageModel?
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        
        self.avatar = nil
        if success {
            let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
            let id = try dataContainer.decodeIfPresent(String.self, forKey: .id) ?? ""
            let name = try dataContainer.decodeIfPresent(String.self, forKey: .name) ?? ""
            let image = try dataContainer.decodeIfPresent(String.self, forKey: .image) ?? ""
            var model = ImageModel.init()
            model.image = image
            model.id = id
            model.name = name
            self.avatar = model
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}


















