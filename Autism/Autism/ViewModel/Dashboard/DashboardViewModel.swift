//
//  DashboardViewModel.swift
//  Autism
//
//  Created by Savleen on 29/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class DashboardViewModel:NSObject  {
    var dataClosure : (() -> Void)?
    var resetAssessmentClosure : ((_ response:CommonMessageResponseVO) -> Void)?
    var resetLearningClosure : ((_ response:CommonMessageResponseVO) -> Void)?

    var learningAlgoClosure : ((_ algoResponse:AlgorithmResponseVO) -> Void)?
    var deleteAccountClosure : ((_ messageResponse:CommonMessageResponseVO) -> Void)?
    var noNetWorkClosure: (() -> Void)?
    var labelsResponseVO: ScreenLabelResponseVO?
    var dashboardPerformanceResponseVO: DashboardPerformanceResponseVO?
   
    func fetchDashboardScreenLabels() {
        
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
              ServiceParsingKeys.screen_id.rawValue:ScreenLabel.dashboard.rawValue,
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
            self.fetchUserData()
          }
      }
    
    func fetchUserData() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getDashboardUrl()

        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.language_code.rawValue:user.languageCode
            ]
        }
        ServiceManager.processDataFromServer(service: service, model: DashboardPerformanceResponseVO.self) { (responseVo, error) in
            if let e = error {
                print("Error = ", e.localizedDescription)
            } else {
                if let res = responseVo {
                    self.dashboardPerformanceResponseVO = res
                    if let closure = self.dataClosure {
                        closure()
                    }
                }
            }
        }
    }
    
    func resetAssessment() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getResetLearning()
        if let user = UserManager.shared.getUserInfo() {
           service.params = [
            ServiceParsingKeys.user_id.rawValue:user.id,
           ]
        }
        ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
            if let _ = error {
            } else {
                if let res = responseVo {
                    if let closure = self.resetAssessmentClosure {
                           closure(res)
                       }
                }
            }
        }
    }

    
    func resetLearning() {
           var service = Service.init(httpMethod: .POST)
           service.url = ServiceHelper.getResetAssessmentUrl()
           if let user = UserManager.shared.getUserInfo() {
               service.params = [
                   ServiceParsingKeys.user_id.rawValue:user.id,
               ]
           }
           ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
               if let e = error {
                   print("Error = ", e.localizedDescription)
               } else {
                   if let res = responseVo {
                    if let closure = self.resetLearningClosure {
                           closure(res)
                       }
                   }
               }
           }
       }
    
    func getLearningAlgoScript() {
           var service = Service.init(httpMethod: .POST)
           service.url = ServiceHelper.getLearningAlgoUrl()
           if let user = UserManager.shared.getUserInfo() {
               service.params = [
                   ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.language.rawValue:user.languageCode

               ]
           }
           ServiceManager.processDataFromServer(service: service, model: AlgorithmResponseVO.self) { (responseVo, error) in
               if let e = error {
                   print("Error = ", e.localizedDescription)
                    
               } else {
                   if let res = responseVo {
                    if let closure = self.learningAlgoClosure {
                           closure(res)
                    }
                   }
               }
           }
       }
    
    func deleteUserAccount() {
           var service = Service.init(httpMethod: .POST)
           service.url = ServiceHelper.getUserDeleteAccountUrl()
           if let user = UserManager.shared.getUserInfo() {
               service.params = [
                   ServiceParsingKeys.user_id.rawValue:user.id,
               ]
           }
           ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
               if let e = error {
                   print("Error = ", e.localizedDescription)
               } else {
                   if let res = responseVo {
                    if let closure = self.deleteAccountClosure {
                        closure(res)
                    }
                   }
               }
           }
       }
    
}


