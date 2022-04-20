//
//  BucketView.swift
//  Autism
//
//  Created by Savleen on 30/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import UIKit

class BucketView : UIView {
    var iModel : ImageModel?
    
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!

    func settingIPhoneFrames() {
        
        imgView1.frame = CGRect(x: 30, y: 40, width: 40, height: 40)
        imgView1.frame = CGRect(x: 30, y: 40, width: 40, height: 40)
        imgView1.frame = CGRect(x: 30, y: 40, width: 40, height: 40)
    }
    
    func settingIPadFrames() {
        imgView1.frame = CGRect(x: 30, y: 40, width: 40, height: 40)
        imgView1.frame = CGRect(x: 30, y: 40, width: 40, height: 40)
        imgView1.frame = CGRect(x: 30, y: 40, width: 40, height: 40)
    }
    
}


