//
//  AssessmentStartViewController.swift
//  Autism
//
//  Created by Savleen on 17/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentStartViewController: UIViewController {
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var completeProgressTextView: UITextView!

    private var assessmentStartViewModel = AssessmentStartViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        self.assessmentStartViewModel.fetchStartAssessmentScreenLabels()
    }
    @IBAction func startClicked(_ sender: Any) {
        let vc = Utility.getViewController(ofType: AssessmentViewController.self)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension AssessmentStartViewController {
    private func customSetting() {
            self.navigationController?.navigationBar.isHidden = true
        Utility.setView(view: self.whiteBackgroundView, cornerRadius: 10, borderWidth: 0, color: .clear)
        Utility.setView(view: self.startBtn, cornerRadius: 5, borderWidth: 0, color: .clear)
        
    }
    
    private func listenModelClosures()
    {
           self.assessmentStartViewModel.labelsClosure = {
                   DispatchQueue.main.async {
                           if let response = self.assessmentStartViewModel.labelsResponseVO {
                               self.setLabels(labelresponse: response)
                           }
                   }
           }
       }
       
       private func setLabels(labelresponse:ScreenLabelResponseVO) {
        if let user = UserManager.shared.getUserInfo() {
                          self.nameLbl.text = labelresponse.getLiteralof(code: AssessmentStartLabelCode.welcome.rawValue).label_text + " " + Utility.deCrypt(text: user.nickname)
        }
        self.startBtn.setTitle(labelresponse.getLiteralof(code: AssessmentStartLabelCode.start.rawValue).label_text, for: .normal)
        let text = labelresponse.getLiteralof(code: AssessmentStartLabelCode.complete_Progress.rawValue).label_text
        self.completeProgressTextView.text = text.replacingOccurrences(of: "\\n", with: "\n")

       }
}

extension AssessmentStartViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
//            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}
