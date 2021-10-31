//
//  CircularProgressView.swift
//  Autism
//
//  Created by Savleen on 30/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {
   private var progressLyr = CAShapeLayer()
   private var trackLyr = CAShapeLayer()
    
   var progressColor = UIColor.white {
       didSet {
          progressLyr.strokeColor = progressColor.cgColor
       }
    }
    var trackColor = UIColor.white {
       didSet {
          trackLyr.strokeColor = trackColor.cgColor
       }
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       makeCircularPath()
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        self.makeCircularPath()
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
       let animation = CABasicAnimation(keyPath: "strokeEnd")
       animation.duration = duration
       animation.fromValue = 0
       animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
       progressLyr.strokeEnd = CGFloat(value)
       progressLyr.add(animation, forKey: "animateprogress")
    }
    
   private func makeCircularPath() {
       self.backgroundColor = UIColor.clear
       self.layer.cornerRadius = self.frame.size.width/2
       let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
       trackLyr.path = circlePath.cgPath
       trackLyr.fillColor = UIColor.clear.cgColor
       trackLyr.strokeColor = trackColor.cgColor
       trackLyr.lineWidth = 5.0
       trackLyr.strokeEnd = 1.0
       layer.addSublayer(trackLyr)
       progressLyr.path = circlePath.cgPath
       progressLyr.fillColor = UIColor.clear.cgColor
       progressLyr.strokeColor = progressColor.cgColor
       progressLyr.lineWidth = 5.0
       progressLyr.strokeEnd = 0.0
       layer.addSublayer(progressLyr)
    }
}
