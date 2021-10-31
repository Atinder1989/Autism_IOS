//
//  DashboardSkillCell.swift
//  Autism
//
//  Created by Savleen on 30/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class DashboardSkillCell: UICollectionViewCell {
    @IBOutlet weak var circularProgress: CircularProgressView!
    @IBOutlet weak var percentlabel: UILabel!
    @IBOutlet weak var textlabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        Utility.setView(view: self, cornerRadius: 15, borderWidth: 0, color: .clear)
    }
    func setData(model:PerformanceDetail,assessment_status:ModuleStatus,learning_status:ModuleStatus,courseType:CourseModule) {
        circularProgress.trackColor = model.trackColor
        circularProgress.progressColor = model.progressColor
        self.textlabel.text = model.key
        self.percentlabel.textColor = model.progressColor
        
        circularProgress.isHidden = true
        self.lockImageView.isHidden = true
        self.logoImageView.isHidden = true
        
        if courseType == .assessment {
            if !model.assesment_question {
                self.lockImageView.isHidden = false
            } else {
                let score = Double(model.assesment_score)
                let value:Double = Double(score/100)
                circularProgress.setProgressWithAnimation(duration: 0, value: Float(value))
                self.percentlabel.text = "\(model.assesment_score)%"
                circularProgress.isHidden = false
            }
            
        } else if courseType == .learning {
            if !model.assesment_question {
                self.lockImageView.isHidden = false
            } else if model.assesment_status == .completed && assessment_status == .completed {
                self.logoImageView.isHidden = false
            }
        }
        
    }
    
    
   
}


