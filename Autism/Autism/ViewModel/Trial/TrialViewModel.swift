//
//  TrialViewModel.swift
//  Autism
//
//  Created by Dilip Technology on 22/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

//var trial_skill_domain_id_value = "5f4159f8d7f42669b982e4f9"
//var trial_program_id_value = "60cafd20d57ae04972e0722e"
//var trial_req_no_value = "SD6P4L1"
//var trial_table_name_value = "question_table"


//var trial_skill_domain_id_value = "5f411915d7f42669b982e4c6"
//var trial_program_id_value = "5f411953d7f42669b982e4c7"
//var trial_req_no_value = "SD4P6L1"
//var trial_table_name_value = "body_tracking"

//var trial_skill_domain_id_value = "5f4163366af0b9e258061c65"
//var trial_program_id_value = "5f3ffd5ff0774f38bfb7df2c"
//var trial_req_no_value = "SD9P1L3_3"
//var trial_table_name_value = "verbal_with_multiple"


var trial_skill_domain_id_value = "5f3696756a47807a001de5b1"
var trial_program_id_value = "5f415b66d7f42669b982e4fb"
var trial_req_no_value = "SD3P6L1"
var trial_table_name_value = "maze"

class TrialViewModel {
    var index:Int = 0
    var dataClosure : (() -> Void)?
    var questionResponseVo: TrialQuestionResponseVO? = nil {
           didSet {
               if let closure = self.dataClosure {
                   closure()
               }
           }
    }
    
    func fetchQuestion() {
        
//        {
//        "language": "en",
//        "user_id" : "605259c69bba502a9e6708b6",
//        "skill_domain_id" : "5f3a5ad1bc50f14d79d3c25f",
//        "program_id" : "5feeea5693180b4349b079ca",
//        "req_no" : "SD3P3L1",
//        "table_name" : "matching_object"
//        }
        
        
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getTrailQuestion()

        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
//                ServiceParsingKeys.skill_domain_id.rawValue:"5f411915d7f42669b982e4c6",
//                ServiceParsingKeys.program_id.rawValue:"5f411953d7f42669b982e4c7",
//                ServiceParsingKeys.req_no.rawValue:"SD4P6L1",
//                ServiceParsingKeys.table_name.rawValue:"body_tracking"
                ServiceParsingKeys.skill_domain_id.rawValue:trial_skill_domain_id_value,
                ServiceParsingKeys.program_id.rawValue:trial_program_id_value,
                ServiceParsingKeys.req_no.rawValue:trial_req_no_value,
                ServiceParsingKeys.table_name.rawValue:trial_table_name_value
            ]
        }

        print("service.params = ", service.params)
        ServiceManager.processDataFromServer(service: service, model: TrialQuestionResponseVO.self) { (responseVo, error) in
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
//                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
//                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime()
            ]
        }
        
        ServiceManager.processDataFromServer(service: service, model: TrialQuestionResponseVO.self) { (responseVo, error) in
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
