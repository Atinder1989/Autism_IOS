//
//  VideoQuestion.swift
//  Autism
//
//  Created by mac on 08/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct VideoQuestion: Codable {
    var image: String
    var id: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
       
        self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
