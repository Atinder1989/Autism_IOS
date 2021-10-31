//
//  LanguageCell.swift
//  Autism
//
//  Created by IMPUTE on 30/01/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
class LanguageCell: UICollectionViewCell {
    @IBOutlet weak var languageName: UILabel!
    @IBOutlet weak var languageImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(model:LanguageModel) {
        self.languageName.text = model.name
        self.languageImageView.setImageWith(urlString: model.image)
        
    }
}



