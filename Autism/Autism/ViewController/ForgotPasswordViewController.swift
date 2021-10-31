//
//  ForgotPasswordViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/23.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var formTableView: UITableView!
    @IBOutlet weak var sendLinkButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var desriptionTitleLabel: UILabel!

    private var forgotViewModel = ForgotPasswordViewModel()
    private var list = [FormModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.customSetting()
        self.forgotViewModel.fetchforgotScreenLabels()
    }
    @IBAction func sendLinkClicked(_ sender: Any) {
        
        if let lableRes = self.forgotViewModel
            .labelsResponseVO {
        if list[0].text.count > 0 {
            if !list[0].text.isValidEmail() {
                Utility.showAlert(title: lableRes.getLiteralof(code: ForgotPasswordLabelCode.information.rawValue).label_text, message: list[0].popUpMessage)
            } else {
                self.forgotViewModel.sendLinkToUser(list: self.list)
        }
        } else {
            Utility.showAlert(title: lableRes.getLiteralof(code: ForgotPasswordLabelCode.information.rawValue).label_text, message: list[0].popUpMessage)
        }
            
        }
    }
    
    @IBAction func backClicked(_ sender: Any) {
       self.navigationController?.popViewController(animated: true)
    }
    
    func setData()
    {
        DispatchQueue.main.async {
            self.whiteBackgroundView.isHidden = false
        }
    }
}

// MARK: UITableview Delegates And Datasource Methods
extension ForgotPasswordViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.formTableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier) as! UserInfoCell
        if let labelResponseVo = self.forgotViewModel.labelsResponseVO {
            cell.setData(model: self.list[indexPath.row], delegate: self, labelResponse: labelResponseVo)
        }
        cell.popOverButton.isHidden = true
        cell.popOverTransparentButton.isHidden = true
        cell.forgotButtonWidth.constant = 0
        return cell
    }
}

extension ForgotPasswordViewController {
    private func customSetting() {
        formTableView.register(UserInfoCell.nib, forCellReuseIdentifier: UserInfoCell.identifier)
        Utility.setView(view: self.sendLinkButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.whiteBackgroundView, cornerRadius: 15, borderWidth: 0, color: .clear)
        formTableView.tableFooterView = UIView.init()
    }
      private func listenModelClosures() {
        
        self.forgotViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
          self.forgotViewModel.dataClosure = {
                DispatchQueue.main.async {
                    if let response = self.forgotViewModel.forgotResponseVO,let labelResponseVo = self.forgotViewModel.labelsResponseVO {
                            Utility.showAlert(title: labelResponseVo.getLiteralof(code: ForgotPasswordLabelCode.information.rawValue).label_text, message: response.message)
                            if response.success {
                            self.navigationController?.popViewController(animated: true)
                            }
                        }
                }
          }
          
          self.forgotViewModel.labelsClosure = {
                  DispatchQueue.main.async {
                          if let response = self.forgotViewModel.labelsResponseVO {
                              self.setLabels(labelresponse: response)
                              self.formTableView.reloadData()
                            self.setData()
                          }
                  }
          }
      }
    
     private func setLabels(labelresponse:ScreenLabelResponseVO) {
           self.resetForm()
        self.screenTitleLabel.text = labelresponse.getLiteralof(code: ForgotPasswordLabelCode.forgot_your_pass.rawValue).label_text
        self.desriptionTitleLabel.text = labelresponse.getLiteralof(code: ForgotPasswordLabelCode.will_help_your.rawValue).label_text
        sendLinkButton.setTitle(labelresponse.getLiteralof(code: ForgotPasswordLabelCode.send_link.rawValue).label_text, for: .normal)
        backButton.setTitle(labelresponse.getLiteralof(code: ForgotPasswordLabelCode.back.rawValue).label_text, for: .normal)
       }
       
       private func resetForm() {
           if let response = self.forgotViewModel.labelsResponseVO {
            self.list = [
                FormModel.init(title: response.getLiteralof(code: ForgotPasswordLabelCode.email.rawValue).label_text, isSecureTextEntry: false, isMandatory: true, text: "", popUpMessage: response.getLiteralof(code: ForgotPasswordLabelCode.email.rawValue).error_text, image: "", placeholder: response.getLiteralof(code: ForgotPasswordLabelCode.hint_email.rawValue).label_text)
              ]
          }
       }
}

extension ForgotPasswordViewController: UserInfoCellDelegate {
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

extension ForgotPasswordViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        self.forgotViewModel.fetchforgotScreenLabels()
    }
}

extension ForgotPasswordViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setData()
        }
    }
}
