//
//  SequenceCell.swift
//  Autism
//
//  Created by Admin on 28/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class SequenceCell: UICollectionViewCell {
    @IBOutlet weak var lblText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Utility.setView(view: self.lblText, cornerRadius: 5, borderWidth: 2, color: .white)
    }
    
    func setData(model:ImageModel) {
        self.lblText.text = model.name
    }
}
