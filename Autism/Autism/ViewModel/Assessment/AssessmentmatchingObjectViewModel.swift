//
//  AssessmentmatchingObjectViewModel.swift
//  Autism
//
//  Created by Dilip Technology on 16/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentMatchingObjectViewModel: NSObject {
    
    var dataClosure : (() -> Void)?
    
    var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
    
    func submitUserAnswer(successCount:Int,info:MatchingObjectInfo,timeTaken:Int,skip:Bool,touchOnEmptyScreenCount:Int,selectedIndex:Int) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()
        var programID:String?
        
        if let user = UserManager.shared.getUserInfo() {
            service.params = [ ServiceParsingKeys.user_id.rawValue:user.id,
                               ServiceParsingKeys.question_type.rawValue : info.question_type,
                               ServiceParsingKeys.time_taken.rawValue : timeTaken,
                          ServiceParsingKeys.complete_rate.rawValue : successCount,
                        ServiceParsingKeys.success_count.rawValue : successCount,
                ServiceParsingKeys.question_id.rawValue : info.id,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.req_no.rawValue:info.req_no,
                                ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                                ServiceParsingKeys.level.rawValue:info.level,
                                ServiceParsingKeys.skip.rawValue:skip,
                                ServiceParsingKeys.program_id.rawValue:programID,//info.program_id,
                                
                                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                                ServiceParsingKeys.selectedIndex.rawValue:selectedIndex+1,
                                ServiceParsingKeys.faceDetectionDataList.rawValue:FaceDetection.shared.getFaceDetectionDataList(),
                                ServiceParsingKeys.screenLoadTime.rawValue:Utility.convertDateToString(date: screenLoadTime ?? Date(), format: dateFormat),
                                ServiceParsingKeys.screenSubmitTime.rawValue:Utility.convertDateToString(date:Date(), format: dateFormat),
                                ServiceParsingKeys.idleTime.rawValue:FaceDetection.shared.getIdleTimeinSeconds(),
                                ServiceParsingKeys.course_type.rawValue:CourseModule.assessment.rawValue,

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
    
}
