//
//  ServiceManager.swift
//  Assignment
//
//  Created by Atinderpal Singh on 05/02/19.
//  Copyright © 2019 Abc. All rights reserved.
//

import UIKit

class ServiceManager: NSObject {
    
    class func processDataFromServer<T:Codable>(service: Service,model:T.Type,isloader:Bool = true,responseProcessingBlock: @escaping (T?,Error?) -> () )
    {
 
        print("service = \(service)")
        if Utility.isNetworkAvailable() {
//            if isloader {
//                Utility.showLoader()
//            }
            let request = RequestManager.sharedInstance.createRequest(service: service)
            SessionManager.sharedInstance.processRequest(request: request) { (data, error) in                
                ServiceManager.processDataModalFromResponseData(service: service, model:T.self,data: data,error: error,responseProcessingBlock: responseProcessingBlock)
            
             }
        } else {
            Utility.sharedInstance.showToast(message:"Network UnAvailable")
            let error: NSError = NSError.init(domain: "", code: 0,
                                                         userInfo: [NSLocalizedDescriptionKey: ""])
            responseProcessingBlock(nil, error)
        }
    }
    
    private class func processDataModalFromResponseData<T:Codable>(service:Service,model:T.Type, data:Data?,error:Error?,responseProcessingBlock: @escaping (T?,Error?) -> ())
    {
       // Utility.hideLoader()
        
        if !service.url.contains("insertLog") {
            self.insertLog(oldService: service, data: data, error: error)
        }
        
        if let responseError = error
        {
            
            print(responseError.localizedDescription)
            
            if service.url.contains("submitQuestion") || service.url.contains("getQuestion") || service.url.contains("trial_answer")
            {
                self.retrySubmitQuestion(oldService: service, model: model.self, responseProcessingBlock: responseProcessingBlock)
                return
            } else if service.url.contains("insertLog") {
                return
            }
            responseProcessingBlock(nil,responseError)
            return
        }
        
        if let responseData = data
        {
            do{
               // print(responseData)
                let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String:Any]
                print(json)
                let jsonDecoder = JSONDecoder.init()
                let parsingModel = try jsonDecoder.decode(model.self, from: responseData)
                Utility.hideRetryView()
                responseProcessingBlock(parsingModel, nil)
            }
            catch(let parsingError)
            {
                responseProcessingBlock(nil,parsingError)
            }
        } else {
            
        }
    }
    
    private class func insertLog(oldService:Service,data:Data?,error:Error?) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getInsertLogUrl()
        var errorString = ""
        var errorcode = 0
        if let responseError = error
        {
            errorString = responseError.localizedDescription
            errorcode = (responseError as NSError).code
        }
        
        var json:[String:Any]?
        if let responseData = data
        {
            do {
                 json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String:Any]
            }
            catch(_)
            {
            }
        } else {
            
        }
        
        var userid = ""
        if let user = UserManager.shared.getUserInfo() {
            userid = user.id
        }
        
        var requestParams = oldService.params
        requestParams[ServiceParsingKeys.url.rawValue] = oldService.url
        service.params = [
         ServiceParsingKeys.user_id.rawValue:userid,
         ServiceParsingKeys.request.rawValue:requestParams,
         ServiceParsingKeys.response.rawValue:json as Any,
         ServiceParsingKeys.error.rawValue:errorString,
         ServiceParsingKeys.errorCode.rawValue:errorcode,
         ServiceParsingKeys.header.rawValue:oldService.headers
        ]
        
        ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self, isloader: false) { (responseVo, error) in
             if let e = error {
                                  print(e.localizedDescription)
                              } else {
                                  if let _ = responseVo {
                                  }
                              }
        }
    }
    
    
    private class func retrySubmitQuestion<T:Codable>(oldService:Service,model:T.Type,responseProcessingBlock: @escaping (T?,Error?) -> ()) {
        
        ServiceManager.processDataFromServer(service: oldService, model: T.self, isloader: false) { (responseVo, error) in
             if let e = error {
                                  print(e.localizedDescription)
                              } else {
                                  if let res = responseVo {
                                    responseProcessingBlock(res, nil)
                                  }
                              }
        }
    }
}
