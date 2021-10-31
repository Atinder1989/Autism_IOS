//
//  MenuListCell.swift
//  Autism
//
//  Created by Savleen on 30/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class MenuListCell: UITableViewCell {
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(item:MenuItem,labelResponse:ScreenLabelResponseVO) {
        self.menuLabel.text = item.getName(labelResponse: labelResponse)
        self.menuImageView.image = UIImage.init(named: item.rawValue)
        
    }
    
}
