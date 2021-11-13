//
//  MenuListViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/03/30.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol MenulistViewDelegate {
    func didClickOnBackground()
    func didClickOnMenuItem(item:MenuItem)

}

class MenuListViewController: UIViewController {
    @IBOutlet weak var menuDrawerView: UIView!
    @IBOutlet weak var backGroundButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var menuListTableView: UITableView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernamLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!

    private var menuListItems = [MenuItem]()
    private var delegate: MenulistViewDelegate?
    private var labelResponse: ScreenLabelResponseVO!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
    }
    
    @IBAction func backGroundButtonClicked(_ sender: Any) {
        if let del = self.delegate {
            del.didClickOnBackground()
        }
    }
    @IBAction func logoutButtonClicked(_ sender: Any) {
           if let del = self.delegate {
             del.didClickOnMenuItem(item: .logout)
           }
    }
}

// MARK: UITableview Delegates And Datasource Methods
extension MenuListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuListItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuListCell.identifier) as! MenuListCell
        cell.selectionStyle = .none
        cell.setData(item: self.menuListItems[indexPath.row], labelResponse: self.labelResponse)

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let del = self.delegate {
                del.didClickOnMenuItem(item: self.menuListItems[indexPath.row])
        }
    }
}
// MARK: Public Methods
extension MenuListViewController {
    func setDelegate(delegate:MenulistViewDelegate, labelResponse:ScreenLabelResponseVO) {
        self.delegate = delegate
        self.labelResponse = labelResponse
        DispatchQueue.main.async {
            self.menuListTableView.reloadData()
        }
    }
    
}

// MARK: Private Methods
extension MenuListViewController {
    private func customSetting(){
        Utility.setView(view: self.menuDrawerView, cornerRadius: 25, borderWidth: 0, color: .clear)
        menuListTableView.register(MenuListCell.nib, forCellReuseIdentifier: MenuListCell.identifier)
//        self.menuListItems = [
//            .changeLanguage,.editprofile,
//            .subscription_plan,.feedback,.faqs,.tutorials,.privacy_policy,.terms_and_conditions,.deleteAccount,.logout
//        ]
        
        self.menuListItems = [
            .changeLanguage,
            .deleteAccount,.logout
        ]

        if let user = UserManager.shared.getUserInfo() {
                   self.usernamLbl.text = Utility.deCrypt(text: user.nickname)
            self.emailLbl.text = user.email
                   self.avatarImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + user.avatar)
               }
    }
  
}
