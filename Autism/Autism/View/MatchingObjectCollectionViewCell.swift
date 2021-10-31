//
//  MatchingObjectCollectionViewCell.swift
//  Autism
//
//  Created by Dilip Technology on 16/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class MatchingObjectCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageObject: ImageViewWithID!
    @IBOutlet weak var greenTickImageView: UIImageView!
    
    @IBOutlet weak var fingerImageView: UIImageView!
    
    @IBOutlet weak var imgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setConstraints(value:CGFloat)
    {
        imgWidthConstraint.constant = value
        imgHeightConstraint.constant = value
    }
}
