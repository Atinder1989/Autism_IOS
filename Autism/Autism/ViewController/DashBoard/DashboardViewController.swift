//
//  DashboardViewController.swift
//  Autism
//
//  Created by Savleen on 29/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

struct DashboardLevel {
    let backgroundColor: UIColor
    let image: UIImage
    let textColor: UIColor
}

class DashboardViewController: UIViewController {
    private var dashboardViewModel = DashboardViewModel()
    @IBOutlet weak var usernamLbl: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var resumeAssessmentButton: UIButton!
    @IBOutlet weak var levelCollectionView: UICollectionView!
    @IBOutlet weak var performanceCollectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var currentAssessmentLbl: UILabel!

    private var popOverContentController = UIViewController()

    private var menuVC = Utility.getViewController(ofType: MenuListViewController.self)
    private var isMenuVisible = false
    private var levelList = [DashboardLevel]()
    private var courseType:CourseModule = .assessment {
        didSet{
            DispatchQueue.main.async {
                if let res = self.dashboardViewModel.dashboardPerformanceResponseVO {
                    if res.assessment_status == ModuleStatus.completed {
                        self.historyButton.isHidden = self.courseType == .learning ? true : false
                        self.currentAssessmentLbl.isHidden = self.courseType == .learning ? true : false
                    }
                    self.performanceCollectionView.reloadData()
                }
            }
        }
    }
    
    private var selectedLevelIndexPath: IndexPath?
    private var selectedHistory: History? = nil {
        didSet{
            DispatchQueue.main.async {
                if let history = self.selectedHistory {
                    var text = history.title
                    if history.start_date.count > 0 {
                        text = text + "  Start Date: "+history.start_date
                    }
                    if history.end_date.count > 0 {
                        text = text  + "  End Date: "+history.end_date
                    }
                    self.currentAssessmentLbl.text = text
                    if let res = self.dashboardViewModel.dashboardPerformanceResponseVO {
                        if res.assessment_status == ModuleStatus.completed {
                            self.currentAssessmentLbl.isHidden = false
                        } else {
                            self.currentAssessmentLbl.isHidden = true
                        }
                        
                    }
                }
            }
        }
    }
    
    private var levelIndex = -1 {
        didSet {
            DispatchQueue.main.async {
                if let history = self.selectedHistory {
                if let _ = self.selectedLevelIndexPath {
                    var paths = [IndexPath]()
                    for (i,_) in history.performanceList.enumerated() {
                        paths.append(IndexPath.init(row: i, section: 0))
                    }
                    self.levelCollectionView.reloadItems(at: paths)
                } else {
                    self.levelCollectionView.reloadData()
                }
                self.performanceCollectionView.reloadData()
                }
            }
        }
    }

        private var historyList :[History] = [] {
           didSet {
               DispatchQueue.main.async {
                    if self.historyList.count > 0 {
                        self.levelIndex = 0
                    }
               }
           }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.customSetting()
        self.dashboardViewModel.fetchDashboardScreenLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
        Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
//        SpeechManager.shared.setDelegate(delegate: nil)
        
        self.stopAllCommands()
    }
    
    func stopAllCommands() {
        SpeechManager.shared.stopSpeech()
        SpeechManager.shared.setDelegate(delegate: nil)
        RecordingManager.shared.stopRecording()
//            self.scriptManager.stopallTimer()
    }
    
