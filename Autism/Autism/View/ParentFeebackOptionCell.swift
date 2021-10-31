//
//  ParentFeebackOptionCell.swift
//  Autism
//
//  Created by Savleen on 14/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol ParentFeebackOptionCellDelegate:NSObject {
    func didClickOn(buttonType:OptionButtonType,model:ProgramTypeModel,sender:UIButton)
}

class ParentFeebackOptionCell: UITableViewCell {
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var dontknowLabel: UILabel!
    //@IBOutlet weak var titleLabel: UILabel!
   // @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var titleLabelTextView: UITextView!
    @IBOutlet weak var questionLabelTextView: UITextView!

    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var dontknowButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var disableButton: UIButton!

    private weak var delegate: ParentFeebackOptionCellDelegate?
    private var programTypeModel: ProgramTypeModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(delegate:ParentFeebackOptionCellDelegate,model:ProgramTypeModel,labelResponse:ScreenLabelResponseVO) {
        self.delegate = delegate
        self.programTypeModel = model
        
        let title = model.name.replacingOccurrences(of: "\\n", with: "\n")
        self.titleLabelTextView.text = title
        self.questionLabelTextView.text = model.question.replacingOccurrences(of: "\\n", with: "\n")
        let radioOn = UIImage.init(named: "radioOn")
        let radioOff = UIImage.init(named: "radioOff")
        self.yesButton.setBackgroundImage(model.isYes ? radioOn : radioOff, for: .normal)
        self.noButton.setBackgroundImage(model.isNo ? radioOn : radioOff, for: .normal)
        self.dontknowButton.setBackgroundImage(model.isDontKnow ? radioOn : radioOff, for: .normal)
        self.yesLabel.text = labelResponse.getLiteralof(code: ParentFeedbackLabelCode.yes.rawValue).label_text
        self.noLabel.text = labelResponse.getLiteralof(code: ParentFeedbackLabelCode.no.rawValue).label_text
        self.dontknowLabel.text = labelResponse.getLiteralof(code: ParentFeedbackLabelCode.dont_know.rawValue).label_text
        self.questionButton.isHidden = model.info.count > 0 ? false : true
        self.disableButton.isHidden = !model.isrowDisable

    }
    
       @IBAction func yesClicked(_ sender: UIButton) {
           if let del = self.delegate {
               del.didClickOn(buttonType: .yes, model: self.programTypeModel, sender: sender)
           }
       }
       
       @IBAction func noClicked(_ sender: UIButton) {
            if let del = self.delegate {
                del.didClickOn(buttonType: .no, model: self.programTypeModel, sender: sender)
            }
       }
       
       @IBAction func dontKnowClicked(_ sender: UIButton) {
         if let del = self.delegate {
             del.didClickOn(buttonType: .dontKnow, model: self.programTypeModel, sender: sender)
         }
       }
    
       @IBAction func questionMarkClicked(_ sender: UIButton) {
            if let del = self.delegate {
                del.didClickOn(buttonType: .questionMark, model: self.programTypeModel, sender: sender)
            }
       }
    
}
