//
//  AssessmentViewModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/04.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class AssessmentViewModel {
    var dataClosure : (() -> Void)?
    var questionResponseVo: AssessmentQuestionResponseVO? = nil {
           didSet {
               if let closure = self.dataClosure {
                   closure()
               }
           }
    }
    
    func fetchQuestion() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getQuestionUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.language.rawValue:user.languageCode,
            ]
        }
        ServiceManager.processDataFromServer(service: service, model: AssessmentQuestionResponseVO.self) { (responseVo, error) in
            if let e = error {
                print("Error = ", e.localizedDescription)
            } else {
                if let res = responseVo {
                    self.questionResponseVo = res
                }
            }
        }
    }
    
    func fetchUserAvatar() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getUserAvatarUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.user_id.rawValue:user.id
            ]
        }
        ServiceManager.processDataFromServer(service: service, model: UserAvatarResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let res = responseVo {
                    if let av = res.avatar {
                        UserManager.shared.updateAvatar(model: av)
                    }
                    self.fetchQuestion()
                }
            }
        }
    }
    
    func skipQuestion(info:BodyTrackingQuestionInfo,completeRate:Int,timetaken:Int,skip:Bool) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()
       if let user = UserManager.shared.getUserInfo() {
            service.params = [
               ServiceParsingKeys.user_id.rawValue :user.id,
               ServiceParsingKeys.question_type.rawValue :info.question_type,
               ServiceParsingKeys.time_taken.rawValue :timetaken,
               ServiceParsingKeys.complete_rate.rawValue :completeRate,
               ServiceParsingKeys.success_count.rawValue : completeRate,
               ServiceParsingKeys.question_id.rawValue :info.id,
               ServiceParsingKeys.language.rawValue:user.languageCode,
               ServiceParsingKeys.req_no.rawValue:info.req_no,
               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
               ServiceParsingKeys.level.rawValue:info.level,
               ServiceParsingKeys.skip.rawValue:skip,
                ServiceParsingKeys.log_type.rawValue:CourseModule.assessment.rawValue,

            ]
        }
        
        ServiceManager.processDataFromServer(service: service, model: AssessmentQuestionResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let response = responseVo {
                    self.questionResponseVo = response
                }
            }
        }
    }
    
    
}

