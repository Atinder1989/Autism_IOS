//
//  OptionCell.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/19.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

enum OptionButtonType: String {
    case yes = "yes"
    case no = "no"
    case dontKnow = "dontKnow"
    case questionMark = "questionMark"
}

protocol OptionCellDelegate:NSObject {
    func didClickOn(buttonType:OptionButtonType,model:OptionModel,sender:UIButton)
}

class OptionCell: UITableViewCell {
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var dontknowLabel: UILabel!
    //@IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!

    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var dontknowButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!

    private weak var delegate: OptionCellDelegate?
    private var optionModel: OptionModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func setData(delegate:OptionCellDelegate,model:OptionModel,labelResponse:ScreenLabelResponseVO) {
        self.delegate = delegate
        self.optionModel = model
        self.titleTextView.text = model.name.replacingOccurrences(of: "\\n", with: "\n")
        let radioOn = UIImage.init(named: "radioOn")
        let radioOff = UIImage.init(named: "radioOff")
        self.yesButton.setBackgroundImage(model.isYes ? radioOn : radioOff, for: .normal)
        self.noButton.setBackgroundImage(model.isNo ? radioOn : radioOff, for: .normal)
        self.dontknowButton.setBackgroundImage(model.isDontKnow ? radioOn : radioOff, for: .normal)
        self.yesLabel.text = labelResponse.getLiteralof(code: UserProfileLabelCode.yes.rawValue).label_text
        self.noLabel.text = labelResponse.getLiteralof(code: UserProfileLabelCode.no.rawValue).label_text
        self.dontknowLabel.text = labelResponse.getLiteralof(code: UserProfileLabelCode.dont_know.rawValue).label_text
        self.questionButton.isHidden = model.info.count > 0 ? false : true
    }
    
    @IBAction func yesClicked(_ sender: UIButton) {
        if let del = self.delegate {
            del.didClickOn(buttonType: .yes, model: self.optionModel, sender: sender)
        }
    }
    
    @IBAction func noClicked(_ sender: UIButton) {
         if let del = self.delegate {
             del.didClickOn(buttonType: .no, model: self.optionModel, sender: sender)
         }
    }
    
    @IBAction func dontKnowClicked(_ sender: UIButton) {
      if let del = self.delegate {
          del.didClickOn(buttonType: .dontKnow, model: self.optionModel, sender: sender)
      }
    }
    @IBAction func questionMarkClicked(_ sender: UIButton) {
         if let del = self.delegate {
             del.didClickOn(buttonType: .questionMark, model: self.optionModel, sender: sender)
         }
       }
}
