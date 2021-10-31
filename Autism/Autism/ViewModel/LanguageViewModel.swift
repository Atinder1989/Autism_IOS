//
//  LanguageViewModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/12.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class LanguageViewModel:NSObject {
    var reloadDataClosure : (() -> Void)?
    var noNetWorkClosure: (() -> Void)?

    var languageResponseVO: LanguageResponseVO? = nil {
        didSet {
            if let reload = self.reloadDataClosure {
                reload()
            }
        }
    }
    
    func getLanguageList() {
        
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                       noNetwork()
            }
            return
        }
        
        
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.languageListUrl()
        ServiceManager.processDataFromServer(service: service, model: LanguageResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
                self.languageResponseVO = nil
            } else {
                if let response = responseVo {
                    self.languageResponseVO = response
                }
            }
        }
    }
    
   
    
}


