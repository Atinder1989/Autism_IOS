//
//  OptionDescriptionViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/26.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class OptionDescriptionViewController: UIViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    var info: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.descriptionTextView.text = self.info.replacingOccurrences(of: "\\n", with: "\n")
    }
 
}
