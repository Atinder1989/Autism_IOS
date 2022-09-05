//
//  ImageModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


struct ImageModel: Codable {
    var image: String
    var empty_image: String
    var id: String
    var name: String
    var avtar_gender: String

    var position: String
    var isCorrectAnswer: Bool
    let degrees:Double = Double.random(in: -30..<30)
    
    var info:String
    var label_code:String
    var language_code:String
    var index:Int
    
    init() {
        self.index = 0
        self.image = ""
        self.empty_image = ""
        self.id = ""
        self.name = ""
        self.position = ""
        self.isCorrectAnswer = false
        self.avtar_gender = ""
        self.info = ""
        self.label_code = ""
        self.language_code = ""
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.image          = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.empty_image     = try container.decodeIfPresent(String.self, forKey: .empty_image) ?? ""
        self.name          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.position          = try container.decodeIfPresent(String.self, forKey: .position) ?? ""
        self.isCorrectAnswer = false
        
        self.info          = try container.decodeIfPresent(String.self, forKey: .info) ?? ""
        self.label_code          = try container.decodeIfPresent(String.self, forKey: .label_code) ?? ""
        self.language_code          = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.avtar_gender          = try container.decodeIfPresent(String.self, forKey: .avtar_gender) ?? ""
        
        self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
    }

    func encode(to encoder: Encoder) throws {
    }
}
