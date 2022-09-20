//
//  ParentPresenceViewController.swift
//  Autism
//
//  Created by Dilip Saket on 31/08/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit

class ParentPresenceViewController: UIViewController {
    
    private let parentPresenceViewModal: ParentPresenceViewModel = ParentPresenceViewModel()

    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    var questionId = ""

    //MARK: Outlets
    @IBOutlet weak var lblFirstNumber: UILabel!
    @IBOutlet weak var lblSecondumber: UILabel!
    @IBOutlet weak var lblTotalNumberHidden: UILabel!
    @IBOutlet weak var txtParentAnswer: UITextField!
    @IBOutlet weak var lblParentAnswerHidden: UILabel!
    @IBOutlet weak var lblBinaryFunc: UILabel!
    
    
    var timer: Timer?
    let userDefault = UserDefaults.standard
    
    var success_count = "0"
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberGenerator()
        
        startTimerForResendingCode()
        
        txtParentAnswer.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMathematicsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(AssesmentMathematicsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        Utility.setView(view: self.submitBtn, cornerRadius: self.submitBtn.frame.size.height/2.0, borderWidth: 1, color: .lightGray)
//    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    //MARK: Function Timer
    func startTimerForResendingCode() {
        let timerIntervalForResendingCode = TimeInterval(20)
        Timer.scheduledTimer(timeInterval: timerIntervalForResendingCode,
                             target: self,
                             selector: #selector(timerEndedUp),
                             userInfo: nil,
                             repeats: false)
    }
    
    @objc func timerEndedUp() {
        
        self.parentPresenceViewModal.submitParentPresenceAnswer(completeRate: success_count, content_type: "is_parent_present")
    }
        
    
    //MARK: Function Number Generator
    func numberGenerator(){
        let numberView1 = Int.random(in: 1..<10)
        lblFirstNumber.text = String(numberView1)
        
        let numberView2 = Int.random(in: 1..<10)
        self.lblSecondumber.text = String(numberView2)
        
        let totalNumberView = (numberView1 * numberView2)
        
        self.lblTotalNumberHidden.text = String(totalNumberView)
        self.userDefault.set(totalNumberView, forKey: "totalNumberView")
        
    }
        
    //MARK: Function Text Assign
    @objc func textChanged() {
        let input1 = Int(txtParentAnswer.text!)
        lblParentAnswerHidden.text = String(describing:
                                    (input1 ?? 0)
        )
        self.userDefault.set(input1, forKey: "input1")
    }
    
    //MARK: Action Buttons
    @IBAction func btnSubmitAnswer(_ sender: Any) {
        
        guard let finalEntered = userDefault.string(forKey: "totalNumberView") else { return }
        guard let generated = userDefault.string(forKey: "input1") else { return }
        
        if finalEntered == generated{
            success_count = "100"
            self.parentPresenceViewModal.submitParentPresenceAnswer(completeRate: success_count, content_type: "is_parent_present")
        } else {
            success_count = "0"
            self.parentPresenceViewModal.submitParentPresenceAnswer(completeRate: success_count, content_type: "is_parent_present")
        }
    }
}

extension ParentPresenceViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        
//        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        self.questionId = questionId
        self.command_array = command_array
    }
}
