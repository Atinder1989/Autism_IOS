//
//  ProfileIssueCell.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/19.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

enum UserProfileStageType: String {
    case basicInfo          = "basicInfo"
    case ready              = "ready"
    case sensoryIssue       = "SENSORY ISSUE?"
    case challengingBehaviour  = "CHANGING BEHAVIOUR?"
    case otherDetails       = "Other Details"
    case reinforcers       = "reinforcers"
    case none = "none"
}

protocol ProfileIssueCellDelegate:NSObject {
    func didClickOnQuestionMark(sender:UIButton,optionModel:OptionModel)
    func didClickOnOtherDetail(sender:UIButton,formModel:FormModel)
    func didClickOnPriority(sender:UIButton,formModel:FormModel)
    func didUpdateListOf(type:UserProfileStageType,updatedList:[OptionModel],formlist:[FormModel])
    func didClickOnNext()
}

class ProfileIssueCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var issuesListTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    private var optionList = [OptionModel]()
    private var formlist = [FormModel]()

    private var profileStageType:UserProfileStageType = .none
    private weak var delegate: ProfileIssueCellDelegate?
    private var labelResponse:ScreenLabelResponseVO!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Utility.setView(view: self.nextButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        issuesListTableView.register(OptionCell.nib, forCellReuseIdentifier: OptionCell.identifier)
        issuesListTableView.register(UserInfoCell.nib, forCellReuseIdentifier: UserInfoCell.identifier)
        self.issuesListTableView.delegate = self
        self.issuesListTableView.dataSource = self
        self.issuesListTableView.tableFooterView = UIView.init()
    }
    
    func setData(optionList:[OptionModel],stageType:UserProfileStageType,list:[FormModel],delegate:ProfileIssueCellDelegate?,labelResponse:ScreenLabelResponseVO) {
        self.formlist = list
        self.delegate = delegate
        self.labelResponse = labelResponse
        self.optionList = optionList
        self.profileStageType = stageType
        
        self.nextButton.setTitle(labelResponse.getLiteralof(code: UserProfileLabelCode.next.rawValue).label_text, for: .normal)
        switch stageType {
        case .sensoryIssue:
            self.titleLabel.text = labelResponse.getLiteralof(code: UserProfileLabelCode.sensory_issues.rawValue).label_text
        case .challengingBehaviour:
            self.titleLabel.text = labelResponse.getLiteralof(code: UserProfileLabelCode.challenging_behaviour.rawValue).label_text
        case .otherDetails:
            self.titleLabel.text = labelResponse.getLiteralof(code: UserProfileLabelCode.other_details.rawValue).label_text
        case .reinforcers:
            self.titleLabel.text = labelResponse.getLiteralof(code: UserProfileLabelCode.reinforcers_favourite.rawValue).label_text
            self.nextButton.setTitle(labelResponse.getLiteralof(code: UserProfileLabelCode.Submit.rawValue).label_text, for: .normal)
        default:
            break
        }
        self.issuesListTableView.reloadData()
    }
    
     @IBAction func nextClicked(_ sender: Any) {
           if let del = self.delegate {
               del.didClickOnNext()
           }
    }
    
}


// MARK: UITableview Delegates And Datasource Methods
extension ProfileIssueCell : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch profileStageType {
        case .sensoryIssue,.challengingBehaviour:
                    return self.optionList.count
        case .otherDetails:
            return self.optionList.count + self.formlist.count
        case .reinforcers:
            return self.formlist.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.profileStageType == .reinforcers {
            return 70
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch profileStageType {
            case .sensoryIssue,.challengingBehaviour:
                let cell = tableView.dequeueReusableCell(withIdentifier: OptionCell.identifier) as! OptionCell
                cell.selectionStyle = .none
                cell.setData(delegate: self, model: self.optionList[indexPath.row], labelResponse: self.labelResponse)
                return cell
            case .otherDetails:
                
                if indexPath.row > 2 {
                    var model = FormModel.init(title: "", isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage: "", image: "", placeholder: "")
                    if indexPath.row == 3 {
                        model = self.formlist[0]
                    } else {
                        model = self.formlist[1]
                    }

                let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier) as! UserInfoCell
                    cell.selectionStyle = .none

                    cell.setData(model: model, delegate: self, labelResponse: self.labelResponse)
                    cell.titleLabel.textColor = UIColor.init(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1)
                    cell.bgView.isHidden = true
                    cell.titlePopOverButton.isHidden = true
                    cell.detailLabel.isHidden = false
                    cell.detailLabel.text = model.text
//                    cell.dataTextField?.textColor = .black
//                    cell.dataTextField.isUserInteractionEnabled = false
//                    cell.bgView.backgroundColor = .clear
//                    Utility.setView(view: cell.bgView, cornerRadius: 0, borderWidth: 0, color: .clear)
                    
                    return cell
                }
                    
                
                let optionCell = tableView.dequeueReusableCell(withIdentifier: OptionCell.identifier) as! OptionCell
                optionCell.selectionStyle = .none

                optionCell.setData(delegate: self, model: self.optionList[indexPath.row], labelResponse: self.labelResponse)
                return optionCell
            
            case .reinforcers:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier) as! UserInfoCell
                cell.selectionStyle = .none

