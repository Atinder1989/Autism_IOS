//
//  AvatarSelectionViewModel.swift
//  Autism
//
//  Created by Savleen on 30/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class AvatarSelectionViewModel:NSObject  {
   
    var dataClosure : (() -> Void)?
    var labelsClosure : (() -> Void)?
    var setAvatarClosure : ((AvatarSetResponseVO?) -> Void)?
    var noNetWorkClosure: (() -> Void)?
    
    var avatarListResponseVO: AvatarListResponseVO? = nil {
        didSet {
            if let closure = self.dataClosure {
                closure()
            }
        }
    }
    
    var labelsResponseVO: ScreenLabelResponseVO? = nil
    
    func fetchSelectAvatarScreenLabels() {
        
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
               ServiceParsingKeys.screen_id.rawValue:ScreenLabel.avatar_Selection.rawValue,
               ServiceParsingKeys.language.rawValue:user.languageCode,
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
                self.fetchAvtarList()
           }
    }
    
    func fetchAvtarList() {
        var service = Service.init(httpMethod: .GET)
        service.url = ServiceHelper.avatarListUrl()
          
        ServiceManager.processDataFromServer(service: service, model: AvatarListResponseVO.self) { (responseVo, error) in
            if let _ = error {
                 self.avatarListResponseVO = nil
            } else {
                if let response = responseVo {
                    self.avatarListResponseVO = response
                }
            }
        }
    }
    
    func setAvatarForCurrentUser(model:ImageModel) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.setAvatarUrl()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.avatar_id.rawValue:model.id,
                ServiceParsingKeys.language_code.rawValue:user.languageCode,
            ]
        }
        ServiceManager.processDataFromServer(service: service, model: AvatarSetResponseVO.self) { (responseVo, error) in
            if let _ = error {
                if let closure = self.setAvatarClosure {
                    closure(nil)
                }
            } else {
                if let response = responseVo {
                    UserManager.shared.saveAvatarVariationList(list: response.avtar_variations_List)
                    UserManager.shared.updateScreenId(screenid: response.screen_id)
                    UserManager.shared.updateAvtarGender(gender: model.avtar_gender)
                    if let closure = self.setAvatarClosure {
                        closure(response)
                    }
                }
            }
        }
    }
}


