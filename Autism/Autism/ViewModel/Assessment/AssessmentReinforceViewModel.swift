//
//  AssessmentReinforceViewModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/09.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


class AssessmentReinforceViewModel {
 var submitClosure : (() -> Void)?

 var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.submitClosure {
                closure()
            }
        }
 }
    
    func submitReinforcerQuestionDetails(completeRate:Int, selection:String,preferredSelection:String,touchResponse:String,responseTime:Int,info:ReinforcerInfo,type:AssessmentQuestionType,skip:Bool,touchOnEmptyScreenCount:Int) {
       
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.question_type.rawValue:type.rawValue,
                ServiceParsingKeys.selection.rawValue:selection,
                ServiceParsingKeys.preferredSelection.rawValue:preferredSelection,
                ServiceParsingKeys.touchResponse.rawValue:touchResponse,
                ServiceParsingKeys.responseTime.rawValue:responseTime,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.req_no.rawValue:info.req_no,
                ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                ServiceParsingKeys.level.rawValue:info.level,
                ServiceParsingKeys.question_id.rawValue:info.id,
                ServiceParsingKeys.complete_rate.rawValue:completeRate,
                ServiceParsingKeys.skip.rawValue:skip,
                ServiceParsingKeys.program_id.rawValue:info.program_id,
                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                ServiceParsingKeys.faceDetectionDataList.rawValue:FaceDetection.shared.getFaceDetectionDataList(),
                ServiceParsingKeys.screenLoadTime.rawValue:Utility.convertDateToString(date: screenLoadTime ?? Date(), format: dateFormat),
                ServiceParsingKeys.screenSubmitTime.rawValue:Utility.convertDateToString(date:Date(), format: dateFormat),
                ServiceParsingKeys.idleTime.rawValue:FaceDetection.shared.getIdleTimeinSeconds(),
                ServiceParsingKeys.log_type.rawValue:CourseModule.assessment.rawValue,
            ]
        }
        ServiceManager.processDataFromServer(service: service, model: AssessmentQuestionResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let response = responseVo {
                    print(response)
                    self.accessmentSubmitResponseVO = response
                }
            }
        }
        
    }
    
    
    
}
