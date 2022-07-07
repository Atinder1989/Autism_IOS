//
//  MandViewController.swift
//  Autism
//
//  Created by Dilip Saket on 02/07/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit

class MandViewController: UIViewController {

    var algoResponse:AlgorithmResponseVO!
    let mandViewModel:MandViewModel = MandViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitButtonClicked() {
        mandViewModel.submitLearningMandAnswer(response: self.algoResponse)
    }

    func setResponse(algoResponse:AlgorithmResponseVO) {
        self.algoResponse = algoResponse
        
    }
}
