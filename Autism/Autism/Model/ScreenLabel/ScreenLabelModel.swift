//
//  ScreenLabelModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ScreenLabelModel: Codable {
    var label_code: String
    var label_text: String
    var error_text: String
    
    init(code:String,text:String,errorText:String) {
        self.label_code = ""
        self.label_text = ""
        self.error_text = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.label_code = try container.decodeIfPresent(String.self, forKey: .label_code) ?? ""
        self.label_text = try container.decodeIfPresent(String.self, forKey: .label_text) ?? ""
        self.error_text = try container.decodeIfPresent(String.self, forKey: .error_text) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {}
}

