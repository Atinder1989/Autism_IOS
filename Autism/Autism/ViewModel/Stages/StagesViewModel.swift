//
//  StagesViewModel.swift
//  Stage
//
//  Created by IMPUTE on 18/12/19.
//  Copyright © 2019 Atinder. All rights reserved.
//

import Foundation

class StagesViewModel {
    var dataClosure : (() -> Void)?
    var tapOnStageClosure : ((_ program:LearningProgramModel) -> Void)?
    var tapOnProgressClosure : ((_ program:LearningProgramModel,_ sender:UIView) -> Void)?
    var noNetWorkClosure: (() -> Void)?

    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.tag = 1000
        v.frame = UIScreen.main.bounds
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private var stagesCoordinateList = [StageModel]()
    
    var labelsResponseVO: ScreenLabelResponseVO?
    var programResponseVO: LearningSkillProgramResponseVO? = nil {
        didSet {
                if let closure = self.dataClosure {
                    closure()
                }
        }
    }
    
    func setProgramResponseData(algoResponse:AlgorithmResponseVO) {
        if let detail = algoResponse.skillprogramDetail {
            var programResponse = LearningSkillProgramResponseVO()
            programResponse.id = detail.id
            programResponse.skill_domain_id = detail.skill_domain_id
            programResponse.skill_domain_image = detail.skill_domain_image
            programResponse.learningProgramList = detail.learningProgramList
            self.programResponseVO = programResponse
        }
    }
    
    func fetchDashboardScreenLabels() {
        
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                       noNetwork()
            }
            return
        }
          var service = Service.init(httpMethod: .POST)
          service.url = ServiceHelper.screenLabelUrl()
        if let user = UserManager.shared.getUserInfo() {
          service.params = [
              ServiceParsingKeys.screen_id.rawValue:ScreenLabel.modules_name.rawValue,
              ServiceParsingKeys.language.rawValue:user.languageCode
          ]
        }
          
          ServiceManager.processDataFromServer(service: service, model: ScreenLabelResponseVO.self) { (responseVo, error) in
              if let e = error {
                  print(e.localizedDescription)
                  self.labelsResponseVO = nil
              } else {
                  if let response = responseVo {
                      self.labelsResponseVO = response
                  }
              }
          }
      }

    
    func getLearningSkillProgramList(performanceDetail:PerformanceDetail,startDate:String,endDate:String) {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getLearningSkillProgram()
        if let user = UserManager.shared.getUserInfo() {
            service.params = [
              ServiceParsingKeys.language_code.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue:user.id,
                ServiceParsingKeys.skill_domain_id.rawValue:performanceDetail.skill_domain_id,
                ServiceParsingKeys.level.rawValue:performanceDetail.level,
                ServiceParsingKeys.start_date.rawValue:startDate,
                ServiceParsingKeys.end_date.rawValue:endDate
            ]
        }
        ServiceManager.processDataFromServer(service: service, model: LearningSkillProgramResponseVO.self) { (responseVo, error) in
            if let e = error {
                print("Error = ", e.localizedDescription)
                self.programResponseVO = nil
            } else {
                if let res = responseVo {
                    self.programResponseVO = res
                }
            }
        }
    }
     
    func getStagesView() -> UIScrollView {
        self.resetComponents()
        self.stagesCoordinateList =  self.getForestStagesListCoordinates()
        self.addStagesOnScrollView()
        return scrollView
    }
}
// MARK: Private Methods
extension StagesViewModel {
    private func resetComponents() {
        self.stagesCoordinateList.removeAll()
        for subview in self.scrollView.subviews{
            subview.removeFromSuperview()
        }
    }
    
    // MARK: Animal Stage Methods
    private func getForestStagesListCoordinates() -> [StageModel] {
        let size = 160
        var list = [StageModel]()
        list = [
            LearningStage.init(frame: CGRect.init(x: 20, y: 40, width: size, height: size), image: .start, program: nil),
            LearningStage.init(frame: CGRect.init(x: (Int(UIScreen.main.bounds.size.width / 2)-100), y: 100, width: size, height: size), image: .none, program: nil),
            LearningStage.init(frame: CGRect.init(x: Int(UIScreen.main.bounds.size.width - 300), y: 200, width: size, height: size), image: .none, program: nil),
            LearningStage.init(frame: CGRect.init(x: 100 , y: Int(UIScreen.main.bounds.size.height - 480), width: size, height: size), image: .none, program: nil),
            LearningStage.init(frame: CGRect.init(x: 140, y: Int(UIScreen.main.bounds.size.height - 180), width: size, height: size), image: .none, program: nil),
            LearningStage.init(frame: CGRect.init(x: Int(UIScreen.main.bounds.size.width/2), y: Int(UIScreen.main.bounds.size.height/2) + 70, width: size, height: size), image: .none, program: nil),
            LearningStage.init(frame: CGRect.init(x: Int(UIScreen.main.bounds.size.width - CGFloat((size+20))) , y: Int(UIScreen.main.bounds.size.height - CGFloat((size+20))), width: size, height: size), image: .goal, program: nil)
        ]
        if let response = self.programResponseVO {
            let imageArray = ["","cat","lion","panda","rabbit","tortoise",""]
            var array = [StageModel]()
            for i in 0...list.count-1 {
                let model = list[i]
                if i == 0 || i == list.count - 1 {
                    array.append(model)
                } else {
                    if i <= response.learningProgramList.count {
                        print("Tag == \(i)")
                        var program = response.learningProgramList[i-1]
                        program.tag = 100 + i
                        program.program_image = imageArray[i]
                        let model = LearningStage.init(frame: model.stageView.frame, image: .none, program: program)
                        array.append(model)
                    }
                }
            }
            return array
        }
        return list
    }
  
    // MARK: Add Stages On Scrollview Methods
    private  func addStagesOnScrollView() {
        let scrollViewContentSize:CGFloat=0;
        for (currentIndex) in (0..<stagesCoordinateList.count) {
            let currentStage:StageModel = stagesCoordinateList[currentIndex]
           // if type == .forest {
                if currentIndex < stagesCoordinateList.count - 1 {
                    let startPoint = currentStage.stageView.center
                    let nextStage:StageModel = stagesCoordinateList[currentIndex+1]
                    let endPoint = nextStage.stageView.center
                    self.drawLine(fromPoint: startPoint, toPoint: endPoint)
                }
           // }
            currentStage.stageView.setDelegate(delegate: self)
            scrollView.addSubview(currentStage.stageView)
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: scrollViewContentSize)
        }
    }
    
    // MARK: Draw Line Methods
    private func drawLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [start, end])
        shapeLayer.path = path
        self.scrollView.layer.addSublayer(shapeLayer)
    }
}

extension StagesViewModel: StageViewDelegate {
    func didClickOnStageView(stage: StageView) {
        if let program = stage.program {
            if let closure = self.tapOnStageClosure {
                closure(program)
            }
        }
    }
    
    func didClickOnProgressBar(stage : StageView,sender:UIView) {
        if let program = stage.program {
            if let closure = self.tapOnProgressClosure {
                closure(program,sender)
            }
        }
    }
}




