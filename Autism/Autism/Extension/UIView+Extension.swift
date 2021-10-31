//
//  UIView+Extension.swift
//  JioMusic
//
//  Created by Atinderpal Singh on 23/02/18.
//  Copyright © 2018 Reliance Jio Infocomm Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func addDashedBorder(cornerRadius: CGFloat, linewidth : CGFloat, color : UIColor,dashpattern:[NSNumber]) {
    self.layer.masksToBounds = true
    self.layer.cornerRadius = cornerRadius
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    let frameSize = self.frame.size
    let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
    shapeLayer.bounds = shapeRect
    shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.lineWidth = linewidth
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    shapeLayer.lineDashPattern = dashpattern //[6,3]
    shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath

    self.layer.addSublayer(shapeLayer)
    }
    
    func allSubViewsOf<T: UIView>(type: T.Type) -> [T] {
           var all = [T]()
           func getSubview(view: UIView) {
               if let aView = view as? T {
                   all.append(aView)
               }
               guard view.subviews.count>0 else { return }
               view.subviews.forEach { getSubview(view: $0) }
           }
           getSubview(view: self)
           return all
       }
       /// S
    
    
}
