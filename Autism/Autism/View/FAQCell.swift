//
//  FAQCell.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/04/03.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class FAQCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bgView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(model: FAQModel) {
        self.titleLabel.text = model.title
        self.descriptionLabel.text = model.text

    }
}
