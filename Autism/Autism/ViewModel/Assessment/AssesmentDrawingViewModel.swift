//
//  AssesmentDrawingViewModel.swift
//  Autism
//
//  Created by Savleen on 07/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import UIKit

class AssesmentDrawingViewModel:NSObject  {
    
    var dataClosure : (() -> Void)?
    
    var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
    

    
    func submitUserAnswer(info:DrawingQuestionInfo,timeTaken:Int,imageurl:String,skip:Bool,touchOnEmptyScreenCount:Int) {
        
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.assessmentQuestionSubmitUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [ ServiceParsingKeys.user_id.rawValue:user.id,
                               ServiceParsingKeys.question_type.rawValue : info.question_type,
                ServiceParsingKeys.time_taken.rawValue : timeTaken,
                ServiceParsingKeys.question_id.rawValue : info.id,
                ServiceParsingKeys.language.rawValue:user.languageCode,
                ServiceParsingKeys.req_no.rawValue:info.req_no,
                ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                ServiceParsingKeys.image_url.rawValue:imageurl,
                ServiceParsingKeys.level.rawValue:info.level,
                ServiceParsingKeys.complete_rate.rawValue : skip ? 0 : 100,
                ServiceParsingKeys.skip.rawValue : skip,
                ServiceParsingKeys.program_id.rawValue:info.program_id,

                ServiceParsingKeys.faceDetectionDataList.rawValue:FaceDetection.shared.getFaceDetectionDataList(),

                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
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
    
    func uploadImage(image: UIImage,timeTaken:Int,info:DrawingQuestionInfo,skip:Bool,touchOnEmptyScreenCount:Int) {
        Utility.showLoader()
        Utility.sharedInstance.uploadImage(image: image) { (url, error) in
            Utility.hideLoader()
            if error == nil {
                self.submitUserAnswer(info: info, timeTaken: timeTaken, imageurl: url, skip: skip, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            } else {
                self.accessmentSubmitResponseVO = nil
            }
        }
    }
    
}

