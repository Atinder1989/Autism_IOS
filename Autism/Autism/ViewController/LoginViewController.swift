//
//  LoginViewController.swift
//  Autism
//
//  Created by IMPUTE on 31/01/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var formTableView: UITableView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var screenTitleLbl: UILabel!
    @IBOutlet weak var pleaseLogLbl: UILabel!
    @IBOutlet weak var notRegisteredUserLbl: UILabel!
    @IBOutlet weak var signUpLbl: UILabel!
    @IBOutlet weak var orLbl: UILabel!
    @IBOutlet weak var loginWithLbl: UILabel!
    @IBOutlet weak var languageImageView: UIImageView!
    @IBOutlet weak var languageName: UILabel!

    private var list = [FormModel]()
    private var socialNetworkManager: SocialNetworkManager = SocialNetworkManager()
    private var loginViewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.loginViewModel.fetchLoginScreenLabels()
        self.customSetting()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  Utility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
   
    
    @IBAction func loginClicked(_ sender: Any) {
        self.loginViewModel.checkAllValidationBeforeLogin(list: self.list)
    }
    
    @IBAction func facebookClicked(_ sender: Any) {
        self.socialNetworkManager.handleSocialLogin(of: .facebook, delegate: self)
    }
    
    @IBAction func gmailClicked(_ sender: Any) {
        self.socialNetworkManager.handleSocialLogin(of: .gmail, delegate: self)
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        let vc = Utility.getViewController(ofType: SignUpViewController.self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setData() {
        DispatchQueue.main.async {
            self.whiteBackgroundView.isHidden = false
        }
    }
}

// MARK: UITableview Delegates And Datasource Methods
extension LoginViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.formTableView.frame.size.height / 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier) as! UserInfoCell
        cell.setData(model: self.list[indexPath.row], delegate: self, labelResponse: self.loginViewModel.labelsResponseVO!)
            cell.forgotButton.isHidden = true
            cell.forgotButtonWidth.constant = 0
        if indexPath.row == 1 {
            cell.forgotButton.isHidden = false
            cell.forgotButtonWidth.constant = 43
        }
        return cell
    }
}

//MARK:- Private Methods
extension LoginViewController {
    private func listenModelClosures() {
        
        self.loginViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
           self.loginViewModel.dataClosure = {
                     DispatchQueue.main.async {
                        
                        if let response = self.loginViewModel.loginResponseVO {
                            if response.success {
                                if let user = response.userVO {
                                    
                                    
                if  let type = ScreenRedirection.init(rawValue: user.screen_id) {
                      let vc = type.getViewController()
                    
                                        self.navigationController?.pushViewController(vc, animated: true)
                                   }
                                }
                            } else {
                                if let lableRes = self.loginViewModel.labelsResponseVO {
                                Utility.showAlert(title: lableRes.getLiteralof(code: LoginLabelCode.information.rawValue).label_text, message: response.message)
                                }
                            }
                        }
                     }
            }
        
        self.loginViewModel.labelsClosure = {
                DispatchQueue.main.async {
                        if let response = self.loginViewModel.labelsResponseVO {
                            self.setLabels(labelresponse: response)
                            self.formTableView.reloadData()
                            self.setData()
                        }
                }
        }
    }
    
    private func customSetting() {
        formTableView.register(UserInfoCell.nib, forCellReuseIdentifier: UserInfoCell.identifier)
        Utility.setView(view: self.loginButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        formTableView.tableFooterView = UIView.init()
        Utility.setView(view: self.whiteBackgroundView, cornerRadius: 15, borderWidth: 0, color: .clear)
        Utility.setView(view: self.googleButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.facebookButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        self.languageName.text = selectedLanguageModel.name
        self.languageImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + selectedLanguageModel.image)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeLanguage(_:)))
        self.languageView.addGestureRecognizer(tap)
    }
    
    @objc private func changeLanguage(_ sender: UITapGestureRecognizer? = nil) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        self.list = [
            FormModel.init(title: labelresponse.getLiteralof(code: LoginLabelCode.email.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: LoginLabelCode.email.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: LoginLabelCode.hint_email.rawValue).label_text ),
            FormModel.init(title: labelresponse.getLiteralof(code: LoginLabelCode.password.rawValue).label_text, isSecureTextEntry: true, isMandatory: true, text: "", popUpMessage: labelresponse.getLiteralof(code: LoginLabelCode.password.rawValue).error_text, image: "", placeholder: labelresponse.getLiteralof(code: LoginLabelCode.hint_password.rawValue).label_text)
        ]
        
        loginButton.setTitle(labelresponse.getLiteralof(code: LoginLabelCode.login.rawValue).label_text, for: .normal)
        self.screenTitleLbl.text = labelresponse.getLiteralof(code: LoginLabelCode.hello.rawValue).label_text
        self.pleaseLogLbl.text = labelresponse.getLiteralof(code: LoginLabelCode.please_login_to_yr_cc.rawValue).label_text
        self.notRegisteredUserLbl.text = labelresponse.getLiteralof(code: LoginLabelCode.new_user_signup.rawValue).label_text
        self.signUpLbl.text = labelresponse.getLiteralof(code: LoginLabelCode.signup.rawValue).label_text
        self.orLbl.text = labelresponse.getLiteralof(code: LoginLabelCode.Or.rawValue).label_text
        self.loginWithLbl.text = labelresponse.getLiteralof(code: LoginLabelCode.Login_with.rawValue).label_text
    }
    
    private func isAnyMandatoryFieldEmpty() -> (isEmpty:Bool,index:Int) {
        var index = -1
        for (i, model) in self.list.enumerated()
        {
            if model.isMandatory && model.text.count == 0 {
                index = i
                break
            }
        }
        return index == -1 ? (false,index) : (true,index)
    }
}

// MARK: UserInfo Cell Delegate

extension LoginViewController: UserInfoCellDelegate {
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
    func didClickOnForgot() {
        DispatchQueue.main.async {
            let vc = Utility.getViewController(ofType: ForgotPasswordViewController.self)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: SocialNetworkManagerDelegate Methods
extension LoginViewController: SocialNetworkManagerDelegate {
    func socialNetworkLogin(_ isSuccess: Bool, profile: SocialNetworkProfileModel?, error: Error?)
    {
        if isSuccess {
            if let data = profile {
            self.list.removeAll()
            if let response = self.loginViewModel.labelsResponseVO {
                    self.list = [
                        FormModel.init(title: response.getLiteralof(code: LoginLabelCode.email.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: data.email, popUpMessage: response.getLiteralof(code: LoginLabelCode.email.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: LoginLabelCode.hint_email.rawValue).label_text),
                        FormModel.init(title: response.getLiteralof(code: LoginLabelCode.password.rawValue).label_text, isSecureTextEntry: true, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: LoginLabelCode.password.rawValue).error_text, image: "", placeholder:response.getLiteralof(code: LoginLabelCode.hint_password.rawValue).label_text)
                    ]
                    self.formTableView.reloadData()
                }
            }
        }
    }
}

extension LoginViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        self.loginViewModel.fetchLoginScreenLabels()
    }
}

extension LoginViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setData()
        }
    }
}
