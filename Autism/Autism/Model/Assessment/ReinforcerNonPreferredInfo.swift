//
//  ReinforcerNonPreferredInfo.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ReinforcerNonPreferredInfo: Codable {
    var id: String
    var image: String
    var question_type: String
    var name: String
    var language_code: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.question_type          = try container.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.name          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
