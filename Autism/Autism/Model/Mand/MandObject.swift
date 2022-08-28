//
//  MandObject.swift
//  Autism
//
//  Created by Dilip Saket on 10/08/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation

struct MandObject: Codable {
    
    var id: String
    var child_action_type: String
    var duration:Int
    var icon_image: String
    var mand_type:String
    var object_image: String
    var parent_cue_text:String
    var request_type:String
    var verbal_response:String
    var screen_type:String
    var url:String

    init(from decoder:Decoder) throws {
        
        let dataContainer = try decoder.container(keyedBy: ServiceParsingKeys.self)
                        
        self.id = try dataContainer.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.child_action_type = try dataContainer.decodeIfPresent(String.self, forKey: .child_action_type) ?? ""
        self.duration = try dataContainer.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        self.icon_image = try dataContainer.decodeIfPresent(String.self, forKey: .icon_image) ?? ""
        self.mand_type = try dataContainer.decodeIfPresent(String.self, forKey: .mand_type) ?? ""
        self.object_image = try dataContainer.decodeIfPresent(String.self, forKey: .object_image) ?? ""
        self.parent_cue_text = try dataContainer.decodeIfPresent(String.self, forKey: .parent_cue_text) ?? ""
        self.request_type = try dataContainer.decodeIfPresent(String.self, forKey: .request_type) ?? ""
        self.screen_type = try dataContainer.decodeIfPresent(String.self, forKey: .screen_type) ?? ""
        self.url = try dataContainer.decodeIfPresent(String.self, forKey: .url) ?? ""
        self.verbal_response = try dataContainer.decodeIfPresent(String.self, forKey: .verbal_response) ?? ""
    }
    

    func encode(to encoder: Encoder) throws {

    }
}
