//
//  WebserviceParameter.swift
//  Assignment
//
//  Created by Atinderpal Singh on 05/02/19.
//  Copyright © 2019 Abc. All rights reserved.
//

import Foundation


enum WebserviceHTTPMethod: String {
    case GET  =   "GET"
    case POST =   "POST"
}

struct Service {
    var url: String!
    var httpMethod : WebserviceHTTPMethod
    var params : [String: Any]
    var headers : [String: Any]
    
    init(httpMethod :WebserviceHTTPMethod) {
        self.httpMethod = httpMethod
        self.params = [String: Any]()
        self.headers = [HTTPHeaderKey.HTTPHeaderKeyContenttype.rawValue:HTTPHeaderValue.HTTPHeaderValueApplicationJSON.rawValue]
        
    }
}
