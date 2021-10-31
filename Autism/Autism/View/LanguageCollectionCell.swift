//
//  LanguageCollectionCell.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/27.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class LanguageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var languageName: UILabel!
    @IBOutlet weak var languageImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(model:LanguageModel) {
        self.languageName.text = model.name
        self.languageImageView.setImageWith(urlString:ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
    }
}
