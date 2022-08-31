//
//  Data+Extension.swift
//  Autism
//
//  Created by Singh, Atinderpal on 28/08/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
       if let data = string.data(using: .utf8) {
          append(data)
       }
    }
}
