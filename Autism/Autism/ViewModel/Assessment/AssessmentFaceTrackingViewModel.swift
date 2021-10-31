//
//  AssessmentFaceTrackingViewModel.swift
//  Autism
//
//  Created by Savleen on 10/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class AssessmentFaceTrackingViewModel:NSObject {
 var dataClosure : (() -> Void)?

    var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
    
    func submitFaceTrackDetails(info:FaceTrackingQuestionInfo,timetaken:Int,touchOnEmptyScreenCount:Int) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()
        
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
               ServiceParsingKeys.user_id.rawValue :user.id,
               ServiceParsingKeys.question_type.rawValue :info.question_type,
               ServiceParsingKeys.time_taken.rawValue :timetaken,
               //ServiceParsingKeys.complete_rate.rawValue : value,
              // ServiceParsingKeys.success_count.rawValue :value,
               ServiceParsingKeys.question_id.rawValue :info.id,
               ServiceParsingKeys.language.rawValue:user.languageCode,
               ServiceParsingKeys.req_no.rawValue:info.req_no,
               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
               ServiceParsingKeys.level.rawValue:info.level,
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
                    self.accessmentSubmitResponseVO = response
                }
            }
        }
    }
}


