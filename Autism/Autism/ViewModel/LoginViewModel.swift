//
//  LoginViewModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/14.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class LoginViewModel:NSObject {
    var dataClosure : (() -> Void)?
    var labelsClosure : (() -> Void)?
    var noNetWorkClosure: (() -> Void)?
    
    var loginResponseVO: LoginResponseVO? = nil {
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
        
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                       noNetwork()
            }
            return
        }
        
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.screenLabelUrl()
        service.params = [
            ServiceParsingKeys.screen_id.rawValue:ScreenLabel.login.rawValue,
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
    
    func checkAllValidationBeforeLogin(list :[FormModel]) {
        var isAnythingMissing = false
           for model in list {
               if model.isMandatory && model.text.count == 0 {
                   isAnythingMissing = true
                   Utility.showAlert(title: "Information", message: model.popUpMessage)
                   break
               }
               
                if let response = self.labelsResponseVO {
                    if model.title == response.getLiteralof(code: LoginLabelCode.email.rawValue).label_text {
                        if !model.text.isValidEmail() {
                            isAnythingMissing = true
                            Utility.showAlert(title: "Information", message: response.getLiteralof(code: LoginLabelCode.email.rawValue).label_text)
                            break
                        }
                    }
                }
            }
        
         if !isAnythingMissing {
            self.fetchLoginDetails(list: list)
         }
    }
    
    func fetchLoginDetails(list:[FormModel]) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.loginUrl()
        service.params = [
                           ServiceParsingKeys.email.rawValue:list[0].text,
                           ServiceParsingKeys.password.rawValue:Utility.encrypt(text: list[1].text),
                           ServiceParsingKeys.language_code.rawValue:selectedLanguageModel.code,
                           ServiceParsingKeys.eye_tracking_supported_device.rawValue:Utility.sharedInstance.isARFaceTrackingConfigurationOnCurrentDevice()
            
        ]
        ServiceManager.processDataFromServer(service: service, model: LoginResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
                self.loginResponseVO = nil
            } else {
                if let response = responseVo {
                    if let user = response.userVO {
                        UserManager.shared.saveUserInfo(userVO: user)
                    }
                    UserManager.shared.saveAvatarVariationList(list: response.avtar_variations_List)
                    self.loginResponseVO = response
                }
            }
        }
    }
    
}


