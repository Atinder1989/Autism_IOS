//
//  SetPrioirtyViewModel.swift
//  Autism
//
//  Created by mac on 23/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class SetPrioirtyViewModel:NSObject {
    var dataClosure : (() -> Void)?
    var labelsClosure : (() -> Void)?

     var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
    
    var labelsResponseVO: ScreenLabelResponseVO? = nil {
        didSet {
            if let closure = self.labelsClosure {
                closure()
            }
        }
    }
    
    func fetchLoginScreenLabels() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.screenLabelUrl()
        if let user = UserManager.shared.getUserInfo() {
        service.params = [
            ServiceParsingKeys.screen_id.rawValue:ScreenLabel.login.rawValue,
            ServiceParsingKeys.language.rawValue:user.languageCode
        ]
        }
        
        ServiceManager.processDataFromServer(service: service, model: ScreenLabelResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
                self.labelsResponseVO = nil
            } else {
                if let response = responseVo {
                    self.labelsResponseVO = response
                }
            }
        }
    }
    
    func submitPriorityAnswer(priority:String,level:String) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.setPriority()
          if let user = UserManager.shared.getUserInfo() {
        service.params = [
        ServiceParsingKeys.priority.rawValue:priority,
        ServiceParsingKeys.level.rawValue:level,
        ServiceParsingKeys.user_id.rawValue:user.id
        ]
     
        }
        print(service.params)
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



