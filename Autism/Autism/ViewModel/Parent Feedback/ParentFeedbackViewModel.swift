//
//  ParentFeedbackViewModel.swift
//  Autism
//
//  Created by Savleen on 14/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class ParentFeedbackViewModel {
    private var isApiResponse = false
    var dataClosure : (() -> Void)?
    var noNetWorkClosure: (() -> Void)?
    
    var submitParentFeedbackClosure : ((CommonMessageResponseVO) -> Void)?
    var labelsResponseVO: ScreenLabelResponseVO?
    var feedbackResponseVo: ParentFeedbackListResponseVO? = nil {
       didSet {
           if let closure = self.dataClosure {
                if isApiResponse {
                    self.isApiResponse = false
                    closure()
                }
           }
       }
    }
    
    func fetchParentFeedbackScreenLabels() {
        
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                       noNetwork()
            }
            return
        }
           var service = Service.init(httpMethod: .POST)
           service.url = ServiceHelper.screenLabelUrl()
        if let user = UserManager.shared.getUserInfo() {
           service.params = [
               ServiceParsingKeys.screen_id.rawValue:ScreenLabel.parentFeedback.rawValue,
           ServiceParsingKeys.language.rawValue:user.languageCode
             ]
        }
           
           ServiceManager.processDataFromServer(service: service, model: ScreenLabelResponseVO.self) { (responseVo, error) in
               if let _ = error {
                   self.labelsResponseVO = nil
               } else {
                   if let response = responseVo {
                       self.labelsResponseVO = response
                   }
               }
              self.getParentFeedbackList()
           }
       }
    

    func getParentFeedbackList() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.parentFeedbackUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
              ServiceParsingKeys.language_code.rawValue:user.languageCode

            ]
        }
        ServiceManager.processDataFromServer(service: service, model: ParentFeedbackListResponseVO.self) { (responseVo, error) in
            if let e = error {
                print("Error = ", e.localizedDescription)
            } else {
                if let res = responseVo {
                    self.isApiResponse = true
                    self.feedbackResponseVo = res
                }
            }
        }
    }
    
    func updateFeedbackList(feedbackModel: ParentFeedbackModel) {
         var index = -1
         if let responseVo = self.feedbackResponseVo {
            for (i, m) in responseVo.feedbackList.enumerated() {
                if m.skill_domain_id == feedbackModel.skill_domain_id {
                    index = i
                    break
                }
            }
         }
        if let responseVo = self.feedbackResponseVo {
            var res = responseVo
            res.feedbackList.remove(at: index)
            res.feedbackList.insert(feedbackModel, at: index)
            self.feedbackResponseVo = res
        }
    }
    
    func submitParentFeedbackList() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.submitParentFeedbackUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.language_code.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.user_parent_feedback.rawValue:self.getUserParentFeedbackDictionary()
            ]
        }
        ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
            if let e = error {
                print("Error = ", e.localizedDescription)
            } else {
                if let res = responseVo {
                    UserManager.shared.updateScreenId(screenid: res.screenid)
                    if let closure = self.submitParentFeedbackClosure {
                        closure(res)
                    }
                }
            }
        }
    }
    
    private func getUserParentFeedbackDictionary() ->[String: Any] {
        var dict:[String: Any] = [String: Any]()
        var totalCount = 0

        if let response = self.feedbackResponseVo {
            for model in response.feedbackList {
                var programTypeDict:[String: Any] = [String: Any]()
                totalCount = 0
                for programTypeModel in model.programTypeList {
                    let programTypeId = programTypeModel.id
                    if programTypeModel.isNo {
                        programTypeDict[programTypeId] = 0
                    } else if programTypeModel.isYes {
                        programTypeDict[programTypeId] = 1
                        totalCount += 1
                    } else if programTypeModel.isDontKnow {
                        programTypeDict[programTypeId] = 2
                    } else {
                        programTypeDict[programTypeId] = 2
                    }
                }
                programTypeDict[ServiceParsingKeys.total_count.rawValue] = totalCount
                dict[model.skill_domain_id] = programTypeDict
            }
        }
        return dict
    }
}
