//
//  VideoAnswer.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct VideoAnswer: Codable {
    var name: String
    var id: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
       
        self.name          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
