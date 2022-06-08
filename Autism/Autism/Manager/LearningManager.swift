//
//  LearningManager.swift
//  Autism
//
//  Created by Savleen on 23/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import SafariServices

class LearningManager {
   
    static var webViewTimer: Timer? = nil
    static var webViewTimeTaken = 0
    
    static var svc: SFSafariViewController!
    static var isYoutubeRunning:Bool = false
    
    static let viewHeaderYT = UIView()
    static let imgViewAvtarYT = UIImageView()
    static let btnHomeYT = UIButton()
    static let btnSkipYT = UIButton()
    
    static var trialInfo:TrialInfo!
    
    static func getLearningScriptController(skill_domain_id:String,program: LearningProgramModel,command_array: [ScriptCommandInfo],questionId:String) -> UIViewController?  {
        var scriptController: UIViewController? = nil
        print("#program.label_code ==== \(program.label_code)")
        switch program.label_code {
        case .following_instructions:
            let vc = Utility.getViewController(ofType: LearningFollowingInstructionsViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .matching:
            let vc = Utility.getViewController(ofType: LearningMatchingViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .matching_identical, .matching_identical_2, .matching_identical_3:
            let vc = Utility.getViewController(ofType: LearningMatchingIdenticalViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .matching_three_pair:
            let vc = Utility.getViewController(ofType: LearningMatching3PairViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .visual_tracking:
            let vc = Utility.getViewController(ofType: LearningVisualTrackingViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .colors,.shapes,.solid_colors,.basic_colors,.colors_shapes,.simple_colors,.expressively_labeling_items:
            let vc = Utility.getViewController(ofType: LearningColorViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .grabing_objects:
            let vc = Utility.getViewController(ofType: LearningGrabingObjectsViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .tacting_2objects_help,.vocal_Imitations,.tacting_4object_no_help,.tacting_6non_favourite_2,.tacting_6non_favourite,.tacting_10_item, .tacting_2objects_no_help:
            let vc = Utility.getViewController(ofType: LearningVocalImitationsViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .echoic1M,.echoic_2M,.echoice_3M,.echoice_4M,.echoic_5M,.echoice_5M_2,.echoice_3M_2:
            let vc = Utility.getViewController(ofType: LearningEchoicViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .spelling:
            let vc = Utility.getViewController(ofType: LearningSpellingViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        
        case .manding_2words_help:
            let vc = Utility.getViewController(ofType: LearningManding2WordsViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .mathematics:
            let vc = Utility.getViewController(ofType: LearningMathematicsViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .fine_motor_movements:
            let vc = Utility.getViewController(ofType: LearningFineMotorMovementViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        case .eye_contact:
            let vc = Utility.getViewController(ofType: LearningEyeContactViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setData(program: program, skillDomainId: skill_domain_id,command_array:command_array ,questionId:questionId)
            scriptController = vc
        default:break
        }
        
        if let _ = scriptController {
           // FaceDetection.shared.startFaceDetectionSession()
        }
        
        return scriptController
    }
    
    static func getTrialController(info:TrialInfo) -> UIViewController?  {
        var scriptController: UIViewController? = nil
        trialInfo = info
        if(info.enable_reinforcer == true) {
            self.showWebView()
            return nil
        }
        let type = AssessmentQuestionType.init(rawValue: info.question_type)
        switch type {
        case .matching_object:
            if let info = info.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: TrialMatchingObjectViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info)
                scriptController = vc
            }
        case .PictureArray,.colors,.shapes,.solid_colors:
            if let info = info.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: TrialPictureArrayViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info)
                scriptController = vc
            }
        case .VerbalResponse,.verbal_actions,.introduction_name:
            if let info = info.verbalQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialVerbalQuestionViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setVerbalQuestionInfo(info: info)
                scriptController = vc
            }
        case .verbal_with_multiple:
            if let info = info.verbalQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialVerbalWithMultippleViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setVerbalQuestionInfo(info: info)
                scriptController = vc
            }
        case .environtmental_sounds:
            if let info = info.verbalQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialEchoicViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setVerbalQuestionInfo(info: info)
                scriptController = vc
            }
        case .matching_one_pair:
            if let info = info.matchingObjectInfo {
                
                if(info.block.count > 1) {
                    let vc = Utility.getViewController(ofType: TrialMatching3PairViewController.self)
                    vc.isFromLearning = true
                    vc.modalPresentationStyle = .fullScreen
                    vc.setMatchingObjectInfo(info: info)
                    scriptController = vc
                } else {
                    let vc = Utility.getViewController(ofType: TrialMatchingOnePairViewController.self)
                    vc.isFromLearning = true
                    vc.modalPresentationStyle = .fullScreen
                    vc.setMatchingObjectInfo(info: info)
                    scriptController = vc
                }
            }
        case .matching_three_pair:
            if let info = info.matchingObjectInfo {
                if(info.block.count > 1) {
                    let vc = Utility.getViewController(ofType: TrialMatching3PairViewController.self)
                    vc.isFromLearning = true
                    vc.modalPresentationStyle = .fullScreen
                    vc.setMatchingObjectInfo(info: info)
                    scriptController = vc
                } else {
                    let vc = Utility.getViewController(ofType: TrialMatchingOnePairViewController.self)
                    vc.isFromLearning = true
                    vc.modalPresentationStyle = .fullScreen
                    vc.setMatchingObjectInfo(info: info)
                    scriptController = vc
                }
            }

        case .spelling:
            if let info = info.spellingQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialSpellingViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setSpellingQuestionInfo(info: info)
                scriptController = vc
            }
        case .add_subs_mathematics:
            if let info = info.mathematicsCalculationInfo {
                let vc = Utility.getViewController(ofType: TrialMathematicsViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setMathematicsQuestionInfo(info: info)
                scriptController = vc
            }
        case .balloon_game:
            if let info = info.balloonGameQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialBalloonGameViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setQuestionInfo(info: info)
                scriptController = vc
            }
        case .body_tracking:
            if let info = info.bodyTrackingQuestionInfo {
                let vc = Utility.getViewController(ofType: TrialBodyTrackingViewController.self)
                vc.isFromLearning = true
                vc.modalPresentationStyle = .fullScreen
                vc.setQuestionInfo(info: info)
                scriptController = vc
            }
        default:break
        }
        
        if let _ = scriptController {
           // FaceDetection.shared.startFaceDetectionSession()
        }
        
        return scriptController
    }
    
    static func submitLearningMatchingAnswer(parameters:[String: Any]) {
        //FaceDetection.shared.stopFaceDetectionSession()
        var params = parameters
        params[ ServiceParsingKeys.log_type.rawValue] = CourseModule.learning.rawValue
        
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getLearningAnswerUrl()
        service.params = params
        print("parameters learning = ", params)
        ServiceManager.processDataFromServer(service: service, model: AlgorithmResponseVO.self) {(responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let response = responseVo {
                    DispatchQueue.main.async {
                    self.handleResponse(response: response)
                    }
                }
            }
        }
    }
    
    static func submitTrialMatchingAnswer(parameters:[String: Any]) {
       // FaceDetection.shared.stopFaceDetectionSession()
        var params = parameters
        params[ ServiceParsingKeys.log_type.rawValue] = CourseModule.trial.rawValue
    
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.trialAnswerUrl()
        service.params = params
        print("parameters learning trial = ", params)
        ServiceManager.processDataFromServer(service: service, model: AlgorithmResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let response = responseVo {
                    DispatchQueue.main.async {
                    self.handleResponse(response: response)
                    }
                }
            }
        }
    }
    
    static func handleResponse(response:AlgorithmResponseVO) {
        if let data = response.data {
        switch data.course_type {
        case .learning:
            if let info = data.learninginfo {
                var program = LearningProgramModel.init()
                program.program_id = info.program_id
                if let code =  ProgramCode.init(rawValue: info.label_code) {
                    program.label_code = code
                } else {
                    program.label_code = .none
                }
                if let topvc = UIApplication.topViewController() {
                    if let vc = self.getLearningScriptController(skill_domain_id: info.skill_domain_id, program: program, command_array: [], questionId: "") {
                    topvc.present(vc, animated: true, completion: nil)
                    } else {
                        Utility.showAlert(title: "Information", message: "Learning Work under progress")
                        UserManager.shared.exitAssessment()
                    }
                }
            }
            break
        case .trial:
            if let info = data.trialInfo {
                self.handleTrialInfo(trialInfo:info)
            }
            break
        default:
            self.showAlert(message: response.message)
            break
        }
        } else {
            self.showAlert(message: response.message)
        }
    }
    
    static func showAlert(message: String) {
        if let topController = UIApplication.topViewController() {
            if topController is UIAlertController {
            } else {
                let alert = UIAlertController(title: "", message: message,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                    self.resetAssessment()
                }))
                topController.present(alert, animated: true, completion: nil)
            }
         }
    }

    static func handleTrialInfo(trialInfo:TrialInfo)
    {
        if let topvc = UIApplication.topViewController() {
            if let vc = self.getTrialController(info: trialInfo) {
                topvc.present(vc, animated: true, completion: nil)
            } else {
                if(trialInfo.enable_reinforcer == false) {
                    Utility.showAlert(title: "Information", message: "Trail Work under progress")
                    UserManager.shared.exitAssessment()
                }
            }
        }
    }
    
    
    private static func resetAssessment() {
        Utility.showLoader()
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getResetLearning()
        if let user = UserManager.shared.getUserInfo() {
           service.params = [
            ServiceParsingKeys.user_id.rawValue:user.id,
           ]
        }
        ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
            Utility.hideLoader()
            if let _ = error {
            } else {
                if let res = responseVo {
                    DispatchQueue.main.async {
                        self.resetLearning()
                    }
                }
            }
        }
    }

    
    private static func resetLearning() {
        Utility.showLoader()

           var service = Service.init(httpMethod: .POST)
           service.url = ServiceHelper.getResetAssessmentUrl()
           if let user = UserManager.shared.getUserInfo() {
               service.params = [
                   ServiceParsingKeys.user_id.rawValue:user.id,
               ]
           }
           ServiceManager.processDataFromServer(service: service, model: CommonMessageResponseVO.self) { (responseVo, error) in
               Utility.hideLoader()
               if let e = error {
                   print("Error = ", e.localizedDescription)
               } else {
                   if let _ = responseVo {
                       UserManager.shared.resetAssessment()
                   }
               }
           }
       }
    
    
    //MARK:- Youtube
    static func initializeWebViewTimer() {
        LearningManager.webViewTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LearningManager.calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc static func hideYoutube()
    {
        self.stopWebViewTimer()
        self.hideWebView()
    }
    
    @objc static func btnHomeYTClicked()
    {
        DispatchQueue.main.async {

            self.stopWebViewTimer()
            self.svc.dismiss(animated: false, completion: {
                self.svc = nil
                self.isYoutubeRunning = false
                //SpeechManager.shared.setDelegate(delegate: self)
            })
            UserManager.shared.exitAssessment()
        }
    }
    
    @objc static func btnSkipYTClicked()
    {
        DispatchQueue.main.async {

            self.viewHeaderYT.isHidden = true
            self.stopWebViewTimer()
            
                self.svc.dismiss(animated: false, completion: {
                    self.svc = nil
                    self.isYoutubeRunning = false
                //SpeechManager.shared.setDelegate(delegate: self)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.callNextQuestion()
                    }
                    //perform(#selector(LearningManager.callNextQuestion), with: nil, afterDelay: 1.0)
            })
        }
    }
    
    @objc static func callNextQuestion()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if var info = trialInfo {
                info.enable_reinforcer = false
               self.handleTrialInfo(trialInfo: info)
            }
        }
    }
    
