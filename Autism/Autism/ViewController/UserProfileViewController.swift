//
//  UserProfileViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/17.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

public extension Int {
   var asWord: String {
    let numberValue = NSNumber(value: self)
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    return formatter.string(from: numberValue)!
  }
}



enum PopOverContentType: String {
    case datePicker = "DatePicker"
    case country = "country"
    case state = "state"
    case otherDetails = "otherDetails"
    case reinforcer = "reinforcer"
    case description = "description"
    case none = "none"
}

class UserProfileViewController: UIViewController {
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var subStageMenuTableView: UITableView!
    @IBOutlet weak var profileSubStagesView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var subStageMenuView: UIView!
    @IBOutlet weak var profileSubStagesCollectionView: UICollectionView!
    @IBOutlet weak var basicProfilenextButton: UIButton!
    @IBOutlet weak var menuBackButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var assesmentBG: UIImageView!

    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var helpUsTextView: UITextView!

    private var basicInfolist = [FormModel]()
    private var popOverContentType : PopOverContentType = .none
    
    private let datePickerController = Utility.getViewController(ofType: DatePickerViewController.self)
   
    private var popOverContentController = UIViewController()
    private var userprofileViewModel = UserProfileViewModel()
    
    private var otherDetailsList = [OptionModel]()
    private var othterDetailFormlist = [FormModel]()

    private var reinforcerFormlist = [FormModel]()
    private var userProfileStageType : UserProfileStageType = .basicInfo
    let array:[UserProfileStageType] = [.ready,.sensoryIssue,.challengingBehaviour,.otherDetails,.reinforcers]

    var isNavigatedtoPF:Bool = false
    var isEditProfile:Bool = false
    private var currentIndex = 0 {
        
        didSet{
            DispatchQueue.main.async {
                self.userProfileStageType = self.array[self.currentIndex]
                self.scrollCollectionViewSubStageTo(index: self.currentIndex)
                self.subStageMenuTableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Utility.sharedInstance.loadCountriesList()
        self.listenModelClosures()
        self.customSetting()
        self.userprofileViewModel.fetchProfileScreenLabels(isEditProfile: self.isEditProfile)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
   
    @IBAction func menuBackClicked(_ sender: Any){
        self.hideSubStageProfileView()
    }
    
    @IBAction func basicProfileNextClicked(_ sender: Any) {
        self.handleUserBasicInfoNext()
    }
    
    private func scrollCollectionViewSubStageTo(index:Int) {
        self.profileSubStagesCollectionView.scrollToItem(at:IndexPath(item: index, section: 0), at: .centeredVertically, animated: true)
    }
    
    private func handleUserBasicInfoNext() {
        var isAnythingMissing = false
        for model in basicInfolist {
             if model.isMandatory && model.text.count == 0 {
                 isAnythingMissing = true
                if let response = self.userprofileViewModel.labelsResponseVO {
                    Utility.showAlert(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: model.popUpMessage)
                }
                 break
             }
            if let response = self.userprofileViewModel.labelsResponseVO {
                if model.title == response.getLiteralof(code: UserProfileLabelCode.nickname.rawValue).label_text {
                    if model.text.count < Int(AppConstant.minCharacterLimit.rawValue)! || model.text.count > Int(AppConstant.maxCharacterLimitForNickname.rawValue)!  {
                        isAnythingMissing = true
                        Utility.showAlert(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: UserProfileLabelCode.nickNameValidation.rawValue).label_text)
                    }
                }
                
                if model.title == response.getLiteralof(code: UserProfileLabelCode.guardian_name.rawValue).label_text {
                                   if model.text.count < Int(AppConstant.minCharacterLimit.rawValue)! || model.text.count > Int(AppConstant.maxCharacterLimitForGuardianName.rawValue)!  {
                                       isAnythingMissing = true
                                       Utility.showAlert(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: UserProfileLabelCode.guardianNameValidation.rawValue).label_text)
                                   }
                }
                
                if model.title == response.getLiteralof(code: UserProfileLabelCode.parent_contact_number.rawValue).label_text {
                    if !model.text.isValidPhone() {
                        isAnythingMissing = true
                        Utility.showAlert(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: model.popUpMessage)
                        break
                    }
                }
            }
        }
        if !isAnythingMissing {
            self.showSubStageProfileView()
        }
    }
    
    private func showSubStageProfileView() {
                   UIView.animate(withDuration: 1.5, animations: {
                       self.profileSubStagesView.alpha = 1
                   }) { (finish) in
                       self.userProfileStageType = .ready
                   }
    }
    
    private func hideSubStageProfileView() {
        UIView.animate(withDuration: 1.5, animations: {
            self.profileSubStagesView.alpha = 0
        }) { (finish) in
            self.userProfileStageType = .basicInfo
            self.currentIndex = 0
           // self.scrollCollectionViewSubStageTo(index: 0)
        }
    }
    
}

// MARK: UITableview Delegates And Datasource Methods
extension UserProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == subStageMenuTableView {
            if let _ = self.userprofileViewModel.labelsResponseVO {
                return 5
            }
            return 0
        }
        return self.basicInfolist.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == subStageMenuTableView {
            return 60
        }
        return self.profileTableView.frame.size.height / CGFloat(self.basicInfolist.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.subStageMenuTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileSubStageMenuCell.identifier) as! UserProfileSubStageMenuCell
            cell.selectionStyle = .none
            let labelCode = (indexPath.row + 1).asWord
            let text = self.userprofileViewModel.labelsResponseVO!.getLiteralof(code: labelCode).label_text
            cell.indexButton.setTitle(text, for: .normal)
            if indexPath.row == self.currentIndex {
                cell.indexButton.isSelected = true
            } else {
                cell.indexButton.isSelected = false
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier) as! UserInfoCell
        let model = self.basicInfolist[indexPath.row]
        cell.setData(model: model, delegate: self, labelResponse: self.userprofileViewModel.labelsResponseVO!)
        cell.titleLabel.textColor = UIColor.init(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1)
        cell.dataTextField?.textColor = .black
        
