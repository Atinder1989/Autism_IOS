//
//  ColourPadView.swift
//  Autism
//
//  Created by Savleen on 26/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

@objc public protocol ColourPadViewDelegate {
    
    func colourDidSelcted(_ colourPadView:ColourPadView, _ color:UIColor)
}

public class ColourPadView: UIView {
    
    @objc var delegate:ColourPadViewDelegate?
    var indexNumber:Int = 0
    
    let btnViewBlack:UIButton = UIButton()
    let btnViewGray:UIButton = UIButton()
    let btnViewLightGray:UIButton = UIButton()
    
    let btnViewRed:UIButton = UIButton()
    let btnViewGreen:UIButton = UIButton()
    let btnViewBlue:UIButton = UIButton()
    
    let btnViewCyan:UIButton = UIButton()
    let btnViewYellow:UIButton = UIButton()
    let btnViewMegenda:UIButton = UIButton()
    let btnViewOrange:UIButton = UIButton()
    let btnViewPurple:UIButton = UIButton()
    let btnViewBrown:UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var yRef:CGFloat = 20.0
        let ySpace:CGFloat = 2.0
        
        let pWidth:CGFloat = frame.size.width
        let halfWidth:CGFloat = frame.size.width/2.0
        let pHeight:CGFloat = 40.0
        
        btnViewBlack.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewBlack.backgroundColor = .black
        btnViewBlack.setTitleColor(.black, for: .normal)
        self.addSubview(btnViewBlack)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewGray.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewGray.backgroundColor = .gray
        btnViewGray.setTitleColor(.gray, for: .normal)
        self.addSubview(btnViewGray)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewLightGray.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewLightGray.backgroundColor = .lightGray
        btnViewLightGray.setTitleColor(.lightGray, for: .normal)
        self.addSubview(btnViewLightGray)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewRed.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewRed.backgroundColor = .red
        btnViewRed.setTitleColor(.red, for: .normal)
        self.addSubview(btnViewRed)
        
        yRef = yRef+ySpace+pHeight
                
        btnViewGreen.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewGreen.backgroundColor = .green
        btnViewGreen.setTitleColor(.green, for: .normal)
        self.addSubview(btnViewGreen)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewBlue.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewBlue.backgroundColor = .blue
        btnViewBlue.setTitleColor(.blue, for: .normal)
        self.addSubview(btnViewBlue)
        
        yRef = yRef+ySpace+pHeight

        btnViewCyan.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewCyan.backgroundColor = .cyan
        btnViewCyan.setTitleColor(.cyan, for: .normal)
        self.addSubview(btnViewCyan)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewYellow.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewYellow.backgroundColor = .yellow
        btnViewYellow.setTitleColor(.yellow, for: .normal)
        self.addSubview(btnViewYellow)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewMegenda.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewMegenda.backgroundColor = .magenta
        btnViewMegenda.setTitleColor(.magenta, for: .normal)
        self.addSubview(btnViewMegenda)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewOrange.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewOrange.backgroundColor = .orange
        btnViewOrange.setTitleColor(.orange, for: .normal)
        self.addSubview(btnViewOrange)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewPurple.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewPurple.backgroundColor = .purple
        btnViewPurple.setTitleColor(.purple, for: .normal)
        self.addSubview(btnViewPurple)
        
        yRef = yRef+ySpace+pHeight
        
        btnViewBrown.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
        btnViewBrown.backgroundColor = .brown
        btnViewBrown.setTitleColor(.brown, for: .normal)
        self.addSubview(btnViewBrown)

        
        
        btnViewBlack.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewGray.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewLightGray.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        
        btnViewRed.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewGreen.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewBlue.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        
        btnViewCyan.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewYellow.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewMegenda.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewOrange.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewPurple.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
        btnViewBrown.addTarget(self, action: #selector(btnColourClicked(_:)), for: .touchDown)
    }
        
    @objc func btnColourClicked(_ sender:UIButton) {

        var yRef:CGFloat = 20.0
        let ySpace:CGFloat = 2.0
        
        let pWidth:CGFloat = frame.size.width
        let halfWidth:CGFloat = frame.size.width/2.0
        let pHeight:CGFloat = 40.0
        
        UIView.animate(withDuration: 0.1,
                   delay: 0.1,
                   options: UIView.AnimationOptions.curveEaseIn,
                   animations: { () -> Void in

                    self.btnViewBlack.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewGray.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewLightGray.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewRed.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewGreen.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewBlue.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewCyan.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewYellow.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewMegenda.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewOrange.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewPurple.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    self.btnViewBrown.frame = CGRect(x: -halfWidth, y: yRef, width: pWidth, height: pHeight)
                    yRef = yRef+ySpace+pHeight
                    
                    sender.frame = CGRect(x: -halfWidth+(halfWidth/2.0), y: sender.frame.origin.y, width: pWidth, height: pHeight)
                    
                    }, completion: { (finished) -> Void in
                        self.delegate?.colourDidSelcted(self, sender.backgroundColor!)
                        self.delegate?.colourDidSelcted(self, sender.titleColor(for: .normal)!)
                    })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



