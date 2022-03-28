//
//  LoginViewController.swift
//  Autism
//
//  Created by IMPUTE on 31/01/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var formTableView: UITableView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var screenDescriptionLabel: UILabel!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var alreadyMemberLbl: UILabel!
    @IBOutlet weak var loginLbl: UILabel!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var orLbl: UILabel!
    @IBOutlet weak var signupWithLbl: UILabel!
    @IBOutlet weak var lblterms: UILabel!

    private var list = [FormModel]()
    private var socialNetworkManager: SocialNetworkManager = SocialNetworkManager()
    private var signUpViewModel = SignUpViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.customSetting()
        self.signUpViewModel.fetchSignUpScreenLabels()
    }
    
    @IBAction func gmailClicked(_ sender: Any) {
       self.socialNetworkManager.handleSocialLogin(of: .gmail, delegate: self)
    }
    
    @IBAction func facebookClicked(_ sender: Any) {
        self.socialNetworkManager.handleSocialLogin(of: .facebook, delegate: self)
    }
    
    @IBAction func alreadyMemberClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
  
    @IBAction func signUpClicked(_ sender: Any) {
        self.signUpViewModel.checkAllValidationAndCreateUser(list: self.list)
    }
    
    private func setData() {
        DispatchQueue.main.async {
            self.whiteBackgroundView.isHidden = false
        }
    }
}

// MARK: UITableview Delegates And Datasource Methods
extension SignUpViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.formTableView.frame.size.height / CGFloat(self.list.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier) as! UserInfoCell
        cell.setData(model: self.list[indexPath.row], delegate: self, labelResponse: self.signUpViewModel.labelsResponseVO!)
        cell.popOverButton.isHidden = true
        cell.popOverTransparentButton.isHidden = true
        cell.forgotButtonWidth.constant = 0
        return cell
    }
}

//MARK:- Private Methods
extension SignUpViewController {
    private func listenModelClosures() {
        
        self.signUpViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
        
        self.signUpViewModel.dataClosure = {
                  DispatchQueue.main.async {
                       if let response = self.signUpViewModel.signupResponseVO {
                       // self.resetForm()
                       // self.formTableView.reloadData()
                        if let lableRes = self.signUpViewModel.labelsResponseVO {
                        Utility.showAlert(title: lableRes.getLiteralof(code: SignUpLabelCode.information.rawValue).label_text, message: response.message)
                        }
                        if response.success {
                            self.navigationController?.popViewController(animated: true)
                        }
                       }
                  }
        }
        
        self.signUpViewModel.labelsClosure = {
                DispatchQueue.main.async {
                        if let response = self.signUpViewModel.labelsResponseVO {
                            self.setLabels(labelresponse: response)
                            self.formTableView.reloadData()
                            self.setData()
                        }
                }
        }
    }
    
    private func customSetting() {
        formTableView.register(UserInfoCell.nib, forCellReuseIdentifier: UserInfoCell.identifier)
        Utility.setView(view: self.signUpButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        formTableView.tableFooterView = UIView.init()
        Utility.setView(view: self.whiteBackgroundView, cornerRadius: 15, borderWidth: 0, color: .clear)
         Utility.setView(view: self.googleButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.facebookButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        
    }
    
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        self.resetForm()
        signUpButton.setTitle(labelresponse.getLiteralof(code: SignUpLabelCode.signup.rawValue).label_text, for: .normal)
        screenTitleLabel.text = labelresponse.getLiteralof(code: SignUpLabelCode.hello.rawValue).label_text
        screenDescriptionLabel.text = labelresponse.getLiteralof(code: SignUpLabelCode.register_with_us.rawValue).label_text
        alreadyMemberLbl.text = labelresponse.getLiteralof(code: SignUpLabelCode.already_member.rawValue).label_text
        loginLbl.text = labelresponse.getLiteralof(code: SignUpLabelCode.login.rawValue).label_text
        lblterms.text = labelresponse.getLiteralof(code: SignUpLabelCode.terms_condtion_agree_txt.rawValue).label_text.replacingOccurrences(of: "\\n", with: "\n")
        orLbl.text = labelresponse.getLiteralof(code: SignUpLabelCode.Or.rawValue).label_text
        signupWithLbl.text = labelresponse.getLiteralof(code: SignUpLabelCode.signup_with.rawValue).label_text
    }
    
    private func resetForm() {
        if let response = self.signUpViewModel.labelsResponseVO {
        self.list = [
            FormModel.init(title: response.getLiteralof(code: SignUpLabelCode.name.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: SignUpLabelCode.name.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_enter_your_name.rawValue).label_text),
                  
            FormModel.init(title: response.getLiteralof(code: SignUpLabelCode.email.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: SignUpLabelCode.email.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_email.rawValue).label_text),
            
            FormModel.init(title: response.getLiteralof(code: SignUpLabelCode.password.rawValue).label_text, isSecureTextEntry: true, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: SignUpLabelCode.password.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_password.rawValue).label_text),
                   
            FormModel.init(title: response.getLiteralof(code: SignUpLabelCode.confirm_password.rawValue).label_text, isSecureTextEntry: true, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: SignUpLabelCode.confirm_password.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_confirm_pass.rawValue).label_text)
               ]
        }
    }
}


extension SignUpViewController: UserInfoCellDelegate {
    func didTextFieldValueChange(formModel:FormModel)
    {
        var index = -1
        for (i, model) in self.list.enumerated()
        {
            if model.title == formModel.title {
                index = i
                break
            }
        }
        if index != -1 {
            self.list.remove(at: index)
            self.list.insert(formModel, at:index)
        }
    }
}


// MARK: SocialNetworkManagerDelegate Methods
extension SignUpViewController: SocialNetworkManagerDelegate {
    func socialNetworkLogin(_ isSuccess: Bool, profile: SocialNetworkProfileModel?, error: Error?)
    {
        if isSuccess {
            if let data = profile {
                if let response = self.signUpViewModel.labelsResponseVO {
                    
                self.list.removeAll()
                self.list = [
                    FormModel.init(title: response.getLiteralof(code: SignUpLabelCode.name.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: data.name, popUpMessage: response.getLiteralof(code: SignUpLabelCode.name.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_enter_your_name.rawValue).label_text),
                    FormModel.init(title: response.getLiteralof(code: SignUpLabelCode.email.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: data.email, popUpMessage: response.getLiteralof(code: SignUpLabelCode.email.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_email.rawValue).label_text),
                    FormModel.init(title:response.getLiteralof(code: SignUpLabelCode.password.rawValue).label_text, isSecureTextEntry: true, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: SignUpLabelCode.password.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_password.rawValue).label_text),
                    FormModel.init(title: response.getLiteralof(code: SignUpLabelCode.confirm_password.rawValue).label_text, isSecureTextEntry: true, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: SignUpLabelCode.confirm_password.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: SignUpLabelCode.hint_confirm_pass.rawValue).label_text)
                ]
                self.formTableView.reloadData()
                    
                }
            }
        }
    }
}

extension SignUpViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        self.signUpViewModel.fetchSignUpScreenLabels()
    }
}

extension SignUpViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setData()
        }
    }
}
