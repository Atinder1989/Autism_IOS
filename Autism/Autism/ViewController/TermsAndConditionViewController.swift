//
//  TermsAndConditionViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/04/01.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class TermsAndConditionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backClicked(_ sender: Any) {
           self.navigationController?.popViewController(animated: true)
    }

}
