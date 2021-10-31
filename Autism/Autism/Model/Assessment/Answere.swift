//
//  Answere.swift
//  Autism
//
//  Created by mac on 18/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct Answere: Codable {
    var name: String
    var id: String
    var image: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
       
        self.name          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        
        self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
    }

    func encode(to encoder: Encoder) throws {
    }
}