        if let res = self.userprofileViewModel.labelsResponseVO {
            if model.title == res.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text {
                cell.popOverButton.isHidden = false
                cell.popOverTransparentButton.isHidden = false
                cell.dataTextField.isUserInteractionEnabled = false
                cell.popOverButton.setBackgroundImage(UIImage.init(named: "calender"), for: .normal)
            } else if model.title == res.getLiteralof(code: UserProfileLabelCode.country.rawValue).label_text ||  model.title == res.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text {
                cell.popOverButton.isHidden = false
                cell.popOverTransparentButton.isHidden = false
                cell.dataTextField.isUserInteractionEnabled = false
                cell.popOverButton.setBackgroundImage(UIImage.init(named: "downarrow"), for: .normal)
            } else {
                cell.popOverButton.isHidden = true
                cell.popOverTransparentButton.isHidden = true
                cell.dataTextField.isUserInteractionEnabled = true
                cell.forgotButtonWidth.constant = 0
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.subStageMenuTableView {
            self.currentIndex = indexPath.row
        }
    }
}

extension UserProfileViewController: UserInfoCellDelegate {
    func didTextFieldValueChange(formModel:FormModel)
    {
        var index = -1
        for (i, model) in self.basicInfolist.enumerated()
        {
            if model.title == formModel.title {
                index = i
                break
            }
        }
        if index != -1 {
            self.basicInfolist.remove(at: index)
            self.basicInfolist.insert(formModel, at:index)
        }
    }
    
    func didClickOnCalender(sender: UIButton) {
        self.view.endEditing(true)
        if let labelResponse = self.userprofileViewModel.labelsResponseVO {
        STCalenderVC().presentCalenderView(delegate: self, minimum: -100, maximum: 0, selectedDate: nil, onSourceViewController: self,labelresponse: labelResponse)
        }
    }
    
    func didClickOnCountry(sender: UIButton) {
        self.view.endEditing(true)
        if let labelResponse = self.userprofileViewModel.labelsResponseVO {
        let vc = Utility.getViewController(ofType: PopOverContentViewController.self)
            vc.setLabels(lblResponse: labelResponse, delegate: self)
        vc.popOverContentType = .country
        self.popOverContentType = .country
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 348, height: 350)
        self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
        self.popOverContentController = vc
        }
    }
    
