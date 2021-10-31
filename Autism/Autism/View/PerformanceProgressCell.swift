//
//  PerformanceProgressCell.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/04/08.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class PerformanceProgressCell: UICollectionViewCell {
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var heigthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(model:PerformanceProgressModel) {
        self.titleLabel.text = model.title
        self.valueLabel.text = "\(Int(model.progressValue))"
        self.progressView.backgroundColor = model.progressColor
        let progress:CGFloat = 100/model.progressValue
        let updatedProgressValue:CGFloat = 300/progress
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, animations: {
                self.heigthConstraint.constant = CGFloat(updatedProgressValue)
                self.layoutIfNeeded()
            }) { (finish) in
            }
        }
        
    }

}
