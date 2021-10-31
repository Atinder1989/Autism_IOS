//
//  UserInfoCell.swift
//  Autism
//
//  Created by IMPUTE on 31/01/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol UserInfoCellDelegate:NSObject {
    func didTextFieldValueChange(formModel:FormModel)
    func didClickOnCalender(sender:UIButton)
    func didClickOnCountry(sender:UIButton)
    func didClickOnState(sender:UIButton)
    func didClickOnOtherDetail(sender:UIButton,formModel:FormModel)
    func didClickOnPriority(sender:UIButton,formModel:FormModel)
    func didClickOnForgot()
}

extension UserInfoCellDelegate {
    func didTextFieldValueChange(formModel:FormModel){}
    func didClickOnCalender(sender:UIButton) {}
    func didClickOnCountry(sender:UIButton) {}
    func didClickOnState(sender:UIButton) {}
    func didClickOnOtherDetail(sender:UIButton,formModel:FormModel){}
    func didClickOnPriority(sender:UIButton,formModel:FormModel) {}
    func didClickOnForgot() {}
}

class UserInfoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    @IBOutlet weak var dataTextField: UITextField!
    @IBOutlet weak var popOverButton: UIButton!
    @IBOutlet weak var popOverTransparentButton: UIButton!

    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var priorityImageView: UIImageView!

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titlePopOverButton: UIButton!
    @IBOutlet weak var forgotButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var popOverButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var priorityImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var priorityImageViewHeight: NSLayoutConstraint!
    
    private weak var delegate: UserInfoCellDelegate?
    private  var formModel:FormModel!
    private var labelResponse:ScreenLabelResponseVO!
    override func awakeFromNib() {
        super.awakeFromNib()
        let borderColor = UIColor.init(red: 223/255.0, green: 227/255.0, blue: 232/255.0, alpha: 1)
        Utility.setView(view: self.bgView, cornerRadius: 3, borderWidth: 1, color: borderColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(model:FormModel,delegate:UserInfoCellDelegate,labelResponse:ScreenLabelResponseVO?) {
        self.labelResponse = labelResponse
        self.formModel = model
        self.delegate = delegate
        self.titleLabel.text = model.title
        self.dataTextField.text = model.text
        self.dataTextField.isSecureTextEntry = model.isSecureTextEntry
        
        self.priorityImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image)
        let color = UIColor.init(red: 189/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1)
        dataTextField.attributedPlaceholder = NSAttributedString(string: model.placeholder, attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : UIFont(name: AppFont.helveticaNeue.rawValue, size: 14)!])
        if let lbRes = self.labelResponse {
            self.forgotButton.setTitle(lbRes.getLiteralof(code: LoginLabelCode.forgot_password.rawValue).label_text, for: .normal)
            
            if lbRes.getLiteralof(code: UserProfileLabelCode.parent_contact_number.rawValue).label_text == model.title {
                self.dataTextField.keyboardType = .phonePad
            } else {
                self.dataTextField.keyboardType = .default
            }
        }
    }
    
    @IBAction func textfieldEditingValueChange(_ sender: UITextField) {
        self.formModel.text = sender.text ?? ""
        if let del = self.delegate {
            del.didTextFieldValueChange(formModel: self.formModel)
        }
    }
    
    @IBAction func forgotPasswordClicked(_ sender: UITextField) {
        if let del = self.delegate {
            del.didClickOnForgot()
        }
    }

    @IBAction func popOverClicked(_ sender: UIButton) {
            if let del = self.delegate {
                if let lbRes = self.labelResponse {
                if self.formModel.title == self.labelResponse.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text {
                    del.didClickOnCalender(sender: sender)
                } else if self.formModel.title == self.labelResponse.getLiteralof(code: UserProfileLabelCode.country.rawValue).label_text {
                    del.didClickOnCountry(sender: sender)
                } else if self.formModel.title == self.labelResponse.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text {
                    del.didClickOnState(sender: sender)
                } else if self.formModel.title.lowercased().contains(lbRes.getLiteralof(code: UserProfileLabelCode.details.rawValue).label_text) {
                    del.didClickOnOtherDetail(sender: sender, formModel: formModel)
                }else if self.formModel.title.lowercased().contains(lbRes.getLiteralof(code: UserProfileLabelCode.priority.rawValue).label_text) {
                    del.didClickOnPriority(sender: popOverButton, formModel: self.formModel)
                }
                }
            }
    }
}

extension UserInfoCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        if self.labelResponse.getLiteralof(code: UserProfileLabelCode.parent_contact_number.rawValue).label_text == formModel.title {
           
            if let _ = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) {
                 return true
            } else {
                 return false
            }
        }
        
        if self.labelResponse.getLiteralof(code: UserProfileLabelCode.nickname.rawValue).label_text == formModel.title {
            if let text = textField.text {
                if text.count < Int(AppConstant.maxCharacterLimitForNickname.rawValue)!   {
                        let characterSet = CharacterSet.letters
                        if text.rangeOfCharacter(from: characterSet.inverted) != nil {
                            return false
                        }
                    if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                            return false
                    }
                  return true
                } else {
                    return false
                }
            } else {
                return true
            }
        }
        
        if self.labelResponse.getLiteralof(code: UserProfileLabelCode.guardian_name.rawValue).label_text == formModel.title {
            if let text = textField.text {
                if text.count < Int(AppConstant.maxCharacterLimitForGuardianName.rawValue)!  {
                    let characterSet = CharacterSet.letters
                        if text.rangeOfCharacter(from: characterSet.inverted) != nil {
                            return false
                        }
                        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                            return false
                        }
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        }
        
        return true
    }
}