    func didClickOnState(sender: UIButton) {
        self.view.endEditing(true)
        if let response = self.userprofileViewModel.labelsResponseVO {
            var country = ""
        for model in basicInfolist {
            if model.isMandatory && model.title == response.getLiteralof(code: UserProfileLabelCode.country.rawValue).label_text {
                country = model.text
                break
            }
        }
            
            if country.count == 0 {
                        Utility.showAlert(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: UserProfileLabelCode.country.rawValue).error_text)
            } else {
            let vc = Utility.getViewController(ofType: PopOverContentViewController.self)
            vc.setLabels(lblResponse: response, delegate: self)
                let list = Utility.sharedInstance.countriesDictionary[country]
                vc.states = list ?? []
            vc.popOverContentType = .state
            self.popOverContentType = .state
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 348, height: 350)
            self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
            self.popOverContentController = vc
            }
        }
        
//        if let labelResponse = self.userprofileViewModel.labelsResponseVO {
//        let vc = Utility.getViewController(ofType: PopOverContentViewController.self)
//            vc.setLabels(lblResponse: labelResponse, delegate: self)
//        vc.popOverContentType = .country
//        self.popOverContentType = .country
//        vc.modalPresentationStyle = .popover
//        vc.preferredContentSize = CGSize(width: 348, height: 350)
//        self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
//        self.popOverContentController = vc
//        }
    }
}

//MARK:- Private Methods
extension UserProfileViewController {
    private func listenModelClosures() {

        self.userprofileViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
        self.userprofileViewModel.submitClosure = { (response) in
            DispatchQueue.main.async {
                if response.success {
                    
                    if !self.userprofileViewModel.isUserEditProfile() {
                    if  let type = ScreenRedirection.init(rawValue: response.screen_id){
                        
                        let vc = type.getViewController()
                        if(vc is ParentFeedbackViewController) {
                            if(self.isNavigatedtoPF == false) {
                                self.isNavigatedtoPF = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                            }
                        } else {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    if let labelresponse = self.userprofileViewModel.labelsResponseVO {
                        Utility.showAlert(title: labelresponse.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: response.message)
                    }
                }
            }
        }
        
        self.userprofileViewModel.labelsClosure = {
                DispatchQueue.main.async {
                    if(self.profileSubStagesView.alpha != 1) {
                        if let response = self.userprofileViewModel.labelsResponseVO {
                            self.setLabels(labelresponse: response)
                            self.profileTableView.reloadData()
                            self.subStageMenuTableView.reloadData()
                            self.setData()
                        }
                    }
                }
        }
        
        self.userprofileViewModel.dropdownClosure = {
            DispatchQueue.main.async {
                self.profileSubStagesCollectionView.reloadData()
            }
        }
        
        self.userprofileViewModel.editProfileDataClosure = { labelresponse,editUserProfile in
            DispatchQueue.main.async {
                self.basicInfolist.removeAll()
                self.basicInfolist = [
                    FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.nickname.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: Utility.deCrypt(text: editUserProfile.nickname), popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.nickname.rawValue).error_text, image: "", placeholder:  labelresponse.getLiteralof(code: UserProfileLabelCode.kid_name.rawValue).label_text),
                    
                    FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: Utility.deCrypt(text: editUserProfile.dob), popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.dob.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.dob_text.rawValue).label_text),
                           
                    FormModel.init(title:labelresponse.getLiteralof(code: UserProfileLabelCode.guardian_name.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: Utility.deCrypt(text: editUserProfile.guardian_name), popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.guardian_name.rawValue).error_text, image: "", placeholder:  labelresponse.getLiteralof(code: UserProfileLabelCode.guardian_text.rawValue).label_text),

                    FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.country.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: Utility.deCrypt(text: editUserProfile.country), popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.country.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.country_text.rawValue).label_text),
                    
                    FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: Utility.deCrypt(text: editUserProfile.state), popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.state.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text),
                           
