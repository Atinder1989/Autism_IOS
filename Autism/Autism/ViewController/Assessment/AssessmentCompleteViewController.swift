//
//  AssessmentCompleteViewController.swift
//  Autism
//
//  Created by Savleen on 29/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentCompleteViewController: UIViewController {
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var successfullyCompletedLbl: UILabel!

    private var assessmentCompleteViewModel = AssessmentCompleteViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        assessmentCompleteViewModel.fetchAssessmentCompleteScreenLabels()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }
    @IBAction func nextClicked(_ sender: Any) {
       UserManager.shared.updateScreenId(screenid: ScreenRedirection.dashboard.rawValue)
       let vc = Utility.getViewController(ofType: DashboardViewController.self)
       vc.modalPresentationStyle = .fullScreen
       self.present(vc, animated: true, completion: nil)
    }

}

extension AssessmentCompleteViewController {
    private func customSetting() {
            self.navigationController?.navigationBar.isHidden = true
        Utility.setView(view: self.whiteBackgroundView, cornerRadius: 10, borderWidth: 0, color: .clear)
        Utility.setView(view: self.nextBtn, cornerRadius: 30, borderWidth: 0.5, color: .darkGray)
    }
    
    private func listenModelClosures() {
        self.assessmentCompleteViewModel.labelsClosure = {
                DispatchQueue.main.async {
                        if let response = self.assessmentCompleteViewModel.labelsResponseVO {
                            self.setLabels(labelresponse: response)
                        }
                }
        }
    }
    
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        if let user = UserManager.shared.getUserInfo() {
            self.nameLbl.text = labelresponse.getLiteralof(code: AssessmentCompleteLabelCode.congrats.rawValue).label_text + " " + Utility.deCrypt(text: user.nickname)
        }
       // self.nextBtn.setTitle(labelresponse.getLiteralof(code: AssessmentCompleteLabelCode.next.rawValue).label_text, for: .normal)
        self.successfullyCompletedLbl.text = labelresponse.getLiteralof(code: AssessmentCompleteLabelCode.successfully_Completed.rawValue).label_text
    }
    
}
extension AssessmentCompleteViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            self.listenModelClosures()
        }
    }
}
