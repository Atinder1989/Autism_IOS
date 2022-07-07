//
//  MandViewModel.swift
//  Autism
//
//  Created by Dilip Saket on 03/07/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation

class MandViewModel {
    
    var noNetWorkClosure: (() -> Void)?

    func submitLearningMandAnswer(response:AlgorithmResponseVO) {

        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                noNetwork()
            }
            return
        }
        
        if let user = UserManager.shared.getUserInfo() {
            let parameters: [String : Any] = [
                
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.complete_rate.rawValue :100,
//                ServiceParsingKeys.new_correct_question_till_mand.rawValue:user.id,
                
                //NewDevelopment
                ServiceParsingKeys.content_type.rawValue:response.data?.mandInfo?.content_type ?? "",
                ServiceParsingKeys.course_type.rawValue:response.data?.mandInfo?.course_type ?? "",
//                ServiceParsingKeys.level.rawValue:self.program.level,
//                ServiceParsingKeys.bucket.rawValue:self.program.bucket,
                ServiceParsingKeys.table_name.rawValue:response.data?.mandInfo?.table_name ?? ""

                ]
            LearningManager.submitLearningMatchingAnswer(parameters: parameters)
        }

//        let parameter:[String: Any] = ["ss":"ddd"]
//        LearningManager.submitLearningMatchingAnswer(parameters: parameter)
    }
}
