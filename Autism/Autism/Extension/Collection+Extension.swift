//
//  Collection+Extension.swift
//  Autism
//
//  Created by Savleen on 20/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

extension Collection where Element == CGFloat, Index == Int {
    /// Return the mean of a list of CGFloat. Used with `recentVirtualObjectDistances`.
    var average: CGFloat? {
        guard !isEmpty else {
            return nil
        }
        
        let sum = reduce(CGFloat(0)) { current, next -> CGFloat in
            return current + next
        }
        
        return sum / CGFloat(count)
    }
}
