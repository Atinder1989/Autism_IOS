//
//  ScreenLabelResponseVO.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ScreenLabelResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var literalList: [ScreenLabelModel]
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.literalList = try dataContainer.decodeIfPresent([ScreenLabelModel].self, forKey: .docs) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
    func getLiteralof(code:String) -> ScreenLabelModel {
        let m = self.literalList.filter{ $0.label_code == code }
        
        if m.count > 0 {
            return m[0]
        }
       
        return ScreenLabelModel.init(code: "", text: "", errorText: "")
    }
}


