//
//  SignUpViewModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/13.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class SignUpViewModel:NSObject {
    var dataClosure : (() -> Void)?
    var labelsClosure : (() -> Void)?
    var noNetWorkClosure: (() -> Void)?
    
    var signupResponseVO: CommonMessageResponseVO? = nil {
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
    
    func fetchSignUpScreenLabels() {
        
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                       noNetwork()
            }
            return
        }
           var service = Service.init(httpMethod: .POST)
           service.url = ServiceHelper.screenLabelUrl()
           service.params = [
               ServiceParsingKeys.screen_id.rawValue:ScreenLabel.signup.rawValue,
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
    
    func checkAllValidationAndCreateUser(list :[FormModel]) {
        var isAnythingMissing = false
               for model in list {
                   if model.isMandatory && model.text.count == 0 {
                       isAnythingMissing = true
                    if let lableRes = self.labelsResponseVO {
                        Utility.showAlert(title: lableRes.getLiteralof(code: SignUpLabelCode.information.rawValue).label_text, message: model.popUpMessage)
                    }
                       break
                   }
                   
                if let response = self.labelsResponseVO {
                    if model.title == response.getLiteralof(code: SignUpLabelCode.email.rawValue).label_text {
                        if !model.text.isValidEmail() {
                           isAnythingMissing = true
                        if let lableRes = self.labelsResponseVO {
                            Utility.showAlert(title: lableRes.getLiteralof(code: SignUpLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: SignUpLabelCode.email.rawValue).label_text)
                        }
                        break
                       }
                   }
                }
              }
               
               // Check Password/Confirm Validation
               let passwordModel = list[2]
               let confirmPasswordModel = list[3]
               
               if let lableRes = self.labelsResponseVO {

               if passwordModel.text == confirmPasswordModel.text {
                   let passwordLength = Int(AppConstant.passwordLength.rawValue)
                   if passwordModel.text.count >= passwordLength! {
                    if !passwordModel.text.isValidpassword() {
                        Utility.showAlert(title: lableRes.getLiteralof(code: SignUpLabelCode.information.rawValue).label_text, message: lableRes.getLiteralof(code: SignUpLabelCode.hint_password.rawValue).label_text)
                                                  return
                    }
                } else {
                       Utility.showAlert(title: lableRes.getLiteralof(code: SignUpLabelCode.information.rawValue).label_text, message: lableRes.getLiteralof(code: SignUpLabelCode.hint_password.rawValue).label_text)
                                  return
                }
               } else {
                   isAnythingMissing = true
                   Utility.showAlert(title: lableRes.getLiteralof(code: SignUpLabelCode.information.rawValue).label_text, message: confirmPasswordModel.popUpMessage)
                   return
               }
        
               }
               
               if !isAnythingMissing {
                    self.registerUser(list: list)
               }
    }
    
    
    private func registerUser(list:[FormModel]) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.registerUrl()
        service.params = [ ServiceParsingKeys.name.rawValue:Utility.encrypt(text: list[0].text),
                           ServiceParsingKeys.email.rawValue:list[1].text,
                           ServiceParsingKeys.language.rawValue:selectedLanguageModel.code,
                           ServiceParsingKeys.password.rawValue:Utility.encrypt(text: list[2].text),
        ]
        ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
                self.signupResponseVO = nil
            } else {
                if let response = responseVo {
                    self.signupResponseVO = response
                }
            }
        }
    }
}


