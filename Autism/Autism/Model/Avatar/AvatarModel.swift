//
//  AvatarModel.swift
//  Autism
//
//  Created by Savleen on 31/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct AvatarModel: Codable {
    var id: String
    var avtar_id: String
    var file: String
    var file_type: String
    var variation_type: String
    var isDownloaded: Bool
    
    init() {
        self.id = ""
        self.avtar_id = ""
        self.file = ""
        self.file_type = ""
        self.variation_type = ""
        self.isDownloaded = false

    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
       self.avtar_id          = try container.decodeIfPresent(String.self, forKey: .avtar_id) ?? ""
        self.file          = try container.decodeIfPresent(String.self, forKey: .file) ?? ""
        self.file_type          = try container.decodeIfPresent(String.self, forKey: .file_type) ?? ""
        self.variation_type          = try container.decodeIfPresent(String.self, forKey: .variation_type) ?? ""
        self.isDownloaded = false
    }

    func encode(to encoder: Encoder) throws {
    }
}