                    FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.city.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: Utility.deCrypt(text: editUserProfile.city), popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.city.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.city_text.rawValue).label_text),
                           
                    FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.parent_contact_number.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text:Utility.deCrypt(text: editUserProfile.parent_contact_number), popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.parent_contact_number.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.parents_phonenumber.rawValue).label_text)
                       ]
                
                
                
                self.profileTableView.reloadData()
                self.profileSubStagesCollectionView.reloadData()
            }
        }
        
    }
    
    private func customSetting() {
        self.navigationController?.navigationBar.isHidden = true
        self.profileSubStagesCollectionView.delegate = self
        self.profileSubStagesCollectionView.dataSource = self
        profileSubStagesCollectionView.register(ProfileIssueCell.nib, forCellWithReuseIdentifier: ProfileIssueCell.identifier)
        profileSubStagesCollectionView.register(UserProfileReadyCell.nib, forCellWithReuseIdentifier: UserProfileReadyCell.identifier)
        profileTableView.register(UserInfoCell.nib, forCellReuseIdentifier: UserInfoCell.identifier)
        profileTableView.tableFooterView = UIView.init()
        
        subStageMenuTableView.register(UserProfileSubStageMenuCell.nib, forCellReuseIdentifier: UserProfileSubStageMenuCell.identifier)
        subStageMenuTableView.tableFooterView = UIView.init()
         
        Utility.setView(view: self.profileView, cornerRadius: 40, borderWidth: 0, color: .clear)
        Utility.setView(view: self.basicProfilenextButton, cornerRadius: 30, borderWidth: 0, color: .clear)
        Utility.setView(view: self.menuBackButton, cornerRadius: 20, borderWidth: 0, color: .clear)
    }
    
    func setData(){
        subStageMenuView.isHidden = false
        profileView.isHidden = false
        basicProfilenextButton.isHidden = false
        helpUsTextView.isHidden = false
        logo.isHidden = false
        assesmentBG.isHidden = false
    }
    
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        self.screenTitleLabel.text = labelresponse.getLiteralof(code: UserProfileLabelCode.user_profile.rawValue).label_text
        self.helpUsTextView.text = labelresponse.getLiteralof(code: UserProfileLabelCode.help_us.rawValue).label_text.replacingOccurrences(of: "\\n", with: "\n")
       // self.basicProfilenextButton.setTitle(labelresponse.getLiteralof(code: UserProfileLabelCode.next.rawValue).label_text, for: .normal)
       // self.menuBackButton.setTitle(labelresponse.getLiteralof(code: UserProfileLabelCode.back.rawValue).label_text, for: .normal)

        self.basicInfolist = [
            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.nickname.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.nickname.rawValue).error_text, image: "", placeholder:  labelresponse.getLiteralof(code: UserProfileLabelCode.kid_name.rawValue).label_text),
            
            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.dob.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.dob_text.rawValue).label_text),
                   
            FormModel.init(title:labelresponse.getLiteralof(code: UserProfileLabelCode.guardian_name.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.guardian_name.rawValue).error_text, image: "", placeholder:  labelresponse.getLiteralof(code: UserProfileLabelCode.guardian_text.rawValue).label_text),
                   

            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.country.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.country.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.country_text.rawValue).label_text),
            
            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.state.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text),
                   
            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.city.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.city.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.city_text.rawValue).label_text),
                   
            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.parent_contact_number.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.parent_contact_number.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: UserProfileLabelCode.parents_phonenumber.rawValue).label_text)
               ]
        
        reinforcerFormlist = [
            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_1.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_1.rawValue).error_text, image: "", placeholder: ""),
            FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_2.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_2.rawValue).error_text, image: "", placeholder: ""),
                   FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_3.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_3.rawValue).error_text, image: "", placeholder: ""),
                   FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_4.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage:labelresponse.getLiteralof(code: UserProfileLabelCode.priority_4.rawValue).error_text, image: "", placeholder: ""),
                   FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_5.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage:labelresponse.getLiteralof(code: UserProfileLabelCode.priority_5.rawValue).error_text, image: "", placeholder: ""),
                   FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_6.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_6.rawValue).error_text, image: "", placeholder: ""),
//                   FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_7.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_7.rawValue).error_text, image: "", placeholder: ""),
//                   FormModel.init(title: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_8.rawValue).label_text, isSecureTextEntry: false, isMandatory: false, text: "", popUpMessage: labelresponse.getLiteralof(code: UserProfileLabelCode.priority_8.rawValue).error_text, image: "", placeholder: "")
               ]
     }
    
    private func showPopOverView(sourceView:UIView, frame:CGRect,vc:UIViewController) {
         if let popoverPresentationController = vc.popoverPresentationController {
         popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = frame
         popoverPresentationController.delegate = self
         present(vc, animated: true, completion: nil)
         }
     }
     
    private func dissmissPopOverView() {
         switch self.popOverContentType {
         case .datePicker:
             datePickerController.dismiss(animated: true, completion: nil)
         case .country,.otherDetails,.reinforcer,.state:
            popOverContentController.dismiss(animated: true, completion: nil)
         default:
             break
         }
     }
    
    private func updateForm(updateModel:FormModel,title:String) {
        var index = -1
        for (i, model) in self.basicInfolist.enumerated()
        {
            if model.title == title {
                index = i
                break
            }
        }
        
        if index >= 0 {
            self.basicInfolist.remove(at: index)
            self.basicInfolist.insert(updateModel, at: index)
        }
        
        self.profileTableView.reloadData()
        self.dissmissPopOverView()
    }
    

    
}

