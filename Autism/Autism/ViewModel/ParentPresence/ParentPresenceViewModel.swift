//
//  ParentPresenceModel.swift
//  Autism
//
//  Created by Dilip Saket on 31/08/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation

class ParentPresenceViewModel {
    
    var noNetWorkClosure: (() -> Void)?    
    
    func submitParentPresenceAnswer(completeRate:String, content_type:String) {
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                noNetwork()
            }
            return
        }
        
        if let user = UserManager.shared.getUserInfo() {
                     
            let parameters: [String : Any] = [
                ServiceParsingKeys.complete_rate.rawValue:completeRate as Any,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
                //NewDevelopment
                ServiceParsingKeys.content_type.rawValue:content_type
                ]
            LearningManager.submitLearningMatchingAnswer(parameters: parameters)
        }
    }
    
}
