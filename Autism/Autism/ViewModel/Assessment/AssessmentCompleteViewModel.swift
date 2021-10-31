//
//  AssessmentCompleteViewModel.swift
//  Autism
//
//  Created by Savleen on 31/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class AssessmentCompleteViewModel:NSObject {
    var labelsClosure : (() -> Void)?

     var labelsResponseVO: ScreenLabelResponseVO? = nil {
          didSet {
              if let closure = self.labelsClosure {
                  closure()
              }
          }
      }
   
    func fetchAssessmentCompleteScreenLabels() {
          var service = Service.init(httpMethod: .POST)
          service.url = ServiceHelper.screenLabelUrl()
        if let user = UserManager.shared.getUserInfo() {
          service.params = [
              ServiceParsingKeys.screen_id.rawValue:ScreenLabel.assessment_Complete.rawValue,
              ServiceParsingKeys.language.rawValue:user.languageCode,
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
