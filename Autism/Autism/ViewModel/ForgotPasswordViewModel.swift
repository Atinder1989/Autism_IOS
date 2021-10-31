//
//  ForgotPasswordViewModel.swift
//  Autism
//
//  Created by Savleen on 15/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class ForgotPasswordViewModel:NSObject {
var dataClosure : (() -> Void)?
var labelsClosure : (() -> Void)?
var noNetWorkClosure: (() -> Void)?
    
var forgotResponseVO: CommonMessageResponseVO? = nil {
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

func fetchforgotScreenLabels() {
    
    if !Utility.isNetworkAvailable() {
        if let noNetwork = self.noNetWorkClosure {
                   noNetwork()
        }
        return
    }
    
       var service = Service.init(httpMethod: .POST)
       service.url = ServiceHelper.screenLabelUrl()
       service.params = [
           ServiceParsingKeys.screen_id.rawValue:ScreenLabel.forgot_pass.rawValue,
           ServiceParsingKeys.language.rawValue:selectedLanguageModel.code,
       ]
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
     func sendLinkToUser(list:[FormModel]) {
           var service = Service.init(httpMethod: .POST)
           service.url = ServiceHelper.forgotPasswordUrl()
           service.params = [
            ServiceParsingKeys.email.rawValue:list[0].text,
            ServiceParsingKeys.language_code.rawValue:selectedLanguageModel.code,
           ]
           ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
               if let e = error {
                   print(e.localizedDescription)
               } else {
                   if let response = responseVo {
                        self.forgotResponseVO = response
                   }
               }
           }
       }

}
