//
//  HomeViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/06.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

//protocol AssessmentSubmitDelegate:NSObject {
//    func submitQuestionResponse(response:AssessmentQuestionResponseVO)
//}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var txtPrioirty: UITextField!
    @IBOutlet weak var txtLevel: UITextField!
    
    @IBOutlet weak var btnsubmit: UIButton!
    
    private var list = [FormModel]()
    
    private var setPrioirtyViewModel = SetPrioirtyViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    
     var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utility.setView(view: self.btnsubmit, cornerRadius: 3, borderWidth: 0, color: .clear)
        
        self.listenModelClosures()

        // Do any additional setup after loading the view.
    }
    
    private func listenModelClosures() {
       self.setPrioirtyViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.setPrioirtyViewModel.accessmentSubmitResponseVO {
                        if res.success {
                            
                            if let user =  UserManager.shared.getUserInfo() {
                                var u = user
                                u.screen_id = "assesment"
                                UserManager.shared.saveUserInfo(userVO: u)
                            }
                            
                            let vc = Utility.getViewController(ofType: AssessmentViewController.self)
                            let navController = UINavigationController(rootViewController: vc)
                            navController.navigationBar.isTranslucent = false
                            AppDelegate.shared?.window!.rootViewController = navController
                            
                        
                    }
                }
            }
      }
    }
  

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
         Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
          
        self.setPrioirtyViewModel.submitPriorityAnswer(priority: txtPrioirty.text!, level: txtLevel.text!)
        
    }
    
      @IBAction func logoutClicked(_ sender: Any) {
    let vc = Utility.getViewController(ofType: LoginViewController.self)
    let navController = UINavigationController(rootViewController: vc)
    navController.navigationBar.isTranslucent = false
    AppDelegate.shared?.window!.rootViewController = navController
    }
    
   
}
extension HomeViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}
