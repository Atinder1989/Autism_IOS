//
//  StampView.swift
//  Autism
//
//  Created by Savleen on 26/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

@objc public protocol StampViewDelegate {
    
    func stampDidSelcted(_ colourPadView:StampView, _ stamp:String)
}

public class StampView: UIView {
    
    @objc var delegate:StampViewDelegate?
    var indexNumber:Int = 0
    
    let btnHeart:UIButton = UIButton()
    let btnStar:UIButton = UIButton()
    let btnSmile:UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let yRef:CGFloat = 20.0
                        
        let pWidth:CGFloat = 100
        let pHeight:CGFloat = 100.0
        var xRef:CGFloat = (frame.size.width-(3*pWidth))/4.0
        let xSpace:CGFloat = xRef

        btnHeart.frame = CGRect(x: xRef, y: yRef, width: pWidth, height: pHeight)
        btnHeart.backgroundColor = .clear
        btnHeart.setTitleColor(.black, for: .normal)
        btnHeart.setTitle("Heart", for: .disabled)
        btnHeart.setBackgroundImage(UIImage.init(named: "Heart"), for: .normal)
        self.addSubview(btnHeart)
        
        xRef = xRef+xSpace+pHeight
        
        btnStar.frame = CGRect(x: xRef, y: yRef, width: pWidth, height: pHeight)
        btnStar.setTitle("Star", for: .disabled)
        btnStar.setBackgroundImage(UIImage.init(named: "Star"), for: .normal)
        btnStar.backgroundColor = .clear
        btnStar.setTitleColor(.gray, for: .normal)
        self.addSubview(btnStar)
        
        xRef = xRef+xSpace+pHeight
        
        btnSmile.frame = CGRect(x: xRef, y: yRef, width: pWidth, height: pHeight)
        btnSmile.setTitle("Smile", for: .disabled)
        btnSmile.setBackgroundImage(UIImage.init(named: "Smile"), for: .normal)
        btnSmile.backgroundColor = .clear
        btnSmile.setTitleColor(.lightGray, for: .normal)
        self.addSubview(btnSmile)
        
        btnHeart.addTarget(self, action: #selector(btnStampClicked(_:)), for: .touchDown)
        btnStar.addTarget(self, action: #selector(btnStampClicked(_:)), for: .touchDown)
        btnSmile.addTarget(self, action: #selector(btnStampClicked(_:)), for: .touchDown)
    }
        
    @objc func btnStampClicked(_ sender:UIButton) {
        
        UIView.animate(withDuration: 0.3,
                   delay: 0.3,
                   options: UIView.AnimationOptions.curveEaseIn,
                   animations: { () -> Void in
                    self.frame = CGRect(x: -self.frame.size.width, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)

                    }, completion: { (finished) -> Void in
                        self.delegate?.stampDidSelcted(self, sender.title(for: .disabled)!)
                    })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
