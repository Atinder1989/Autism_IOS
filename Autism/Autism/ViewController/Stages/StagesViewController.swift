//
//  AnimalStageViewController.swift
//  Autism
//
//  Created by IMPUTE on 15/02/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class StagesViewController: UIViewController {
    private var stageViewModel = StagesViewModel()
    private var performanceDetail: PerformanceDetail?
    private var algoResponse:AlgorithmResponseVO?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    private var index = 0
    var level = ""
    private var startDate = "";
    private var endDate = "";

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        if let detail = self.performanceDetail {
            stageViewModel.fetchDashboardScreenLabels()
            stageViewModel.getLearningSkillProgramList(performanceDetail: detail, startDate: self.startDate, endDate: self.endDate)
        } else if let algoResponse = self.algoResponse {
            if(ServiceHelper.baseURL != ServiceEnvironment.DevelopmentNew) {//New Development
                self.view.isUserInteractionEnabled = false
                stageViewModel.fetchDashboardScreenLabels()
                stageViewModel.setProgramResponseData(algoResponse: algoResponse)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            if(ServiceHelper.baseURL == ServiceEnvironment.DevelopmentNew) {//New Development
                self.executeAutomaticLearning()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func homeClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 }
//MARK:- Public Methods
extension StagesViewController {
    func setStageScreen(performanceDetail:PerformanceDetail?,algoResponse:AlgorithmResponseVO?,startDate:String,endDate:String,level:String) {
        self.performanceDetail = performanceDetail
        self.algoResponse = algoResponse
        self.startDate = startDate
        self.endDate = endDate
        self.level = level
    }
}


//MARK:- Private Methods
extension StagesViewController {
    private func handleAutomaticAnimation() {
        if let algoresponse = self.algoResponse {
        if let data = algoresponse.data, let info = data.learninginfo, let detail = algoresponse.skillprogramDetail {
            if index < detail.learningProgramList.count {
                let program = detail.learningProgramList[index]
                if info.program_id != program.program_id {
                    self.findStageViewOnScreen(isRecursive: true)
                } else {
                    self.findStageViewOnScreen(isRecursive: false)
                }
            }
        }
        }
    }
    
    private func findStageViewOnScreen(isRecursive:Bool) {
        for subview in self.view.subviews {
            if let scrollview = subview as? UIScrollView {
                for sView in scrollview.subviews {
                    if let stage = sView as? StageView {
                        print("Index ==== \(index)")
                        if stage.tag == index + 101 {
                            print(stage.program!.program_id)
                            self.startAutomaticAnimation(stageView: stage, isRecursive: isRecursive)
                            break
                        }
                    }
                }
            }
        }
    }
    
    private func startAutomaticAnimation(stageView:StageView,isRecursive:Bool) {
        UIView.animate(withDuration: 0.6,
            animations: {
                stageView.transform = CGAffineTransform(scaleX: 2, y: 2)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6,
                    animations: {
                        stageView.transform = CGAffineTransform.identity
                    },
                    completion: { [self] _ in
                        self.index = self.index + 1
                        print("Updated Index ==== \(index)")
                        if isRecursive {
                            self.handleAutomaticAnimation()
                        } else {
                            DispatchQueue.main.async {
                                self.executeAutomaticLearning()
                            }
                        }
                })
        })
    }
    private func addStagesView(response:LearningSkillProgramResponseVO) {
        let stagesView = self.stageViewModel.getStagesView()
        self.view.addSubview(stagesView)
        self.backgroundImageView.image = UIImage.init(named: "stagebg")
        self.backgroundImageView.isHidden = false
        self.homeButton.isHidden = false
        self.view.bringSubviewToFront(self.homeButton)
    }
    
    private func listenModelClosures() {
        self.stageViewModel.noNetWorkClosure = {
           // Utility.showRetryView(delegate: self)
        }
        
        self.stageViewModel.dataClosure = {
            DispatchQueue.main.async {
                if let response = self.stageViewModel.programResponseVO {
                    self.setData(response: response)
                    self.addStagesView(response: response)
                    self.handleAutomaticAnimation()
                }
            }
        }
        
        self.stageViewModel.tapOnStageClosure = { program in
            DispatchQueue.main.async { [weak self] in
                if let response = self?.stageViewModel.programResponseVO {
                    if let this = self {
                    if this.startDate.count == 0 && this.endDate.count == 0 {
                    if let vc =  LearningManager.getLearningScriptController(skill_domain_id: response.skill_domain_id, program: program, command_array: [], questionId: "") {
                        this.dismiss(animated: false, completion: {
                            if let topvc = UIApplication.topViewController() {
                            topvc.present(vc, animated: true, completion: {
                                LearningManager.setLastVC(vc: vc)
                            })
                            }
                        })
                            
                        
                    } else  {
                        Utility.showAlert(title: "Information", message: "Learning Work under progress")
                        UserManager.shared.exitAssessment()
                    }
                    }
                    }
                }
            }
        }
        
        self.stageViewModel.tapOnProgressClosure = { program,sender in
            DispatchQueue.main.async {
                let total = program.assement_complete_rate + program.learning_complete_rate + program.trial_complete_rate
                if total > 0 {
                let size = CGSize(width: 500, height: 500)
                let vc = Utility.getViewController(ofType: StagesPopUpViewController.self)
                vc.modalPresentationStyle = .popover
                vc.preferredContentSize = size
                    vc.setProgram(program: program, size: size, labelResponse: self.stageViewModel.labelsResponseVO)
                self.showPopOverView(sourceView: sender, vc: vc)
                }
            }
        }
    }
    
    private func showPopOverView(sourceView:UIView,vc:UIViewController) {
         if let popoverPresentationController = vc.popoverPresentationController {
         popoverPresentationController.permittedArrowDirections = .any
         popoverPresentationController.sourceView = sourceView
         popoverPresentationController.sourceRect = sourceView.bounds
         popoverPresentationController.delegate = self
         present(vc, animated: true, completion: nil)
         }
     }
    
    private func setData(response:LearningSkillProgramResponseVO?) {
        if let detail = self.performanceDetail {
            self.titleLabel.text = detail.key
            self.levelLabel.text = level
        } else if let algo = algoResponse ,let data = algo.data, let info = data.learninginfo  {
            self.levelLabel.text = info.level
            if algo.showSkillprogram {
                if let detail  = algo.skillprogramDetail {
                    self.titleLabel.text = detail.skill_domain_name
                }
            }
        } else if let res = response {
            self.titleLabel.text = res.skill_domain_name
        }
    }
    
    private func executeAutomaticLearning() {
        if let algoResponse = self.algoResponse {
        if let data = algoResponse.data,let info = data.learninginfo  {
            var program = LearningProgramModel.init()
            program.program_id = info.program_id
            
            program.course_type = info.course_type
            program.content_type = info.content_type
            program.bucket = info.bucket
            program.index = info.index
            program.table_name = info.table_name
            program.level = info.level

        if let code =  ProgramCode.init(rawValue: info.label_code) {
                program.label_code = code
        } else {
                program.label_code = .none
        }
         
        weak var weakSelf = self
        if let vc =  LearningManager.getLearningScriptController(skill_domain_id: info.skill_domain_id, program: program, command_array: info.command_array, questionId: info.question_id) {
            if let this = weakSelf {
                this.dismiss(animated: false, completion: {
                    if let topvc = UIApplication.topViewController() {
                    topvc.present(vc, animated: true, completion: {
                        LearningManager.setLastVC(vc: vc)
                    })
                    }
                })
            }
        } else {
            Utility.showAlert(title: "Information", message: "Learning Work under progress")
            UserManager.shared.exitAssessment()
        }
            
        }
        }
    }

}

extension StagesViewController: UIPopoverPresentationControllerDelegate {
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

