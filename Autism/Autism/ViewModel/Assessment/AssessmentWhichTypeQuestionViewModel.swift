//
//  AssessmentWhichTypeQuestionViewModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/11.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class AssessmentWhichTypeQuestionViewModel:NSObject  {
    
    var dataClosure : (() -> Void)?
    
    var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
       
    func submitVerbalQuestionDetails(info:WhichTypeQuestionInfo,completeRate:Int,timetaken:Int,skip:Bool,touchOnEmptyScreenCount:Int,selectedIndex:Int) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.time_taken.rawValue:timetaken,
                ServiceParsingKeys.complete_rate.rawValue:completeRate,
                ServiceParsingKeys.success_count.rawValue : completeRate,
                ServiceParsingKeys.question_id.rawValue:info.id,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.req_no.rawValue:info.req_no,
                ServiceParsingKeys.question_type.rawValue:info.question_type,
                ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                ServiceParsingKeys.level.rawValue:info.level,
                ServiceParsingKeys.skip.rawValue:skip,
                ServiceParsingKeys.program_id.rawValue:info.program_id,
                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                ServiceParsingKeys.selectedIndex.rawValue:selectedIndex+1,
                ServiceParsingKeys.faceDetectionDataList.rawValue:FaceDetection.shared.getFaceDetectionDataList(),
                ServiceParsingKeys.screenLoadTime.rawValue:Utility.convertDateToString(date: screenLoadTime ?? Date(), format: dateFormat),
                ServiceParsingKeys.screenSubmitTime.rawValue:Utility.convertDateToString(date:Date(), format: dateFormat),
                ServiceParsingKeys.idleTime.rawValue:FaceDetection.shared.getIdleTimeinSeconds(),
                ServiceParsingKeys.log_type.rawValue:CourseModule.assessment.rawValue,
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


class AssessmentMultiArrayQuestionViewModel:NSObject  {
    
    var dataClosure : (() -> Void)?
    
    var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
       
    func submitVerbalQuestionDetails(info:MultiArrayQuestionInfo, completeRate:Int, timetaken:Int, skip:Bool, touchOnEmptyScreenCount:Int/*, selectedIndex:Int*/) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.time_taken.rawValue:timetaken,
                ServiceParsingKeys.complete_rate.rawValue:completeRate,
                ServiceParsingKeys.success_count.rawValue : completeRate,
                ServiceParsingKeys.question_id.rawValue:info.id,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.req_no.rawValue:info.req_no,
                ServiceParsingKeys.question_type.rawValue:info.question_type,
                ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                ServiceParsingKeys.level.rawValue:info.level,
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
