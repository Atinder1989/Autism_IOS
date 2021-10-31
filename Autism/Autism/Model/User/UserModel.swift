//
//  UserModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/14.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct UserModel: Codable {
    var id: String
    var parentName: String
    var email: String
    var verified: Bool
    var verification: String
    var token: String
    var screen_id: String
    var avatar: String
    var avatar_gender: String
    var languageName: String
    var languageCode: String
    var languageImage: String
    var languageStatus: String
    var nickname: String

    init() {
        self.id = ""
        self.parentName = ""
        self.email = ""
        self.verified = false
        self.verification = ""
        self.token = ""
        self.screen_id = ""
        self.avatar = ""
        self.languageName = ""
        self.languageCode = ""
        self.languageImage = ""
        self.languageStatus = ""
        self.nickname = ""
        self.avatar_gender = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.parentName          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.email          = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.verified          = try container.decodeIfPresent(Bool.self, forKey: .verified) ?? false
        self.verification          = try container.decodeIfPresent(String.self, forKey: .verification) ?? ""
        self.screen_id          = try container.decodeIfPresent(String.self, forKey: .screen_id) ?? ""
        self.token = ""
        self.avatar = ""
        self.languageName = ""
        self.languageCode = ""
        self.languageImage = ""
        self.languageStatus = ""
        self.avatar_gender = ""

        self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname) ?? ""
     }

    func encode(to encoder: Encoder) throws {
    }
    
}
