//
//  AssessmentStartViewModel.swift
//  Autism
//
//  Created by Savleen on 31/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class AssessmentStartViewModel:NSObject {
    var labelsClosure : (() -> Void)?

     var labelsResponseVO: ScreenLabelResponseVO? = nil {
          didSet {
              if let closure = self.labelsClosure {
                  closure()
              }
          }
      }
   
    func fetchStartAssessmentScreenLabels() {
          var service = Service.init(httpMethod: .POST)
          service.url = ServiceHelper.screenLabelUrl()
        if let user = UserManager.shared.getUserInfo() {
          service.params = [
              ServiceParsingKeys.screen_id.rawValue:ScreenLabel.assessment_Start.rawValue,
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
    
}