    @IBAction func historyClicked(_ sender: UIButton) {
        print("History Clicked")
        if let labelResponse = self.dashboardViewModel.labelsResponseVO, let response = self.dashboardViewModel.dashboardPerformanceResponseVO {
        let vc = Utility.getViewController(ofType: PopOverContentViewController.self)
        vc.setLabels(lblResponse: labelResponse, delegate: self)
            vc.historyList = response.all_dates
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 348, height: 250)
        self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
        }
    }
    
    private func showPopOverView(sourceView:UIView, frame:CGRect,vc:UIViewController) {
        self.popOverContentController = vc

         if let popoverPresentationController = vc.popoverPresentationController {
         popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = frame
         popoverPresentationController.delegate = self
         present(vc, animated: true, completion: nil)
         }
     }
    
    @IBAction func settingsClicked(_ sender: Any) {
        print("Setting Clicked")
        if !isMenuVisible {
                   self.showMenuView()
        } else {
            self.isMenuVisible = false
        }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
            switch segmentedControl.selectedSegmentIndex
            {
            case 0:
                self.courseType = .learning
            case 1:
                self.courseType = .assessment
            default:
                break;
            }
        }
    
    
    @IBAction func resumeAssessmentClicked(_ sender: Any) {
       if !self.dashboardViewModel.isActionPerformed() {
           if let res = self.dashboardViewModel.dashboardPerformanceResponseVO {
               if res.assessment_status == ModuleStatus.completed {
                   self.dashboardViewModel.getLearningAlgoScript()
               } else {
                   UserManager.shared.resumeAssessment()
               }
           }
        }
      
    }
    
    @IBAction func resetAssessmentClicked(_ sender: Any) {
            DispatchQueue.main.async {
                self.dashboardViewModel.resetAssessment()
            }
    }
    
    @IBAction func resetLearningClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.dashboardViewModel.resetLearning()
        }
    }
    
    @IBAction func trialClicked(_ sender: Any) {
        DispatchQueue.main.async {
            let vc = Utility.getViewController(ofType: TrialViewController.self)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
}

//MARK:- Private Methods
extension DashboardViewController {
   
    private func listenModelClosures() {
        
        self.dashboardViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
        
          self.dashboardViewModel.dataClosure = {
                  DispatchQueue.main.async {
                          if let response = self.dashboardViewModel.labelsResponseVO {
                              self.setLabels(labelresponse: response)
                              self.addMenuView(labelResposne: response)
                          }
                    if let res = self.dashboardViewModel.dashboardPerformanceResponseVO {
                        if res.history.count > 0 {
                            self.selectedHistory = res.history[0]
                            self.historyList = res.history
                            self.levelIndex = 0
                        }
                    }
                  }
          }
        
        self.dashboardViewModel.resetAssessmentClosure = { response in
            DispatchQueue.main.async {
                if response.success {
                    UserManager.shared.resetAssessment()
                }
            }
        }
        
        self.dashboardViewModel.resetLearningClosure = { response in
           
        }
        
        self.dashboardViewModel.deleteAccountClosure = { response in
            DispatchQueue.main.async {
                if response.success {
                    UserManager.shared.logout()
                }
            }
        }
        
        self.dashboardViewModel.learningAlgoClosure = { algoResponse in
            DispatchQueue.main.async {
                if algoResponse.success {
                    if let data = algoResponse.data {
                        if data.course_type == .none {
                            if let labelresponse = self.dashboardViewModel.labelsResponseVO {
                                
                                let alert = UIAlertController(title: labelresponse.getLiteralof(code: DashboardLabelCode.information.rawValue).label_text, message: algoResponse.message,
                                                              preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                    print("ok")
                                    self.dashboardViewModel.resetAssessment()
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                                
                               // Utility.showAlert(title: labelresponse.getLiteralof(code: DashboardLabelCode.information.rawValue).label_text, message: algoResponse.message)
                            }
                            return
                        }
                        
                        if let _ = data.learninginfo {
                            let vc = Utility.getViewController(ofType: StagesViewController.self)
                            vc.modalPresentationStyle = .fullScreen
                            vc.setStageScreen(performanceDetail: nil, algoResponse: algoResponse, startDate: "", endDate: "", level: "")
                            self.present(vc, animated: true, completion: nil)
                        } else if let trailinfo = data.trialInfo {
                            if let vc =  LearningManager.getTrialController(info: trailinfo) {
                                self.present(vc, animated: true, completion: nil)
                            } else {
                                Utility.showAlert(title: "Information", message: "Trail Work under progress")
                            }
                        } else if let mandInfo = data.mandInfo {
                            
                            DispatchQueue.main.async {
                                let vc:MandViewController = Utility.getViewController(ofType: MandViewController.self)
                                vc.modalPresentationStyle = .fullScreen
                                vc.setResponse(algoResponse: algoResponse)
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    } else {
                        if let labelresponse = self.dashboardViewModel.labelsResponseVO {
                            Utility.showAlert(title: labelresponse.getLiteralof(code: DashboardLabelCode.information.rawValue).label_text, message: algoResponse.message)
                        }
                    }
                } else {
                    if let labelresponse = self.dashboardViewModel.labelsResponseVO {
                        Utility.showAlert(title: labelresponse.getLiteralof(code: DashboardLabelCode.information.rawValue).label_text, message: algoResponse.message)
                    }
                }
            }
        }
    }
    
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        self.resumeAssessmentButton.isHidden = false
        
        if let res = self.dashboardViewModel.dashboardPerformanceResponseVO {
            if res.assessment_status == .completed && res.learning_status != .started {
                self.resumeAssessmentButton.setTitle(labelresponse.getLiteralof(code: DashboardLabelCode.learning.rawValue).label_text, for: .normal)
            } else if res.assessment_status == .completed && res.learning_status == .started {
                self.resumeAssessmentButton.setTitle(labelresponse.getLiteralof(code: DashboardLabelCode.resumeLearning.rawValue).label_text, for: .normal)
            }
            else {
                if res.all_dates.count > 1 { self.resumeAssessmentButton.setTitle(labelresponse.getLiteralof(code: DashboardLabelCode.reassessment.rawValue).label_text, for: .normal)
                } else {
                self.resumeAssessmentButton.setTitle(labelresponse.getLiteralof(code: DashboardLabelCode.resumeAssessment.rawValue).label_text, for: .normal)
                }
            }
            if res.assessment_status == .completed {
                self.segmentedControl.isHidden = false
            } else {
                self.segmentedControl.isHidden = true
            }
        }
        courseType = .assessment

        self.segmentedControl.setTitle(labelresponse.getLiteralof(code: DashboardLabelCode.learning.rawValue).label_text, forSegmentAt: 0)
        self.segmentedControl.setTitle(labelresponse.getLiteralof(code: DashboardLabelCode.assessment.rawValue).label_text, forSegmentAt: 1)

        
    }

    private func setUplevelCustomization() {
        self.levelList = [
            DashboardLevel.init(backgroundColor: UIColor.init(red: 127.0/255.0, green: 69.0/255.0, blue: 240.0/255.0, alpha: 1), image: UIImage.init(named: "level1")!, textColor: .white),
            DashboardLevel.init(backgroundColor: UIColor.init(red: 255.0/255.0, green: 226.0/255.0, blue: 188.0/255.0, alpha: 1), image: UIImage.init(named: "level2")!, textColor: .black),
            DashboardLevel.init(backgroundColor: UIColor.init(red: 255.0/255.0, green: 208.0/255.0, blue: 215.0/255.0, alpha: 1), image: UIImage.init(named: "level3")!, textColor: .black),
            DashboardLevel.init(backgroundColor: UIColor.init(red: 219.0/255.0, green: 231.0/255.0, blue: 255.0/255.0, alpha: 1), image: UIImage.init(named: "level4")!, textColor: .black)
        ]
    }
    
    private func customSetting() {
        self.setUplevelCustomization()
        self.navigationController?.navigationBar.isHidden = true
                
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any]  , for: .normal)
        segmentedControl.selectedSegmentIndex = 1
        
        Utility.setView(view: self.resumeAssessmentButton, cornerRadius: 10, borderWidth: 0, color: .clear)

        levelCollectionView.register(DashboardLevelCell.nib, forCellWithReuseIdentifier: DashboardLevelCell.identifier)
        performanceCollectionView.register(DashboardSkillCell.nib, forCellWithReuseIdentifier: DashboardSkillCell.identifier)
        if let user = UserManager.shared.getUserInfo() {
            self.usernamLbl.text = Utility.deCrypt(text: user.nickname)
             self.avatarImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + user.avatar)
        }
    }
    private func addMenuView(labelResposne:ScreenLabelResponseVO) {
        self.menuVC.setDelegate(delegate: self, labelResponse:  labelResposne)
           menuVC.view.frame = CGRect.init(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
           self.view.addSubview(menuVC.view)
           self.menuVC.view.isHidden = true
       }
    
    private func showMenuView() {
        self.menuVC.view.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.menuVC.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
        }) { (finished) in
            self.isMenuVisible = true
        }
        
    }
    
    private func hideMenuView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.menuVC.view.frame = CGRect.init(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }) { (finished) in
            self.menuVC.view.isHidden = true
            self.isMenuVisible = false
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == levelCollectionView {
            if let history = self.selectedHistory {
            let width = self.levelCollectionView.frame.width / CGFloat(history.performanceList.count)
            return CGSize.init(width: width - 20 , height: self.levelCollectionView.frame.height-20)
            }
        }
        return CGSize.init(width: (self.performanceCollectionView.frame.width / 3) - 15, height: Utility.isRunningOnIpad() ? 85 : 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == levelCollectionView {
            if let history = self.selectedHistory {
                print("level count $$$$$$$$$$$$ == \(history.performanceList.count)")
                return history.performanceList.count
            }
        }
        else if collectionView == performanceCollectionView {
            if self.levelIndex >= 0 {
                if let history = self.selectedHistory {
                    return history.performanceList[levelIndex].performanceDetail.count
                }
            }
        }
        return 0
    }
    
    // make a cell for each cell index path
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == levelCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardLevelCell.identifier, for: indexPath) as! DashboardLevelCell
            if let history = self.selectedHistory {
                cell.setData(model: history.performanceList[indexPath.row], levelCount: history.performanceList.count)
            }
            cell.levelImageView.image = self.levelList[indexPath.row].image
            cell.backgroundColor = self.levelList[indexPath.row].backgroundColor
            
            if levelIndex == indexPath.row {
                Utility.setView(view: cell, cornerRadius: 15, borderWidth: 2, color: .black)
            } else {
                Utility.setView(view: cell, cornerRadius: 15, borderWidth: 0, color: .clear)
            }
            
            cell.levelLbl.textColor =  self.levelList[indexPath.row].textColor
            cell.messageLbl.textColor =  self.levelList[indexPath.row].textColor
            cell.completeLbl.textColor =  self.levelList[indexPath.row].textColor

            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardSkillCell.identifier, for: indexPath) as! DashboardSkillCell
        if let res = self.dashboardViewModel.dashboardPerformanceResponseVO,let history = self.selectedHistory {
            let model = history.performanceList[levelIndex].performanceDetail[indexPath.row]
            cell.setData(model: model, assessment_status: res.assessment_status,learning_status:res.learning_status, courseType: self.courseType)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if collectionView == self.levelCollectionView {
                let newLevel = indexPath.row
                if newLevel != self.levelIndex {
                    self.selectedLevelIndexPath = indexPath
                    self.levelIndex = newLevel
                }
            } else {
                
                if let history = self.selectedHistory {
                let model = history.performanceList[self.levelIndex].performanceDetail[indexPath.row]
                if model.assesment_status == .completed {
                    if let res = self.dashboardViewModel.dashboardPerformanceResponseVO {
                        if res.assessment_status == .completed {
                            let vc = Utility.getViewController(ofType: StagesViewController.self)
                            vc.modalPresentationStyle = .fullScreen
                            vc.setStageScreen(performanceDetail: model, algoResponse: nil, startDate: history.start_date, endDate: history.end_date, level: history.performanceList[self.levelIndex].title)
                            self.present(vc, animated: true, completion: nil)
                        } else {
                            if let labelresponse = self.dashboardViewModel.labelsResponseVO {
                            Utility.showAlert(title: labelresponse.getLiteralof(code: DashboardLabelCode.information.rawValue).label_text, message: labelresponse.getLiteralof(code: DashboardLabelCode.completeAssessment.rawValue).label_text)
                            }
                        }
                    }
                } 
                else if model.assesment_question {
                    if let labelresponse = self.dashboardViewModel.labelsResponseVO {
                    Utility.showAlert(title: labelresponse.getLiteralof(code: DashboardLabelCode.information.rawValue).label_text, message: labelresponse.getLiteralof(code: DashboardLabelCode.completeAssessment.rawValue).label_text)
                    }
                }
                }
                
            }
        }
    }
    
}

