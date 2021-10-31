//
//  RequestManager.swift
//  Assignment
//
//  Created by Atinderpal Singh on 05/02/19.
//  Copyright © 2019 Abc. All rights reserved.
//

import UIKit

let WEBSERVICE_TIMEOUT_INTERVAL = 30

class RequestManager: NSObject {
    
    static let sharedInstance = RequestManager()
    
    func createRequest(service: Service) -> URLRequest {
        var request: URLRequest!
        switch service.httpMethod {
        case .GET:
            request = create_GET_Request(service: service)
              break
        case .POST:
            request = create_POST_Request(service: service)
            break
        }
        return request
    }

    //MARK:- GET Request Method
  private func create_GET_Request(service: Service) -> URLRequest
    {
        let url = urlForGETRequest(service: service)
        var request = URLRequest(url: URL(string: url)!, cachePolicy:NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(WEBSERVICE_TIMEOUT_INTERVAL))
        request.httpMethod = service.httpMethod.rawValue
        for (key,value) in service.headers
        {
            request.addValue(value as! String, forHTTPHeaderField: key)
        }
        return request
    }
    
    private func urlForGETRequest(service: Service) -> String
    {
        let url = service.url
        var array_params = [String]()
        for (key,value) in service.params
        {
            array_params.append("\(key)=\(value)")
        }
        var paramString = ""
        if array_params.count > 0
        {
            let base_url = url! + "?"
            paramString = base_url + array_params.joined(separator: "&")
        }
        else
        {
            paramString = url!
        }
        var escapedString = paramString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        escapedString = escapedString?.trimmingCharacters(in: .whitespaces)
        return escapedString!
    }
    
    
    //MARK:- POST Request Method
   private func create_POST_Request(service: Service) -> URLRequest
    {
        var request = URLRequest(url: URL(string: service.url)!, cachePolicy:NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(WEBSERVICE_TIMEOUT_INTERVAL))
        request.httpMethod = service.httpMethod.rawValue
        
        if let value = service.headers[HTTPHeaderKey.HTTPHeaderKeyContenttype.rawValue] {
            let headerValue: HTTPHeaderValue = HTTPHeaderValue(rawValue: value as! String)!
            switch headerValue {
            case .HTTPHeaderValueApplicationFormURLEncoded:
                
                var array_params = [String]()
                for (key,value) in service.params
                {
                    array_params.append("\(key)=\(value)")
                }
                var paramString = ""
                paramString = paramString + array_params.joined(separator: "&")
                request.httpBody = paramString.data(using: .utf8)
            break
           
            case .HTTPHeaderValueApplicationJSON:
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: service.params, options: .prettyPrinted)
                } catch let error {
                    print(error.localizedDescription)
                }
                
            break
            }
        }
        
        for (key,value) in service.headers
        {
            request.addValue(value as! String, forHTTPHeaderField: key)
        }
        return request
    }

}
