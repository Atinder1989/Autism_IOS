//
//  OtherDetailInfo.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


struct OtherDetailInfo: Codable {
    var name: String
    var language_code: String
    var id: String
    var other_detail_id : String
    
    init(id:String,name:String,lngCode:String,otherDetailId:String) {
        self.id = id
        self.name = name
        self.language_code = lngCode
        self.other_detail_id = otherDetailId
    }
 
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.language_code = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.other_detail_id = try container.decodeIfPresent(String.self, forKey: .other_detail_id) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {}
}
