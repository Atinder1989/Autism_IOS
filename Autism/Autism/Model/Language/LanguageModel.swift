//
//  Language.swift
//  Autism
//
//  Created by IMPUTE on 30/01/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import UIKit

struct LanguageModel: Codable {
    var name: String
    var code: String
    var image: String
    var status: String
    
    init(name:String,code:String,image:String,status:String) {
        self.name = name
        self.code = code
        self.image = image
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {}
}
