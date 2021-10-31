//
//  ServiceEnvironment.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/04/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

enum ServiceEnvironment : String {
  
    case Testing   = "https://impute.co.jp:3300/v1/"
    case Development = "https://impute.co.jp:3400/v1/"
    
    func getMediaBaseUrl() -> String {
         return "https://autism-images.s3.ap-northeast-1.amazonaws.com/"

    }
}