extension UserProfileViewController: UIPopoverPresentationControllerDelegate {
    //UIPopoverPresentationControllerDelegate inherits from UIAdaptivePresentationControllerDelegate, we will use this method to define the presentation style for popover presentation controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
    }
     
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
     
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
    return true
    }
}

extension UserProfileViewController: DatePickerViewControllerDelegate {
    func donePressed(dateString:String) {
        if let res = self.userprofileViewModel.labelsResponseVO {
            let updatedModel = FormModel.init(title: res.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: dateString, popUpMessage: res.getLiteralof(code: UserProfileLabelCode.dob.rawValue).error_text, image: "", placeholder: "")
            self.updateForm(updateModel: updatedModel, title: res.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text)
        }
    }
    
    func cancelPressed() {
        self.dissmissPopOverView()
    }
  
    
}

extension UserProfileViewController: PopOverContentViewControllerDelegate {
    func didSelectState(state:String?) {
        if let res = self.userprofileViewModel.labelsResponseVO {
            if let s = state {
                let updateModel = FormModel.init(title: res.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: s, popUpMessage:res.getLiteralof(code: UserProfileLabelCode.state.rawValue).error_text, image: "", placeholder: "")
                self.updateForm(updateModel: updateModel, title:res.getLiteralof(code: UserProfileLabelCode.state.rawValue).label_text)
            } else {
                self.dissmissPopOverView()
            }

        }
    }

