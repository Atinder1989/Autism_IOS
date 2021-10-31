//
//  PuzzleBlock.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct PuzzleBlock: Codable {
    var image: String
    var empty_image: String
    var id: String
    var is_hidden: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id             = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.empty_image    = try container.decodeIfPresent(String.self, forKey: .empty_image) ?? ""
        self.is_hidden      = try container.decodeIfPresent(Bool.self, forKey: .is_hidden) ?? false
    }

    func encode(to encoder: Encoder) throws {
    }
}
