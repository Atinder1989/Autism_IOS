//
//  TrialViewController.swift
//  Autism
//
//  Created by Dilip Technology on 22/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class TrialViewController: UIViewController, SpeechManagerDelegate {
    
    private var trialViewModel = TrialViewModel()

    private var webViewTimer: Timer? = nil
    private var webViewTimeTaken = 0
    private var questionResponse:TrialQuestionResponseVO?
    private var isLandscape = false
    private var skipQuestion = false
    
    let viewHeaderYT = UIView()
    let imgViewAvtarYT = UIImageView()
    let btnHomeYT = UIButton()
    let btnSkipYT = UIButton()
    
    private var apiDataState: APIDataState = .notCall
    @IBOutlet weak var skipButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.reloadData()
    }

    private func reloadData()
    {
        self.listenModelClosures()
//        if DatabaseManager.sharedInstance.getUnDownloadedAvatarVariationList().count > 0
//        {
//            Utility.showLoader()
//            AvatarDownloader.sharedInstance.downloadAvatarVariationList(list: DatabaseManager.sharedInstance.getUnDownloadedAvatarVariationList())
//        } else {
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        if !isLandscape {
            isLandscape = true
            Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
           self.handleTrialScreenFlow()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
//           self.stopQuestionCompletionTimer()
//           SpeechManager.shared.setDelegate(delegate: nil)
           UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
//        if !skipQuestion {
//            self.skipQuestion = true
//            if let res = self.trialViewModel.questionResponseVo,let info = res.bodyTrackingInfo {
//                self.skipButton.isHidden = true
//                self.trialViewModel.skipQuestion(info: info, completeRate: 0, timetaken: 4, skip: true)
//            }
//        }
    }
    
}

//MARK:- Private Methods
extension TrialViewController {
    private func handleTrialScreenFlow () {
        if let user = UserManager.shared.getUserInfo() {
            if user.avatar.count > 0 {
                let strMessage = "skill_domain_id : "+trial_skill_domain_id_value+"\n\n"+"program_id : "+trial_program_id_value+"\n\n"+"req_no : "+trial_req_no_value+"\n\n"+"table_name : "+trial_table_name_value
                let alert = UIAlertController(title: "Trial", message: strMessage, preferredStyle: UIAlertController.Style.alert)
                
                let ok = UIAlertAction(title: "Continue", style: .default, handler: { action in
                    self.trialViewModel.fetchQuestion()
                })
                alert.addAction(ok)
                
                let cancel = UIAlertAction(title: "Change Values", style: .default, handler: { action in
                    self.updateValues()
                })
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
                        
                //self.trialViewModel.fetchQuestion()
            } else {
                self.trialViewModel.fetchUserAvatar()
            }
        }
    }
    
    func updateValues()
    {
        let alert = UIAlertController(title:"Trial Values", message: "Customize parameter values:", preferredStyle:UIAlertController.Style.alert)

        //                var trial_skill_domain_id_value = "5f4163366af0b9e258061c65"
        //                var trial_program_id_value = "5f3ffd5ff0774f38bfb7df2c"
        //                var trial_req_no_value = "SD9P1L3_3"
        //                var trial_table_name_value = "verbal_with_multiple"


        //ADD TEXT FIELD (YOU CAN ADD MULTIPLE TEXTFILED AS WELL)
        alert.addTextField { (textField : UITextField!) in
            textField.placeholder = "skill_domain_id"
            //textField.delegate = self
        }
        alert.addTextField { (textField : UITextField!) in
            textField.placeholder = "program_id"
            //textField.delegate = self
        }
        alert.addTextField { (textField : UITextField!) in
            textField.placeholder = "req_no"
            //textField.delegate = self
        }
        alert.addTextField { (textField : UITextField!) in
            textField.placeholder = "table_name"
            //textField.delegate = self
        }
        
        
        //SAVE BUTTON
        let save = UIAlertAction(title: "Save & Continue", style: UIAlertAction.Style.default, handler: { saveAction -> Void in
            let textField0 = alert.textFields![0] as UITextField
            let textField1 = alert.textFields![1] as UITextField
            let textField2 = alert.textFields![2] as UITextField
            let textField3 = alert.textFields![3] as UITextField
            
            trial_skill_domain_id_value = textField0.text ?? trial_skill_domain_id_value
            trial_program_id_value = textField1.text ?? trial_program_id_value
            trial_req_no_value = textField2.text ?? trial_req_no_value
            trial_table_name_value = textField3.text ?? trial_table_name_value
            
            self.trialViewModel.fetchQuestion()
        })
        //CANCEL BUTTON
        let cancel = UIAlertAction(title: "Continue Without change", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in
            
            self.trialViewModel.fetchQuestion()
        })

