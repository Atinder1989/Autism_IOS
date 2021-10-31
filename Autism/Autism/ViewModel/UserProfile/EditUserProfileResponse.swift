//
//  EditUserProfileResponse.swift
//  Autism
//
//  Created by Savleen on 20/06/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import Foundation

struct EditUserProfileResponse: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    
    var nickname: String
    var dob: String
    var guardian_name: String
    var country: String
    var city: String
    var state: String

    var parent_contact_number: String

    var sensoryIssueList: [EditProfileModel]
    var challengingBehaviourList: [EditProfileModel]
    var reinforcerList: [EditProfileModel]
//    var dietList: [OptionModel]
    var otherDetail: [EditProfileModel]

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.nickname = try dataContainer.decodeIfPresent(String.self, forKey: .nickname) ?? ""
        self.dob = try dataContainer.decodeIfPresent(String.self, forKey: .dob) ?? ""
        self.guardian_name = try dataContainer.decodeIfPresent(String.self, forKey: .guardian_name) ?? ""
        self.country = try dataContainer.decodeIfPresent(String.self, forKey: .country) ?? ""
        self.city = try dataContainer.decodeIfPresent(String.self, forKey: .city) ?? ""
        self.state = try dataContainer.decodeIfPresent(String.self, forKey: .state) ?? ""
        self.parent_contact_number = try dataContainer.decodeIfPresent(String.self, forKey: .parent_contact_number) ?? ""
        
        self.sensoryIssueList = try dataContainer.decodeIfPresent([EditProfileModel].self, forKey: .sensory_issue) ?? []
        self.challengingBehaviourList = try dataContainer.decodeIfPresent([EditProfileModel].self, forKey: .challenging_behaviour) ?? []
        self.reinforcerList = try dataContainer.decodeIfPresent([EditProfileModel].self, forKey: .reinforcer) ?? []
//        self.dietList = try dataContainer.decodeIfPresent([OptionModel].self, forKey: .diet) ?? []
        self.otherDetail = try dataContainer.decodeIfPresent([EditProfileModel].self, forKey: .other_detail) ?? []
}
    
    func encode(to encoder: Encoder) throws {
        
    }
 }


struct EditProfileModel: Codable {
    var option: String
    var value: String
    
   
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.option = try container.decodeIfPresent(String.self, forKey: .option) ?? ""
        self.value = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {}
}