    func didSelectCountry(country:String?) {
        if let res = self.userprofileViewModel.labelsResponseVO {
            if let cm = country {
                let updateModel = FormModel.init(title: res.getLiteralof(code: UserProfileLabelCode.country.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: cm, popUpMessage:res.getLiteralof(code: UserProfileLabelCode.country.rawValue).error_text, image: "", placeholder: "")
                self.updateForm(updateModel: updateModel, title:res.getLiteralof(code: UserProfileLabelCode.country.rawValue).label_text)
            } else {
                self.dissmissPopOverView()
            }

        }
    }
    
    
    
    
    func didSelectMultipleDetailsOf(type:PopOverContentType,selectedList:[Int],formmodel:FormModel?) {
    self.dissmissPopOverView()

    switch type {
        case .reinforcer:
                print(selectedList)
                var index = -1
                for (i,model) in self.reinforcerFormlist.enumerated() {
                    if model.title == formmodel?.title {
                        index = i
                        break
                    }
                }

                if let m = formmodel {
                    var newModel = m
                    if selectedList.count > 0,let res = self.userprofileViewModel.dropDownListResponseVO {
                        newModel.text = res.reinforcerList[selectedList[0]].name
                        newModel.image = res.reinforcerList[selectedList[0]].image
                    }
                    let array = self.reinforcerFormlist.filter{$0.text == newModel.text}
                    if array.count == 0 {
                        self.reinforcerFormlist.remove(at: index)
                        self.reinforcerFormlist.insert(newModel, at: index)
                        self.userprofileViewModel.updateReinforcerFormList(formList: self.reinforcerFormlist)
                    } else {
                        DispatchQueue.main.async {
                            if let response = self.userprofileViewModel.labelsResponseVO {
                                let alert = UIAlertController(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: UserProfileLabelCode.already_added.rawValue).label_text, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title:response.getLiteralof(code: UserProfileLabelCode.ok.rawValue).label_text, style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
        break
    case .otherDetails:
        if let fModel = formmodel,let response = self.userprofileViewModel.dropDownListResponseVO {
            var model = fModel
            var index = -1
            for (i, itemModel) in response.otherDetail.enumerated() {
                if model.title.lowercased().contains(itemModel.name.lowercased()) {
                    index = i
                    break
                }
            }
            if index >= 0 {
                if selectedList.count == 1 {
                    let indexValue = selectedList[0]
                    model.text = response.otherDetail[index].otherDetailInfoList[indexValue].name
                } else {
                    var subArray = [OtherDetailInfo]()
                    for valueIndex in selectedList {
                        subArray.append(response.otherDetail[index].otherDetailInfoList[valueIndex])
                    }
                    var text = ""
                    for (index,model) in subArray.enumerated() {
                        if index < subArray.count - 1 {
                            text += model.name + ","
                        } else {
                            text += model.name
                        }
                    }
                    model.text = text
                }
            }
            index = -1
            for (i, itemModel) in self.othterDetailFormlist.enumerated() {
                if model.title.lowercased().contains(itemModel.title.lowercased()) {
                    index = i
                    break
                }
            }
            if index >= 0 {
                self.othterDetailFormlist.remove(at:index)
                self.othterDetailFormlist.insert(model, at: index)
            }
            self.userprofileViewModel.updateOtherSubDetailFormList(formList: self.othterDetailFormlist)
        }
        default:
        break
    }
        self.profileSubStagesCollectionView.reloadData()
    }
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.profileSubStagesCollectionView.frame.width, height: self.profileSubStagesCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = self.userprofileViewModel.labelsResponseVO {
            return 5
        }
        return 0
    }
    
    // make a cell for each cell index path
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileIssueCell.identifier, for: indexPath) as! ProfileIssueCell
        
        if let response =  self.userprofileViewModel.dropDownListResponseVO {
        
        if indexPath.row == 0 {
            let readyCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileReadyCell.identifier, for: indexPath) as! UserProfileReadyCell
            readyCell.setData(labelsResponseVO: self.userprofileViewModel.labelsResponseVO!, delegate: self)
            return readyCell
        } else if indexPath.row == 1 {
            cell.setData(optionList: response.sensoryIssueList, stageType: .sensoryIssue, list: [], delegate: self, labelResponse: self.userprofileViewModel.labelsResponseVO!)
        } else if indexPath.row == 2 {
            cell.setData(optionList: response.challengingBehaviourList, stageType: .challengingBehaviour, list: [], delegate: self, labelResponse: self.userprofileViewModel.labelsResponseVO!)
        } else if indexPath.row == 3 {
            cell.setData(optionList: response.otherDetail, stageType: .otherDetails, list: othterDetailFormlist, delegate: self, labelResponse: self.userprofileViewModel.labelsResponseVO!)
        }
        else if indexPath.row == 4 {
            cell.setData(optionList: [], stageType: .reinforcers, list: reinforcerFormlist, delegate: self, labelResponse: self.userprofileViewModel.labelsResponseVO!)
        }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}


extension UserProfileViewController: ProfileIssueCellDelegate {
    func didClickOnNext() {
        switch self.userProfileStageType {
            case .sensoryIssue:
                self.userProfileStageType = .challengingBehaviour
                self.currentIndex = 2
               // self.scrollCollectionViewSubStageTo(index: 2)
            case .challengingBehaviour:
                self.userProfileStageType = .otherDetails
                self.currentIndex = 3
               // self.scrollCollectionViewSubStageTo(index: 3)
            case .otherDetails:
                self.userProfileStageType = .reinforcers
                self.currentIndex = 4
            case .reinforcers:
                var valueCount = 0
                for model in self.reinforcerFormlist {
                    if model.text.count > 0 {
                        valueCount = valueCount + 1
                    }
                }
                
                if valueCount >= userProfileReinforcerLimit {
                    self.userprofileViewModel.submitUserProfile(basicinfo: self.basicInfolist)
                } else {
                    if let response = self.userprofileViewModel.labelsResponseVO {
                        Utility.showAlert(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: UserProfileLabelCode.priority_1.rawValue).error_text)
                    }
                }
            default:
                break
            }
    }
    
    func didClickOnQuestionMark(sender: UIButton, optionModel: OptionModel) {
        let vc = Utility.getViewController(ofType: OptionDescriptionViewController.self)
                          self.popOverContentType = .description
        vc.info = optionModel.info
        
        let popOverWidth:CGFloat = 348
        
        let sizeText = Utility.getSize(optionModel.info, font: UIFont(name:AppFont.helveticaNeue.rawValue,size:16)!, boundingSize: CGSize(width: popOverWidth, height: 20000.0))
        
        //let sizeText = Utility.getSize(optionModel.description, font: UIFont(name:AppFont.robotoRegular.rawValue,size:16)!, boundingSize: CGSize(width: popOverWidth, height: 20000.0))
                         vc.modalPresentationStyle = .popover
                    //      vc.preferredContentSize = CGSize(width: 348, height: 350)
        vc.preferredContentSize = CGSize(width: popOverWidth, height: sizeText.height+20)

                          self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
                          self.popOverContentController = vc
        
    }
    
    func didUpdateListOf(type:UserProfileStageType,updatedList:[OptionModel],formlist:[FormModel]) {
        switch type {
        case .sensoryIssue:
            self.userprofileViewModel.updateSensoryIssueList(list: updatedList)
        case .challengingBehaviour:
            self.userprofileViewModel.updateChallengingBehaviourList(list: updatedList)
        case .otherDetails:
            self.othterDetailFormlist.removeAll()
            self.othterDetailFormlist = formlist
            self.userprofileViewModel.updateOtherDetailsList(list: updatedList)
            break
        default:
            break
        }
    }
    
    func didClickOnOtherDetail(sender: UIButton, formModel: FormModel) {
        if let res = self.userprofileViewModel.dropDownListResponseVO {
            var index = -1
            
            for (i, model) in res.otherDetail.enumerated()
            {
                 if formModel.title.lowercased().contains(model.name.lowercased()) {
                    index = i
                    break
                }
            }
            
            if index >= 0 {
                let vc = Utility.getViewController(ofType: PopOverContentViewController.self)
                self.popOverContentType = .otherDetails
                if let res = self.userprofileViewModel.dropDownListResponseVO , let labelResponse = self.userprofileViewModel.labelsResponseVO{
                    vc.dropDownList = res.otherDetail[index].otherDetailInfoList
                    vc.formModel = formModel
                    vc.setLabels(lblResponse: labelResponse, delegate: self)
                    vc.popOverContentType = .otherDetails
                }
                vc.modalPresentationStyle = .popover
                vc.preferredContentSize = CGSize(width: 348, height: 350)
                self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
                self.popOverContentController = vc
            }
        }
    }


    func didClickOnPriority(sender:UIButton,formModel:FormModel) {
        let vc = Utility.getViewController(ofType: PopOverContentViewController.self)
        self.popOverContentType = .reinforcer

        if let res = self.userprofileViewModel.dropDownListResponseVO, let labelResponse = self.userprofileViewModel.labelsResponseVO {
                        vc.reinforcerList = res.reinforcerList
                        vc.formModel = formModel
                        vc.setLabels(lblResponse: labelResponse, delegate: self)
                        vc.popOverContentType = .reinforcer
                    }
                    vc.modalPresentationStyle = .popover
                    vc.preferredContentSize = CGSize(width: 348, height: 350)
                    self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
                    self.popOverContentController = vc
    }
    
    
}

extension UserProfileViewController: UserProfileReadyCellDelegate {
    func didClickOnReady() {
         self.userProfileStageType = .sensoryIssue
        self.currentIndex = 1
    }
}

extension UserProfileViewController : STCalenderVCDelegate {
    
    func selectedCalendar(dateStr: String, date: Date) {
       // if self.dateDifference(selectedDate: date) >= 3 {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let dateString = df.string(from:date)
            if let res = self.userprofileViewModel.labelsResponseVO {
                  let updatedModel = FormModel.init(title: res.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: dateString, popUpMessage: res.getLiteralof(code: UserProfileLabelCode.dob.rawValue).error_text, image: "", placeholder: "")
                  self.updateForm(updateModel: updatedModel, title: res.getLiteralof(code: UserProfileLabelCode.dob.rawValue).label_text)
            }
//        } else {
//            if let response = self.userprofileViewModel.labelsResponseVO {
//                Utility.showAlert(title: response.getLiteralof(code: UserProfileLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: UserProfileLabelCode.dobValidation.rawValue).label_text)
//            }
//        }
    }
    
    private func dateDifference(selectedDate: Date) -> Int {
        let year = Calendar.current.dateComponents([.year], from: selectedDate, to: Date()).year
        return year ?? 0
    }
}
extension UserProfileViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        self.userprofileViewModel.fetchProfileScreenLabels(isEditProfile: self.isEditProfile)
    }
}

extension UserProfileViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setData()
        }
    }
}
