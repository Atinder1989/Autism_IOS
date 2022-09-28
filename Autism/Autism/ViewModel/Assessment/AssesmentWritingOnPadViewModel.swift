//
//  AssesmentWritingOnPadViewModel.swift
//  Autism
//
//  Created by Singh, Atinderpal on 28/08/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation
import UIKit

class AssesmentWritingOnPadViewModel:NSObject  {
    
    var dataClosure : (() -> Void)?
    var speechClosure : ((_ status: Bool) -> Void)?

    var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
    
    
    func submitUserAnswer(info:WritingOnPadInfo,timeTaken:Int, skip:Bool,touchOnEmptyScreenCount:Int, request: Bool) {
            
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
                ServiceParsingKeys.level.rawValue:info.level,
                               ServiceParsingKeys.complete_rate.rawValue : skip ? 0 : request ? 100 : 0,
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
    //class func getProfileAPICall(VC: UIViewController, completetionBlock: @escaping (Bool) -> Void) {

    func uploadImage(image: UIImage,timeTaken:Int,info:WritingOnPadInfo,skip:Bool,touchOnEmptyScreenCount:Int, completetionBlock: @escaping (Bool) -> Void) {
        Utility.showLoader()
        Utility.sharedInstance.uploadCapturedImage(correctText: info.image_with_text[0].name, image: image) { error, responseVo in
            Utility.hideLoader()
            if error == nil {
                if let responseVo = responseVo {
                    completetionBlock(responseVo.result)
//                    if let closure = self.speechClosure {
//                        closure(responseVo.result)
//                    }
//                    self.submitUserAnswer(info: info, timeTaken: timeTaken, skip: skip, touchOnEmptyScreenCount: touchOnEmptyScreenCount, request: responseVo.result)
                }
            } else {
                self.accessmentSubmitResponseVO = nil
            }
        }
    }
    
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "imagefile.jpg"
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
}

struct ImageUploadResponseVO: Codable {
    var success: Bool
    var result: Bool

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.result = try container.decodeIfPresent(Bool.self, forKey: .result) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}
