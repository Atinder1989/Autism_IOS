//
//  LoginResponseVO.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/14.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct LoginResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var userVO: UserModel?
    var avtar_variations_List: [AvatarModel]

    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        
        self.userVO = nil
        self.avtar_variations_List = []
        if success {
            let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
            self.userVO = try dataContainer.decodeIfPresent(UserModel.self, forKey: .user) ?? nil
            self.userVO?.token = try dataContainer.decodeIfPresent(String.self, forKey: .token) ?? ""
            self.userVO?.languageCode = selectedLanguageModel.code
            self.userVO?.languageName = selectedLanguageModel.name
            self.userVO?.languageImage = selectedLanguageModel.image
            self.avtar_variations_List = try dataContainer.decodeIfPresent([AvatarModel].self, forKey: .avtar_variations) ?? []
            let avatarModel = try dataContainer.decodeIfPresent(ImageModel.self, forKey: .avtar_data) ?? nil
            if let model = avatarModel {
                self.userVO?.avatar = model.image
                self.userVO?.avatar_gender = model.avtar_gender
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}
