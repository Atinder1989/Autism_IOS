//
//  Animation.swift
//  Autism
//
//  Created by Savleen on 23/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class Animations {
    static func shake(on onView: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 8
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: onView.center.x - 10, y: onView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: onView.center.x + 10, y: onView.center.y))
        onView.layer.add(animation, forKey: "position")
    }
    
    static func makeBiggerAnimation(isLeft:Bool = true, imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
        let initialW:CGFloat = imageView.frame.size.width
        var scaleSize:CGFloat = 0.0
        var diffC:CGFloat = 0.0
        if let option = questionInfo.option {
            scaleSize = CGFloat(option.larger_scale.floatValue)
            diffC = (initialW/2.0) * (scaleSize-1)
        }
        let initialC:CGFloat = imageView.center.x
        UIView.animate(withDuration: learningAnimationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            imageView.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize) // Scale your image
            if(isLeft == true) {
                imageView.center = CGPoint(x: initialC+diffC, y: imageView.center.y)
            } else {
                imageView.center = CGPoint(x: initialC-diffC, y: imageView.center.y)
            }
         }) { (finished) in
            completion(finished)
        }
        }
    }
       
    static func makeBiggerAnimationFromCenter(isLeft:Bool = true, imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
        var scaleSize:CGFloat = 0.0

        if let option = questionInfo.option {
            scaleSize = CGFloat(option.larger_scale.floatValue)
            scaleSize = 1.5
        }
        UIView.animate(withDuration: learningAnimationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            imageView.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize) // Scale your image
         }) { (finished) in
            completion(finished)
        }
        }
    }
    static func normalImageAnimation(isLeft:Bool = true, imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
        let initialW:CGFloat = imageView.frame.size.width
        let xScale:CGFloat = imageView.transform.a;
        let originalW:CGFloat = initialW/xScale
        let diffScale:CGFloat = xScale-1
        let diffC:CGFloat = (originalW/2.0) * diffScale
        UIView.animate(withDuration: learningAnimationDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            imageView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image
            if(isLeft == true) {
                imageView.center = CGPoint(x: imageView.center.x-diffC, y: imageView.center.y)
            } else {
                imageView.center = CGPoint(x: imageView.center.x+diffC, y: imageView.center.y)
            }
         }) { (finished) in
            completion(finished)
         }
        }
     }
    
    static func makeBiggerWithoutCenterAnimation(imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
        let initialW:CGFloat = imageView.frame.size.width
        var scaleSize:CGFloat = 0.0
        var diffC:CGFloat = 0.0
        if let option = questionInfo.option {
            scaleSize = CGFloat(option.larger_scale.floatValue)
            diffC = (initialW/2.0) * (scaleSize-1)
        }
        let initialC:CGFloat = imageView.center.x
        UIView.animate(withDuration: learningAnimationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            imageView.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize) // Scale your image
//            imageView.center = CGPoint(x: initialC+diffC, y: imageView.center.y)
         }) { (finished) in
            completion(finished)
        }
        }
    }
    
    static func normalImageWithoutCenterAnimation(imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
        let initialW:CGFloat = imageView.frame.size.width
        let xScale:CGFloat = imageView.transform.a;
        let originalW:CGFloat = initialW/xScale
        let diffScale:CGFloat = xScale-1
        let diffC:CGFloat = (originalW/2.0) * diffScale
        UIView.animate(withDuration: learningAnimationDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            imageView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image
//            imageView.center = CGPoint(x: imageView.center.x-diffC, y: imageView.center.y)
         }) { (finished) in
            completion(finished)
         }
        }
     }
    
    static func dragImageAnimation(leftImageView:UIImageView,rightImageView:UIImageView,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
            
        UIView.animate(withDuration: 5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            rightImageView.frame = leftImageView.frame
         }) { (finished) in
            completion(finished)
        }
            
        }
    }
    
    
    static func makeCenterImageBiggerAnimation(imageView:UIImageView,questionInfo:ScriptCommandInfo,completion: @escaping (Bool) -> ())
    {
        DispatchQueue.main.async {
        var scaleSize:CGFloat = 0.0
        if let option = questionInfo.option {
            scaleSize = CGFloat(option.larger_scale.floatValue - 0.5)
        }
        UIView.animate(withDuration: learningAnimationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            imageView.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize) // Scale your image
         }) { (finished) in
            completion(finished)
        }
        }
    }
    
    
    
}
