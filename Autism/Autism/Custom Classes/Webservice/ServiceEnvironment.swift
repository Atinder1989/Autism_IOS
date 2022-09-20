//
//  ServiceEnvironment.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/04/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

enum ServiceEnvironment : String {
  
    case Development    = "https://impute.co.jp:5000/v1/"    
    case Production     = "https://impute.co.jp:5002/v1/"
    case Testing        = "https://impute.co.jp:5003/v1/"
    
    func getMediaBaseUrl() -> String {
         return "https://autism-images.s3.ap-northeast-1.amazonaws.com/"
    }
}

