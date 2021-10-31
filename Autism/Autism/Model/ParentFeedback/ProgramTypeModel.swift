//
//  ProgramTypeModel.swift
//  Autism
//
//  Created by Savleen on 19/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct ProgramTypeModel: Codable {
    var id: String
    var description: String
    var name: String
    var question: String
    var info: String
    var isYes: Bool
    var isNo: Bool
    var isDontKnow: Bool
    var isrowDisable:Bool
    
    init(id:String,description:String,name:String,question:String,info:String,yes:Bool,no:Bool,dontKnow:Bool,isrowDisable:Bool) {
        self.id = id
        self.description = description
        self.name = name
        self.question = question
        self.info = info
        self.isYes = yes
        self.isNo = no
        self.isDontKnow = dontKnow
        self.isrowDisable = isrowDisable

    }
    
   init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.id          = try container.decodeIfPresent(String.self, forKey: .normalId) ?? ""
        self.description          = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.name          = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.question          = try container.decodeIfPresent(String.self, forKey: .question) ?? ""
        self.info          = try container.decodeIfPresent(String.self, forKey: .info) ?? ""
        self.isYes = false
        self.isNo = false
        self.isDontKnow = false
        self.isrowDisable = true
    }

    func encode(to encoder: Encoder) throws {
    }
}


