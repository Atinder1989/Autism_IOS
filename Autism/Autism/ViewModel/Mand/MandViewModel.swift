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

    var dataClosure : (() -> Void)?
    
    var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }

    func submitMandQuestionDetails(info: MandInfo, mand:MandObject, timeTaken:Int, successCount:Int) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()

        if let user = UserManager.shared.getUserInfo() {
            service.params = [ ServiceParsingKeys.user_id.rawValue:user.id,
                               ServiceParsingKeys.question_id.rawValue : mand.id,
                               ServiceParsingKeys.question_type.rawValue : info.question_type,
                               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                               ServiceParsingKeys.program_id.rawValue:info.program_id,
                               ServiceParsingKeys.level.rawValue:info.level,
                               ServiceParsingKeys.complete_rate.rawValue : successCount,
                               ServiceParsingKeys.success_count.rawValue : successCount,
                               ServiceParsingKeys.language.rawValue:user.languageCode,
                               ServiceParsingKeys.course_type.rawValue : info.course_type,
                               ServiceParsingKeys.req_no.rawValue:"NA",
                               ServiceParsingKeys.time_taken.rawValue : timeTaken,
                               ServiceParsingKeys.image_url.rawValue : "na",
                               ServiceParsingKeys.skip.rawValue:0
            ]
        }
        
        ServiceManager.processDataFromServer(service: service, model: AssessmentQuestionResponseVO.self) { (responseVo, error) in
            if let _ = error {
                 self.accessmentSubmitResponseVO = nil
            } else {
                if let response = responseVo {
                    
                    self.accessmentSubmitResponseVO = response
                }
            }
        }
    }
    
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
                
                //NewDevelopment
                ServiceParsingKeys.content_type.rawValue:response.data?.mandInfo?.content_type ?? "",
                ServiceParsingKeys.course_type.rawValue:response.data?.mandInfo?.course_type ?? "",
                ServiceParsingKeys.table_name.rawValue:response.data?.mandInfo?.table_name ?? ""

                ]
            LearningManager.submitLearningMatchingAnswer(parameters: parameters)
        }

//        let parameter:[String: Any] = ["ss":"ddd"]
//        LearningManager.submitLearningMatchingAnswer(parameters: parameter)
    }
    
}
