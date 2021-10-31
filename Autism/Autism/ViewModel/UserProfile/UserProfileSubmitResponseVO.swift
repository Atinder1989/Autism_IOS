//
//  UserProfileSubmitResponseVO.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct UserProfileSubmitResponseVO: Codable {
var success: Bool
var message: String
var screen_id: String
var nickname: String

init(from decoder:Decoder) throws {
    let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
    self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
    self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
    let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
    self.screen_id = try dataContainer.decodeIfPresent(String.self, forKey: .screen_id) ?? ""
    self.nickname = try dataContainer.decodeIfPresent(String.self, forKey: .nickname) ?? ""
    print(self.nickname)
    }
}