    @objc private static func calculateTimeTaken() {
        print("Webview Timer =====")
        self.webViewTimeTaken += 1
        if self.webViewTimeTaken == Int(AppConstant.webviewTimer.rawValue) {
            self.stopWebViewTimer()
            self.hideWebView()
        }
    }
    
    static func stopWebViewTimer() {
        if let timer = self.webViewTimer {
            timer.invalidate()
            self.webViewTimer = nil
            self.webViewTimeTaken = 0
        }
    }
    
    static func showWebView(_ animated:Bool = true) {
    
        if(svc == nil) {
            svc = SFSafariViewController.init(url: URL(string: "https://www.youtubekids.com/")!)
            if #available(iOS 13.0, *) {
                svc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
        
            svc.modalPresentationStyle = .fullScreen
        }
        // You can also init the view controller with the SFSafariViewController:url: method
       // svc.delegate = self
        if #available(iOS 10.0, *) {
            // The color to tint the background of the navigation bar and the toolbar.
            svc.preferredBarTintColor = .white//readerMode ? .blue : .orange
            // The color to tint the the control buttons on the navigation bar and the toolbar.
            svc.preferredControlTintColor = .white
        } else {
            // Fallback on earlier versions
        }
        
        DispatchQueue.main.async(execute: { [self] in
              
            SpeechManager.shared.setDelegate(delegate: nil)
            if let topvc = UIApplication.topViewController() {
                topvc.present(self.svc, animated: false, completion: {
                    
                    self.isYoutubeRunning = true
                    self.viewHeaderYT.isHidden = false
                    self.viewHeaderYT.frame = CGRect(x:-1, y:-1, width: UIScreen.main.bounds.size.width+2, height: 64)
                    self.viewHeaderYT.backgroundColor = .white
                    
                    if(self.svc != nil) {
                        self.svc.view.window!.addSubview(self.viewHeaderYT)
                    }
                
                    self.imgViewAvtarYT.frame = CGRect(x:UIScreen.main.bounds.size.width-180, y:7, width: 50, height: 50)
                    self.imgViewAvtarYT.clipsToBounds = true
                    self.imgViewAvtarYT.layer.cornerRadius = 20.0
                    self.imgViewAvtarYT.backgroundColor = UIColor.init(white: 1.0, alpha: 0.1)
                
                    if let user = UserManager.shared.getUserInfo() {
                        self.imgViewAvtarYT.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + user.avatar)
                    }
                    self.viewHeaderYT.addSubview(self.imgViewAvtarYT)
                            
                    self.btnHomeYT.backgroundColor = .clear
                    //self.btnHomeYT.setImage(UIImage.init(named: "home"), for: .normal)
                    self.btnHomeYT.setImage(UIImage.init(named: "home"), for: .normal)
                    self.btnHomeYT.setTitleColor(.black, for: .normal)
                    self.btnHomeYT.frame = CGRect(x:UIScreen.main.bounds.size.width-120, y:7, width: 50, height: 50)
                    self.btnHomeYT.addTarget(self, action: #selector(self.btnHomeYTClicked), for: .touchDown)
                    self.viewHeaderYT.addSubview(self.btnHomeYT)
                            
                    self.btnSkipYT.backgroundColor = .clear
                    //self.btnSkipYT.setImage(UIImage.init(named: "back"), for: .normal)
                    self.btnSkipYT.setImage(UIImage.init(named: "skip"), for: .normal)
                    self.btnSkipYT.setTitleColor(.black, for: .normal)
                    self.btnSkipYT.frame = CGRect(x:UIScreen.main.bounds.size.width-60, y:7, width: 50, height: 50)// CGRect(x:10, y:4, width: 40, height: 40)
                    self.btnSkipYT.addTarget(self, action: #selector(self.btnSkipYTClicked), for: .touchDown)
                    self.viewHeaderYT.addSubview(self.btnSkipYT)
                })
            }
            
//        }
    })
        initializeWebViewTimer()
    
   }
    
    static func hideWebView() {
        
        viewHeaderYT.isHidden = true
        if(svc != nil) {
            svc.dismiss(animated: false, completion: {
                self.svc = nil
                self.isYoutubeRunning = false
                //SpeechManager.shared.setDelegate(delegate: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.callNextQuestion()
//                    if var info = trialInfo {
//                        info.enable_reinforcer = false
//                        self.handleTrialInfo(trialInfo: info)
//                    }
                }
            })
        }
        
    }
    
    //MARK:- Delegate
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        //Tells the delegate that the initial URL load completed.
    }
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        //Tells the delegate that the user tapped an Action button.
        return []
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
        //stopWebViewTimer()
        //SpeechManager.shared.speak(message:"", uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
//        if let question = self.questionResponse {
//           self.moveToNextQuestion(res: question)
//        }
    }
}


