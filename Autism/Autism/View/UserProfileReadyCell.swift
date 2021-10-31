//
//  UserProfileReadyCell.swift
//  Autism
//
//  Created by Savleen on 15/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol UserProfileReadyCellDelegate:NSObject {
    func didClickOnReady()
}

class UserProfileReadyCell: UICollectionViewCell {
    @IBOutlet weak var readyButton: UIButton!
   // @IBOutlet weak var helpusLabel: UILabel!
    @IBOutlet weak var helpusTextView: UITextView!

    
     weak var delegate: UserProfileReadyCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Utility.setView(view: self.readyButton, cornerRadius: 60, borderWidth: 0.5, color: .darkGray)
    }
    func setData(labelsResponseVO: ScreenLabelResponseVO,delegate:UserProfileReadyCellDelegate) {
        self.delegate = delegate
       // self.readyButton.setTitle(labelsResponseVO.getLiteralof(code: UserProfileLabelCode.ready.rawValue).label_text, for: .normal)
        let text = labelsResponseVO.getLiteralof(code: UserProfileLabelCode.help_us_understand.rawValue).label_text.replacingOccurrences(of: "\\n", with: "\n")
        self.helpusTextView.text = text
    }
    
    @IBAction func readyClicked(_ sender: Any) {
        if let del = self.delegate {
            del.didClickOnReady()
        }
    }
}