        alert.addAction(save)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)

    }
    
    private func listenModelClosures() {
            self.navigationController?.navigationBar.isHidden = true
            self.trialViewModel.dataClosure = {
                if let res = self.trialViewModel.questionResponseVo {
                    
                    self.apiDataState = .dataFetched
                    DispatchQueue.main.async {
                        if res.enable_reinforcer {
                            self.questionResponse = res
                        } else {
                            self.moveToNextQuestion(res: res)
                        }
                    }
                }
            }
    }
    
    private func initializeWebViewTimer() {
         webViewTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }

    @objc func callNextQuestion()
    {
        if let question = self.questionResponse {
            self.moveToNextQuestion(res: question)
        }
    }
    @objc private func calculateTimeTaken() {
        print("Webview Timer =====")
        self.webViewTimeTaken += 1
        if self.webViewTimeTaken == Int(AppConstant.webviewTimer.rawValue) {
            self.stopWebViewTimer()
        }
    }
    
    private func stopWebViewTimer() {
        if let timer = self.webViewTimer {
            timer.invalidate()
            self.webViewTimer = nil
            self.webViewTimeTaken = 0
        }
    }
            
    private func moveToNextQuestion(res:TrialQuestionResponseVO) {
        
        DispatchQueue.main.async {
        let type = AssessmentQuestionType.init(rawValue: res.question_type)
        switch type {
        case .matching_object:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: TrialMatchingObjectViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .PictureArray:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: TrialPictureArrayViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .VerbalResponse,.verbal_actions, .introduction_name:
            if let info = res.verbalQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialVerbalQuestionViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setVerbalQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .verbal_with_multiple:
            if let info = res.verbalQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialVerbalWithMultippleViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setVerbalQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .matching_one_pair:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: TrialMatchingOnePairViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .matching_three_pair:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: TrialMatching3PairViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .environtmental_sounds:
            if let info = res.verbalQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialEchoicViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setVerbalQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .sound_of_animals:
            if let info = res.verbalQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialSoundOfAnimalsViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setVerbalQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .spelling:
            if let info = res.matchSpellingQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialSpellingViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setSpellingQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .add_subs_mathematics:
            if let info = res.mathematicsCalculationInfo {
                let vc = Utility.getViewController(ofType: TrialMathematicsViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMathematicsQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
            }
        case .balloon_game:
            if let info = res.balloonGameQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialBalloonGameViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
        }
        case .body_tracking:
            if let info = res.bodyTrackingInfo {
                let vc = Utility.getViewController(ofType: TrialBodyTrackingViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
        }
        case .Mazes:
            if let info = res.mazeInfo {
                let vc = Utility.getViewController(ofType: TrialGrabingObjectsViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setQuestionInfo(info: info, delegate: self)
                self.present(vc, animated: true, completion: nil)
        }
        default:
            self.didClickOnHome()
            break
        }
        }
    }
    
    private func moveToNextController(screenName:String) {
//        if  let type = ScreenRedirection.init(rawValue: screenName) {
//            UserManager.shared.updateScreenId(screenid: screenName)
//            let vc = type.getViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            self.skipButton.isHidden = false
//        }
    }
    
    func speechDidFinish(speechText: String) {

    }

}

extension TrialViewController: TrialSubmitDelegate {
    func submitQuestionResponse(response:TrialQuestionResponseVO) {
        DispatchQueue.main.async {
//        if response.screen_id.count == 0 {
            self.questionResponse = response
            if response.enable_reinforcer {
                
            } else {
                self.moveToNextQuestion(res: response)
            }
//        } else {
//            self.moveToNextController(screenName: response.screen_id)
//        }
        }
    }
}

extension TrialViewController: CustomWebViewDelegate {
    func didClickOnArrow() {
        self.stopWebViewTimer()
    }
    
    func didClickOnHome() {
        self.stopWebViewTimer()
        UserManager.shared.exitAssessment()
    }

}

extension TrialViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                self.reloadData()
                self.handleTrialScreenFlow()
            }
        }
    }
}
