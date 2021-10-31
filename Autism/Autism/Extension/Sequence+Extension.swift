//
//  Sequence+Extension.swift
//  Autism
//
//  Created by Savleen on 02/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

extension Sequence where Element: Hashable  {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
    
        func uniqued() -> [Element] {
            var set = Set<Element>()
            return filter { set.insert($0).inserted }
        }
   
}
