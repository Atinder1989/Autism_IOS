//
//  AssessmentViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/04.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import AVKit
import SafariServices

class AssessmentViewController: UIViewController, SpeechManagerDelegate {
    
    private var assessmentViewModel = AssessmentViewModel()
    private var customWebView: CustomWebView?
    private var webViewTimer: Timer? = nil
    private var webViewTimeTaken = 0
    private var questionResponse:AssessmentQuestionResponseVO?
    private var isLandscape = false
    private var skipQuestion = false

    var svc: SFSafariViewController!
    var isYoutubeRunning:Bool = false
    
    let viewHeaderYT = UIView()
    let imgViewAvtarYT = UIImageView()
    let btnHomeYT = UIButton()
    let btnSkipYT = UIButton()
    
    private var apiDataState: APIDataState = .notCall
    @IBOutlet weak var skipButton: UIButton!

    var assessmentVC:UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.reloadData()
    }

    private func reloadData()
    {
        self.listenModelClosures()
        if DatabaseManager.sharedInstance.getUnDownloadedAvatarVariationList().count > 0
        {
            Utility.showLoader()
            AvatarDownloader.sharedInstance.downloadAvatarVariationList(list: DatabaseManager.sharedInstance.getUnDownloadedAvatarVariationList())
        } else {
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        if !isLandscape {
            isLandscape = true
            Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
           self.handleAssessmentScreenFlow()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.customWebView != nil {
            if(UIScreen.main.bounds.height > UIScreen.main.bounds.width) {
                self.customWebView!.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
            } else {
                self.customWebView!.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
        }
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
            self.skipQuestion = true
            if let res = self.assessmentViewModel.questionResponseVo,let info = res.bodyTrackingInfo {
                self.skipButton.isHidden = true
                self.assessmentViewModel.skipQuestion(info: info, completeRate: 0, timetaken: 4, skip: true)
            }
        }
    }
}

//MARK:- Private Methods
extension AssessmentViewController {
    private func handleAssessmentScreenFlow () {
        if let user = UserManager.shared.getUserInfo() {
            if user.avatar.count > 0 {
                self.assessmentViewModel.fetchQuestion()
            } else {
                self.assessmentViewModel.fetchUserAvatar()
            }
        }
    }
    
    private func listenModelClosures() {
            self.navigationController?.navigationBar.isHidden = true
            self.assessmentViewModel.dataClosure = {
                if let res = self.assessmentViewModel.questionResponseVo {
                    
                    self.apiDataState = .dataFetched
                    DispatchQueue.main.async {
                        //self.addWebView()
                        if res.enable_reinforcer {
                            self.questionResponse = res
                            self.showWebView()
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
    
    @objc func hideYoutube()
    {
        self.stopWebViewTimer()
        self.hideWebView()
    }
    
    @objc func btnHomeYTClicked()
    {
        DispatchQueue.main.async {

            self.stopWebViewTimer()
            self.svc.dismiss(animated: false, completion: {
                self.svc = nil
                self.isYoutubeRunning = false
                SpeechManager.shared.setDelegate(delegate: self)
            })
            UserManager.shared.exitAssessment()
        }
    }
    
    @objc func btnSkipYTClicked()
    {
        DispatchQueue.main.async {

            self.viewHeaderYT.isHidden = true
            self.stopWebViewTimer()
            
                self.svc.dismiss(animated: false, completion: {
                    self.svc = nil
                    self.isYoutubeRunning = false
                SpeechManager.shared.setDelegate(delegate: self)
                self.perform(#selector(self.callNextQuestion), with: nil, afterDelay: 1.0)
            })
        }
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
            self.hideWebView()
        }
    }
    
    private func stopWebViewTimer() {
        if let timer = self.webViewTimer {
            timer.invalidate()
            self.webViewTimer = nil
            self.webViewTimeTaken = 0
        }
    }
    
    private func addWebView() {
         if self.customWebView == nil {
                   if let nib = Bundle.main.loadNibNamed(CustomWebView.identifier, owner: nil, options: nil)?.first as? CustomWebView {
                    if(UIScreen.main.bounds.height > UIScreen.main.bounds.width) {
                       nib.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
                    } else {
                        nib.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    }
                    self.customWebView = nib
                    self.customWebView?.delegate = self
                       self.view.addSubview(nib)
                       if let webview = self.customWebView {
                        webview.loadWebPage()
                           webview.alpha = 0
                       }
                   }
               }
        
    }
    
    private func showWebView(_ animated:Bool = true) {
    
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
        svc.delegate = self
        if #available(iOS 10.0, *) {
            // The color to tint the background of the navigation bar and the toolbar.
            svc.preferredBarTintColor = .white//readerMode ? .blue : .orange
            // The color to tint the the control buttons on the navigation bar and the toolbar.
            svc.preferredControlTintColor = .white
        } else {
            // Fallback on earlier versions
        }
        
        DispatchQueue.main.async(execute: { [self] in
  
//        })
//        DispatchQueue.main.async {
            
            SpeechManager.shared.setDelegate(delegate: nil)
            self.present(self.svc, animated: false, completion: {
                
                self.isYoutubeRunning = true
                self.viewHeaderYT.isHidden = false
                self.viewHeaderYT.frame = CGRect(x:-1, y:-1, width: UIScreen.main.bounds.size.width+2, height: 54)
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
//        }
    })
        self.initializeWebViewTimer()
    
   }
    
    private func hideWebView() {
        
        viewHeaderYT.isHidden = true
        if(svc != nil) {
            svc.dismiss(animated: false, completion: {
                self.svc = nil
                self.isYoutubeRunning = false
                SpeechManager.shared.setDelegate(delegate: self)
            })
        }
        if let question = self.questionResponse {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.moveToNextQuestion(res: question)
            }
        }
    }
            
    func presentVC(vc:UIViewController) {
        
        //this.present(vc, animated: true, completion: nil)//OLD CODE
        
        if(assessmentVC == nil) {
            assessmentVC = vc
            self.present(vc, animated: true, completion: nil)
        } else {
            assessmentVC.dismiss(animated: false, completion: {
                self.assessmentVC = vc
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
    private func moveToNextQuestion(res:AssessmentQuestionResponseVO) {
    //    FaceDetection.shared.stopFaceDetectionSession()
     //   FaceDetection.shared.startFaceDetectionSession()
        DispatchQueue.main.async { [weak self] in
            
            if let this = self {
            
                trailPromptTimeForUser = 0
        screenLoadTime = Date()
        let type = AssessmentQuestionType.init(rawValue: res.question_type)
        switch type {
        case .balloon_game:
            if let info = res.balloonGameQuestionInfo {
                let vc = Utility.getViewController(ofType: AssessmentBalloonGameViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setBalloonGameQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
        }
        case .intro_video:
            if let info = res.introVideoQuestionInfo {
                let vc = Utility.getViewController(ofType: AssessmentIntroVideoViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setIntroVideoInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
        }
        case .body_tracking:
            if let info = res.bodyTrackingInfo {
                let vc = Utility.getViewController(ofType: AssessmentBodyTrackingViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setBodyTrackingQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
        }
        case .face_tracking:
                if let info = res.faceTrackingInfo {
                              let vc = Utility.getViewController(ofType: AssessmentFaceTrackingViewController.self)
                              vc.modalPresentationStyle = .fullScreen
                              vc.setFaceTrackingQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
        }
        case .eye_contact:
                if let info = res.eyeContactQuestionInfo {
                    let vc = Utility.getViewController(ofType: AssessmentEyeContactViewController.self)
                    vc.modalPresentationStyle = .fullScreen
                    vc.setEyeContactQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
                }
        case .VerbalResponse,.verbal_actions:
                if let info = res.verbalQuestionInfo {
                 let vc = Utility.getViewController(ofType: AssessmentVerbalQuestionViewController.self)
                 vc.modalPresentationStyle = .fullScreen
                 vc.setVerbalQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
                }
        case .verbal_with_multiple:
            if let info = res.verbalQuestionInfo {
             let vc = Utility.getViewController(ofType: AssessmentVerbalMultiplesViewController.self)
             vc.modalPresentationStyle = .fullScreen
             vc.setVerbalQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .tacting_4m_multiple:
                if let info = res.tacting4mQuestionInfo {
                 let vc = Utility.getViewController(ofType: AssessmentTacting4MMultipleViewController.self)
                 vc.modalPresentationStyle = .fullScreen
                 vc.setTactingQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
                }
        case .puzzle_show_alpha:
                if let info = res.puzzleQuestionInfo {
                    let vc = Utility.getViewController(ofType: AssessmentPuzzleAlphaViewController.self)
                    vc.modalPresentationStyle = .fullScreen
                    vc.setPuzzleQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
                }
        case .Puzzle:
                if let info = res.puzzleQuestionInfo {
                    let vc = Utility.getViewController(ofType: AssessmentPuzzleViewController.self)
                    vc.modalPresentationStyle = .fullScreen
                    vc.setPuzzleQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
                }
        case .reinforce,.reinforce_prefered:
                if let info = res.reinforcerInfo,let nonPrefferedInfo = res.reinforcerNonPreferredInfo {
                    let vc = Utility.getViewController(ofType: AssessmentReinforcerViewController.self)
                    vc.modalPresentationStyle = .fullScreen
                    vc.setReinforcerInfo(info: info, nonpreferredInfo: nonPrefferedInfo, delegate: this, type: type!)
                    this.presentVC(vc: vc)
                }
        case .reinforce_multi_choice:
            if let info = res.reinforceMultiChoiceInfo {
                let vc = Utility.getViewController(ofType: AssessmentReinforceMultiChoiceViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .multi_array_question:
        if let info = res.multiArrayQuestionInfo {
            let vc = Utility.getViewController(ofType: AssessmentMultiArrayQuestionViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setQuestionInfo(info: info, delegate: this)
            this.presentVC(vc: vc)
        }
              case .which_type_question,.PictureArray,.touch_object:
                if let info = res.which_type_question {
                    let vc = Utility.getViewController(ofType: AssessmentWhichTypeQuestionViewController.self)
                    vc.modalPresentationStyle = .fullScreen
                    vc.setQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
                }
        case .sound_imitation:
            if let info = res.soundImitationInfo {
                let vc = Utility.getViewController(ofType: AssessmentSoundImitationViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
            
        case .Mazes:
            if let info = res.mazesInfo {
            let vc = Utility.getViewController(ofType: AssessmentMazesViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setMazesQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
             }
        case .independent_play:
            if let info = res.independentPlayInfo {
            let vc = Utility.getViewController(ofType: AssessmentIndependentPlayViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setIndependentPlayQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
         }
       case .Videos:
            if let info = res.videoInfo {
             let vc = Utility.getViewController(ofType: AssessmentVideoControllerVC.self)
             vc.modalPresentationStyle = .fullScreen
             vc.setVideoQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
             }
        case .sort_object:
            if let info = res.sortObject {
             let vc = Utility.getViewController(ofType: AssessmentSortingViewController.self)
             vc.modalPresentationStyle = .fullScreen
             vc.setSortQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
             }
       case .match_count:
            if let info = res.mazeObject {
              let vc = Utility.getViewController(ofType: AssesmentMazeObjectController.self)
              vc.modalPresentationStyle = .fullScreen
              vc.setSortQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .find_object:
            if let info = res.findObject {
                let vc = Utility.getViewController(ofType: AssesmentFindObjectVC.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setSortQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .calendar:
               if let info = res.matchDate {
                 let vc = Utility.getViewController(ofType: AssesmentMatchDateViewController.self)
                 vc.modalPresentationStyle = .fullScreen
                 vc.setSortQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .arrange_sequence:
            if let info = res.sequenceInfo {
                let vc = Utility.getViewController(ofType: AsessmentSequenceViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setSequenceQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .add_subs_mathematics:
            if let info = res.mathematicsCalculation {
                let vc = Utility.getViewController(ofType: AssesmentMathematicsViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setSortQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .spelling:
            if let info = res.matchSpelling {
                let vc = Utility.getViewController(ofType: AssesmentMatchSpellingViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setSortQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .read_clock:
               if let info = res.readclock {
                   let vc = Utility.getViewController(ofType: AssesmentReadClockViewController.self)
                   vc.modalPresentationStyle = .fullScreen
                   vc.setSortQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
                }
        case .drawing:
             if let info = res.drawingInfo {
                              let vc = Utility.getViewController(ofType: AssessmentDrawingViewController.self)
                              vc.modalPresentationStyle = .fullScreen
                              vc.setDrawingQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
                                                       
                   }
        case .coloring_picture:
                        if let info = res.coloringInfo {
                let vc = Utility.getViewController(ofType: AssesmentColorViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setColorQuestionInfo(info: info, delegate: this)
                            this.presentVC(vc: vc)
            }
        case .alphabet_learning:
            if let info = res.alphabetLearningInfo {
                let vc = Utility.getViewController(ofType: AssessmentAlphabetLearningViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setAlphabetLearningInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .matching_object:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: AssessmentMatchingObjectViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .matching_object_drag:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: AssessmentMatchingObjectDragViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .match_object_with_messy_array:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: AssessmentMatchObjectWithMessyArrayViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .make_word:
            if let info = res.makeWorkInfo {
                let vc = Utility.getViewController(ofType: AssessmentMakeWordViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMakeWordInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .copy_pattern:
            if let info = res.copyPatternInfo {
                let vc = Utility.getViewController(ofType: AssessmentCopyPatternViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setCopyPatternInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .block_design:
            if let info = res.blockDesignInfo {
                let vc = Utility.getViewController(ofType: AssessmentBlockDesignViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setBlockDesignInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .introduction,.introduction_name:
        if let info = res.introductionQInfo {
             let vc = Utility.getViewController(ofType: AssessmentIntroductionViewController.self)
             vc.modalPresentationStyle = .fullScreen
             vc.setIntroductionQuestionInfo(info: info, delegate: this)
            this.presentVC(vc: vc)
            }
        case .environtmental_sounds:
            if let info = res.environmentalSoundInfo {
                 let vc = Utility.getViewController(ofType: AssessmentEnvironmentalSoundViewController.self)
                 vc.modalPresentationStyle = .fullScreen
                 vc.setIntroductionQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .fill_container:
            if let info = res.fillContainerInfo {
                let vc = Utility.getViewController(ofType: AssessmentFillContainerViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setFillContainerQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .matching_one_pair, .matching_three_pair:
            if let info = res.matchingObjectInfo {
                let vc = Utility.getViewController(ofType: AssessmentMatchingOnePairViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setMatchingObjectInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .manding_videos:
            if let info = res.videoInfo {
                let vc = Utility.getViewController(ofType: AssessmentMandingVdeosViewController.self)
                vc.modalPresentationStyle = .fullScreen
                vc.setVideoQuestionInfo(info: info, delegate: this)
                this.presentVC(vc: vc)
            }
        case .manding_verbal_video:
                if let info = res.verbalQuestionInfo {
                 let vc = Utility.getViewController(ofType: AssessmentMandingVerbalVideoViewController.self)
                 vc.modalPresentationStyle = .fullScreen
                 vc.setVerbalQuestionInfo(info: info, delegate: this)
                    this.presentVC(vc: vc)
                }
    
        default:
            this.moveToNextController(screenName: res.screen_id)
            break
        }
            
        }
            
        }
    }
    
    private func moveToNextController(screenName:String) {
      //  FaceDetection.shared.stopFaceDetectionSession()
        if  let type = ScreenRedirection.init(rawValue: screenName) {
            UserManager.shared.updateScreenId(screenid: screenName)
            let vc = type.getViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.skipButton.isHidden = false
        }
    }
    
    func speechDidFinish(speechText: String) {

    }

}

extension AssessmentViewController: AssessmentSubmitDelegate {
    func submitQuestionResponse(response:AssessmentQuestionResponseVO) {
        DispatchQueue.main.async {
        if response.screen_id.count == 0 {
            self.questionResponse = response
          //  FaceDetection.shared.stopFaceDetectionSession()
            if response.enable_reinforcer {
                self.showWebView()
            } else {
                self.moveToNextQuestion(res: response)
            }
        } else {
            self.moveToNextController(screenName: response.screen_id)
        }
        }
    }
}

extension AssessmentViewController: CustomWebViewDelegate {
    func didClickOnArrow() {
        self.stopWebViewTimer()
        self.hideWebView()
    }
    
    func didClickOnHome() {
        self.stopWebViewTimer()
        UserManager.shared.exitAssessment()
    }

}

extension AssessmentViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        //Tells the delegate that the initial URL load completed.
    }
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        //Tells the delegate that the user tapped an Action button.
        return []
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
        self.stopWebViewTimer()
        SpeechManager.shared.speak(message:"", uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        if let question = self.questionResponse {
           self.moveToNextQuestion(res: question)
        }
    }
}

extension AssessmentViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                self.reloadData()
                self.handleAssessmentScreenFlow()
            }
        }
    }
}
