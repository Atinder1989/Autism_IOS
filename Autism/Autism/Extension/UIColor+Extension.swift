//
//  UIColor+Extension.swift
//  Autism
//
//  Created by Savleen on 24/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

extension UIColor {
    static var greenBorderColor: UIColor {
           return UIColor.init(red: 38/255.0, green: 230/255.0, blue: 192/255.0, alpha: 1)
    }
    
    static var purpleBorderColor: UIColor {
           return UIColor(red: 123/255.0, green: 65/255.0, blue: 235/255.0, alpha: 1.0)
    }
    
    static var redBorderColor: UIColor {
           return UIColor(red: 233/255.0, green: 62/255.0, blue: 97/255.0, alpha: 1.0)
    }
       
    convenience init?(hexaRGB: String, alpha: CGFloat = 1) {
           var chars = Array(hexaRGB.hasPrefix("#") ? hexaRGB.dropFirst() : hexaRGB[...])
           switch chars.count {
           case 3: chars = chars.flatMap { [$0, $0] }
           case 6: break
           default: return nil
           }
           self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                   green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                    blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                   alpha: alpha)
       }
    
}
