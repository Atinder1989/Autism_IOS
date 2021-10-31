//
//  OptionTextCell.swift
//  Autism
//
//  Created by Savleen on 18/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class OptionTextCell: UICollectionViewCell {
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(model: ImageModel) {
        self.textLbl.text = model.name
    }

}
