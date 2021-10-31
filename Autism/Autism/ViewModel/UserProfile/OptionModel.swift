//
//  OptionModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


struct OptionModel: Codable {
    var name: String
    var language_code: String
    var image: String
    var isYes: Bool
    var isNo: Bool
    var isDontKnow: Bool
    var id: String
    var info: String

    var otherDetailInfoList: [OtherDetailInfo]
    
    init(id:String,name:String,lngCode:String,isyes:Bool,isno:Bool,isdontknow:Bool,infoList:[OtherDetailInfo],info:String) {
        self.id = id
        self.name = name
        self.language_code = lngCode
        self.isYes = isyes
        self.isNo = isno
        self.isDontKnow = isdontknow
        self.otherDetailInfoList = infoList
        self.image = ""
        self.info = info
    }
 
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.language_code = try container.decodeIfPresent(String.self, forKey: .language_code) ?? ""
        self.info = try container.decodeIfPresent(String.self, forKey: .info) ?? ""
        self.isYes = false
        self.isNo = false
        self.isDontKnow = true
        self.otherDetailInfoList = try container.decodeIfPresent([OtherDetailInfo].self, forKey: .other_detail_infos) ?? []
    }
    
    func encode(to encoder: Encoder) throws {}
}
