//
//  StagesPopUpViewController.swift
//  Autism
//
//  Created by Savleen on 10/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class StagesPopUpViewController: UIViewController {
    private var pieChart: PNPieChart!
    private var popupSize: CGSize!
    private var program:LearningProgramModel!
    private var labelsResponseVO: ScreenLabelResponseVO?
    @IBOutlet weak var lblTitle: UILabel!
    private let height:CGFloat = 200.0
    private let lightGreycolor:UIColor = UIColor.init(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        addAssessmentPieChart()
        addLearningPieChart()
        addTrailPieChart()
    }
}

//MARK:- Public Methods
extension StagesPopUpViewController {
    func setProgram(program:LearningProgramModel,size:CGSize,labelResponse:ScreenLabelResponseVO?) {
        self.program = program
        self.popupSize = size
        self.labelsResponseVO = labelResponse
    }
}

//MARK:- Private Methods
extension StagesPopUpViewController {
    private func addAssessmentPieChart() {
        self.lblTitle.text = self.program.program_name
        var items:[PNPieChartDataItem] = []
        if let labelResponse = self.labelsResponseVO {
            let item = PNPieChartDataItem.init(value: CGFloat(program.assement_complete_rate), color:
                                                Utility.getAssessmentProgressColor(score: Float(program.assement_complete_rate)), description: labelResponse.getLiteralof(code: ModuleNameLabelCode.assessment.rawValue).label_text)
            items.append(item!)
        
        if program.assement_complete_rate < 100 {
            let difference:CGFloat = 100.0 - CGFloat(program.assement_complete_rate)
            let item = PNPieChartDataItem.init(value: difference, color: lightGreycolor, description: "")
            items.append(item!)
        }
        }
        
        let font = UIFont.boldSystemFont(ofSize: 12.0)
        pieChart = PNPieChart(frame: CGRect(x: 25, y: 60, width: height, height: height), items: items)
        pieChart.descriptionTextColor = UIColor.black
        pieChart.descriptionTextFont = font
        pieChart.descriptionTextShadowColor = UIColor.clear
        pieChart.showAbsoluteValues = true
        pieChart.showOnlyValues = false
        pieChart.stroke()
        pieChart.legendStyle = .serial
        pieChart.legendFont = font
//        let legend = self.pieChart.getLegendWithMaxWidth(self.popupSize.width)
//        legend?.frame = CGRect.init(x: 0, y: 300, width: self.popupSize.width, height: self.popupSize.height)
//        self.view.addSubview(legend!)
        self.view.addSubview(self.pieChart)
    }
    
    private func addLearningPieChart() {
        self.lblTitle.text = self.program.program_name
        var items:[PNPieChartDataItem] = []
        if let labelResponse = self.labelsResponseVO {
            let item = PNPieChartDataItem.init(value: CGFloat(program.learning_complete_rate), color:
                                                Utility.getAssessmentProgressColor(score: Float(program.learning_complete_rate)), description: labelResponse.getLiteralof(code: ModuleNameLabelCode.learning.rawValue).label_text)
            items.append(item!)
        
        if program.learning_complete_rate < 100 {
            let difference:CGFloat = 100.0 - CGFloat(program.learning_complete_rate)
            let item = PNPieChartDataItem.init(value: difference, color: lightGreycolor, description: "")
            items.append(item!)
        }
        }
        
        let font = UIFont.boldSystemFont(ofSize: 12.0)
        pieChart = PNPieChart(frame: CGRect(x: 275, y: 60, width: height, height: height), items: items)
        pieChart.descriptionTextColor = UIColor.black
        pieChart.descriptionTextFont = font
        pieChart.descriptionTextShadowColor = UIColor.clear
        pieChart.showAbsoluteValues = true
        pieChart.showOnlyValues = false
        pieChart.stroke()
        pieChart.legendStyle = .serial
        pieChart.legendFont = font
//        let legend = self.pieChart.getLegendWithMaxWidth(self.popupSize.width)
//        legend?.frame = CGRect.init(x: 0, y: 300, width: self.popupSize.width, height: self.popupSize.height)
//        self.view.addSubview(legend!)
        self.view.addSubview(self.pieChart)
    }
    
    private func addTrailPieChart() {
        self.lblTitle.text = self.program.program_name
        var items:[PNPieChartDataItem] = []
        if let labelResponse = self.labelsResponseVO {
            let item = PNPieChartDataItem.init(value: CGFloat(program.trial_complete_rate), color:
                                                Utility.getAssessmentProgressColor(score: Float(program.trial_complete_rate)), description: labelResponse.getLiteralof(code: ModuleNameLabelCode.trial.rawValue).label_text)
            items.append(item!)
        
        if program.trial_complete_rate < 100 {
            let difference:CGFloat = 100.0 - CGFloat(program.trial_complete_rate)
            let item = PNPieChartDataItem.init(value: difference, color: lightGreycolor, description: "")
            items.append(item!)
        }
        }
        
        let font = UIFont.boldSystemFont(ofSize: 12.0)
        pieChart = PNPieChart(frame: CGRect(x: 150, y: 280, width: height, height: height), items: items)
        pieChart.descriptionTextColor = UIColor.black
        pieChart.descriptionTextFont = font
        pieChart.descriptionTextShadowColor = UIColor.clear
        pieChart.showAbsoluteValues = true
        pieChart.showOnlyValues = false
        pieChart.stroke()
        pieChart.legendStyle = .serial
        pieChart.legendFont = font
//        let legend = self.pieChart.getLegendWithMaxWidth(self.popupSize.width)
//        legend?.frame = CGRect.init(x: 0, y: 300, width: self.popupSize.width, height: self.popupSize.height)
//        self.view.addSubview(legend!)
        self.view.addSubview(self.pieChart)
    }
    
}
