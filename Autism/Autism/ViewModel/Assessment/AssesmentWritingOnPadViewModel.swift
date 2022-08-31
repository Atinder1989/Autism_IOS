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
    
    func uploadImage(image: UIImage,timeTaken:Int,info:WritingOnPadInfo,skip:Bool,touchOnEmptyScreenCount:Int) {
        Utility.showLoader()
        
        self.uploadCapturedImage(correctText: info.image_with_text[0].name, image: image) { error, responseVo in
            Utility.hideLoader()
            if error == nil {
                if let responseVo = responseVo {
                    self.submitUserAnswer(info: info, timeTaken: timeTaken, skip: skip, touchOnEmptyScreenCount: touchOnEmptyScreenCount, request: responseVo.result)
                }
            } else {
                self.accessmentSubmitResponseVO = nil
            }
        }
    }
    
    func uploadCapturedImage(correctText: String, image: UIImage, completion: @escaping (Error?, ImageUploadResponseVO?) -> Void) {

        var parameter: [String: Any] = [:]
        parameter["correct_text"] = correctText
       
         guard let mediaImage = Media(withImage: image, forKey: "image") else { return }
        
          //create boundary
          let boundary = generateBoundary()
        
          //create dataBody
          let dataBody = createDataBody(withParameters: parameter, media: [mediaImage], boundary: boundary)

          guard let url = URL(string: "https://impute.co.jp:4000/v1/image/submit") else { return }
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let username = "oeEU1BG0ES"
        let password = "rNGkOF+p/D}V@rK"
        let joined = username + ":" + password
        let data = Data(joined.utf8)
        let encoded = data.base64EncodedString()
        request.setValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
        
          //call createDataBody method
          request.httpBody = dataBody
        
          let session = URLSession.shared
          session.dataTask(with: request) { (data, response, error) in
             if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    print(json)
                    let jsonDecoder = JSONDecoder.init()
                    let imageCheckResponse = try jsonDecoder.decode(ImageUploadResponseVO.self, from: data)
                    completion(nil, imageCheckResponse)
                } catch {
                    completion(error, nil)
                }
             }
          }.resume()
    }
    
}

// MARK: - Private Methods
extension AssesmentWritingOnPadViewModel {
    private func createDataBody(withParameters params: [String: Any]?, media: [Media]?, boundary: String) -> Data {
       let lineBreak = "\r\n"
       var body = Data()
       if let parameters = params {
          for (key, value) in parameters {
             body.append("--\(boundary + lineBreak)")
             body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
             body.append("\((value as? String ?? "") + lineBreak)")
          }
       }
       if let media = media {
          for photo in media {
             body.append("--\(boundary + lineBreak)")
             body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
             body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
             body.append(photo.data)
             body.append(lineBreak)
          }
       }
        body.append("--\(boundary)--\(lineBreak)")
       return body
    }
    
    private func generateBoundary() -> String {
       return "Boundary-\(NSUUID().uuidString)"
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