extension DashboardViewController: MenulistViewDelegate {
    func didClickOnBackground() {
        self.hideMenuView()
    }
    func didClickOnMenuItem(item:MenuItem) {
        self.hideMenuView()
       // var viewController: UIViewController?
        switch item {
        case .changeLanguage:
            DispatchQueue.main.async {

            let vc = Utility.getViewController(ofType: LanguageViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.setDelegate(delegate: self)
            self.present(vc, animated: true, completion: nil)
            }
        case .editprofile:
            DispatchQueue.main.async {
            let vc = Utility.getViewController(ofType: UserProfileViewController.self)
            vc.modalPresentationStyle = .fullScreen
            vc.isEditProfile = true
            self.present(vc, animated: true, completion: nil)
            }
            return
        case .logout:
            UserManager.shared.logout()
            return
        case .deleteAccount:
            showDeleteAccountAlert()
        default:
            break
        }
//        if let controller = viewController {
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
    }
    
    private func showDeleteAccountAlert() {
        if let response = self.dashboardViewModel.labelsResponseVO {
            let alert = UIAlertController(title: response.getLiteralof(code: DashboardLabelCode.information.rawValue).label_text, message: response.getLiteralof(code: DashboardLabelCode.deletemessage.rawValue).label_text, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: response.getLiteralof(code: DashboardLabelCode.ok.rawValue).label_text, style: UIAlertAction.Style.default, handler: {action in
                self.dashboardViewModel.deleteUserAccount()
            }))
            alert.addAction(UIAlertAction(title: response.getLiteralof(code: DashboardLabelCode.Cancel.rawValue).label_text, style: UIAlertAction.Style.default, handler: {action in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    
    }
}



extension DashboardViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

extension DashboardViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            //self.setData()
        }
    }
}
extension DashboardViewController: UIPopoverPresentationControllerDelegate {
    //UIPopoverPresentationControllerDelegate inherits from UIAdaptivePresentationControllerDelegate, we will use this method to define the presentation style for popover presentation controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
    }
     
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
     
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
    return true
    }
}

extension DashboardViewController: PopOverContentViewControllerDelegate {
    func selectedHistoryIndex(index:Int){
        if let response = self.dashboardViewModel.dashboardPerformanceResponseVO {
            let history = self.historyList.filter({ $0.title == response.all_dates[index].title })
            if history.count > 0 {
                self.popOverContentController.dismiss(animated: true, completion: nil)
                self.selectedHistory = history[0]
                let level = self.levelIndex
                self.levelIndex = level
            }
        }
    }
}

extension DashboardViewController: LanguageViewDelegate {
    func didChangeLanguage() {
        if let user = UserManager.shared.getUserInfo() {
            if user.languageCode != selectedLanguageModel.code {
              var userModel = user
                userModel.languageCode = selectedLanguageModel.code
                userModel.languageName = selectedLanguageModel.name
                userModel.languageImage = selectedLanguageModel.image
                UserManager.shared.saveUserInfo(userVO: userModel)
                self.dashboardViewModel.fetchDashboardScreenLabels()
            }
        }
    }

}