            var model = self.formlist[indexPath.row]
            
            let nameToShowSelected = model.text
            print("nameToShowSelected = ", nameToShowSelected)
            let arrTemp = nameToShowSelected.components(separatedBy: ",")
            if(arrTemp.count > 1) {
                model.text = arrTemp[0]
            }

            cell.setData(model: model, delegate: self, labelResponse: self.labelResponse)
            cell.titleLabel.textColor = UIColor.init(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1)
            cell.dataTextField?.textColor = .black
            cell.dataTextField.isUserInteractionEnabled = false
            
        /*    if indexPath.row < self.formlist.count - 2 {
                cell.popOverButton.isHidden = false
                cell.popOverTransparentButton.isHidden = false
                cell.priorityImageView.isHidden = false
                cell.priorityImageViewWidth.constant = 30
                cell.priorityImageViewHeight.constant = 30
                cell.popOverButton.setBackgroundImage(UIImage.init(named: "downarrow"), for: .normal)
                cell.bgView.backgroundColor = .clear
                Utility.setView(view: cell.bgView, cornerRadius: 0, borderWidth: 0, color: .clear)
            }
            else {
                cell.forgotButtonWidth.constant = 0
                cell.popOverButton.isHidden = true
                cell.popOverTransparentButton.isHidden = true
                cell.dataTextField.isUserInteractionEnabled = true
                cell.priorityImageView.isHidden = true
                cell.priorityImageViewWidth.constant = 0
                cell.priorityImageViewHeight.constant = 0
                cell.bgView.backgroundColor = UIColor.init(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
                let borderColor = UIColor.init(red: 223/255.0, green: 227/255.0, blue: 232/255.0, alpha: 1)
                Utility.setView(view: cell.bgView, cornerRadius: 3, borderWidth: 1, color: borderColor)
            } */
                
                cell.popOverButton.isHidden = false
                cell.popOverTransparentButton.isHidden = false
                cell.priorityImageView.isHidden = false
                cell.priorityImageViewWidth.constant = 30
                cell.priorityImageViewHeight.constant = 30
                cell.popOverButton.setBackgroundImage(UIImage.init(named: "downarrow"), for: .normal)
                cell.bgView.backgroundColor = .clear
                Utility.setView(view: cell.bgView, cornerRadius: 0, borderWidth: 0, color: .clear)
                
            return cell
            default:
                   break
        }
        return UITableViewCell.init()
    }
}

extension ProfileIssueCell: OptionCellDelegate {
    func didClickOn(buttonType:OptionButtonType,model:OptionModel,sender:UIButton) {
        print(self.profileStageType)
        var index = -1
        for (i, m) in self.optionList.enumerated()
        {
            if m.name == model.name {
                index = i
                break
            }
        }
        
         var newModel = OptionModel.init(id: model.id, name: model.name, lngCode: model.language_code, isyes: false, isno: false, isdontknow: false, infoList: model.otherDetailInfoList, info: model.info)

        switch buttonType {
        case .yes:
            newModel.isYes = true
            if model.otherDetailInfoList.count > 0 {
                
                var index = -1
                for (i, formModel) in self.formlist.enumerated()
                {
                    if formModel.title.contains(model.name) {
                        index = i
                        break
                    }
                }
                if index == -1 {
                    let title = model.name + " " + labelResponse.getLiteralof(code: UserProfileLabelCode.details.rawValue).label_text
                    self.formlist.append(FormModel.init(title: title, isSecureTextEntry: false, isMandatory: true, text: model.info, popUpMessage: "Please Enter " + title, image: "", placeholder:""))
                }
              }
            
            break
        case .no:
            newModel.isNo = true
            if model.otherDetailInfoList.count > 0 {
                var index = -1
                for (i, formModel) in self.formlist.enumerated()
                {
                    if formModel.title.contains(model.name) {
                        index = i
                        break
                    }
                }
                if index != -1 {
                    self.formlist.remove(at: index)
                }
            }
            break
        case .dontKnow:
            newModel.isDontKnow = true
            if model.otherDetailInfoList.count > 0 {
                var index = -1
                for (i, formModel) in self.formlist.enumerated()
                {
                    if formModel.title.contains(model.name) {
                        index = i
                        break
                    }
                }
                if index != -1 {
                    self.formlist.remove(at: index)
                }
            }
            break
        case .questionMark:
                if let del = self.delegate {
                     del.didClickOnQuestionMark(sender: sender, optionModel: model)
                }
            return
        }
        self.optionList.remove(at: index)
        self.optionList.insert(newModel, at:index)
        DispatchQueue.main.async {
            self.issuesListTableView.reloadData()
        }
        if let del = self.delegate {
            del.didUpdateListOf(type: self.profileStageType, updatedList: self.optionList, formlist: self.formlist)
        }
    }
}


extension ProfileIssueCell: UserInfoCellDelegate {
    func didClickOnOtherDetail(sender: UIButton, formModel: FormModel) {
        if let del = self.delegate {
            del.didClickOnOtherDetail(sender: sender, formModel: formModel)
        }
    }
    func didClickOnPriority(sender:UIButton,formModel:FormModel) {
        if let del = self.delegate {
            del.didClickOnPriority(sender: sender, formModel: formModel)
        }
    }
}
