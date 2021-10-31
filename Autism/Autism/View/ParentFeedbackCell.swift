//
//  ParentFeedbackCell.swift
//  Autism
//
//  Created by Savleen on 11/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol ParentFeedbackCellDelegate:NSObject {
    func didClickOnQuestionMark(sender:UIButton,optionModel:ProgramTypeModel)
    func didUpdateFeedbackList(feedbackModel: ParentFeedbackModel)
    func didClickOnNext()
    func didClickOnPrevious()
}

class ParentFeedbackCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var levelListTableView: UITableView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    private var parentFeedbackModel: ParentFeedbackModel?
    private weak var delegate: ParentFeedbackCellDelegate?
    private var lableResponse: ScreenLabelResponseVO!
    private var isAnythingMissing = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Utility.setView(view: self.btnNext, cornerRadius: 30, borderWidth: 0.5, color: .darkGray)
        Utility.setView(view: self.btnPrevious, cornerRadius: 30, borderWidth: 0.5, color: .darkGray)
        self.levelListTableView.dataSource = self
        self.levelListTableView.delegate = self
        levelListTableView.register(ParentFeebackOptionCell.nib, forCellReuseIdentifier: ParentFeebackOptionCell.identifier)
        levelListTableView.tableFooterView = UIView.init()
    }
    
    func setData(feedbackModel:ParentFeedbackModel,delegate:ParentFeedbackCellDelegate,lableResponse:ScreenLabelResponseVO) {
        self.delegate = delegate
        self.lableResponse = lableResponse
        self.parentFeedbackModel = feedbackModel
        self.titleLabel.text = feedbackModel.skill_name
        self.changeNextButtonState()
        DispatchQueue.main.async {
            self.levelListTableView.reloadData()
        }
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        if !isAnythingMissing {
            if let del = self.delegate {
                del.didClickOnNext()
            }
        }
    }
    
    @IBAction func previousClicked(_ sender: Any) {
        if let del = self.delegate {
            del.didClickOnPrevious()
        }
    }
    
    private func changeNextButtonState() {
        isAnythingMissing = false
             if let feedbackModel = self.parentFeedbackModel {
                 for model in feedbackModel.programTypeList {
                     if !model.isrowDisable {
                         if !model.isYes && !model.isNo && !model.isDontKnow {
                             isAnythingMissing = true
                             break
                         }
                     }
                 }
             }
             if isAnythingMissing {
                self.btnNext.setBackgroundImage(UIImage.init(named: "skipDisabled"), for: .normal)
             } else {
                self.btnNext.setBackgroundImage(UIImage.init(named: "skip"), for: .normal)
             }
    }
}

// MARK: UITableview Delegates And Datasource Methods
extension ParentFeedbackCell : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = self.parentFeedbackModel {
            return model.programTypeList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentFeebackOptionCell.identifier) as! ParentFeebackOptionCell
        cell.selectionStyle = .none
        if let model = self.parentFeedbackModel {
            let programeType = model.programTypeList[indexPath.row]
            cell.setData(delegate: self, model: programeType, labelResponse: self.lableResponse)
       }
        return cell
    }
}

extension ParentFeedbackCell: ParentFeebackOptionCellDelegate {
    func didClickOn(buttonType:OptionButtonType,model:ProgramTypeModel,sender:UIButton) {
        var index = -1
        if let feedbackModel = self.parentFeedbackModel {
           for (i, m) in feedbackModel.programTypeList.enumerated() {
                if m.id == model.id {
                    index = i
                    break
                }
            }
        }
        var newModel = ProgramTypeModel.init(id: model.id, description: model.description, name: model.name, question: model.question, info: model.info, yes: false, no: false, dontKnow: false, isrowDisable: true)
        switch buttonType {
        case .questionMark:
            if let del = self.delegate {
                     del.didClickOnQuestionMark(sender: sender, optionModel: model)
                }
            return
        case .yes:
            newModel.isYes = true
            newModel.isrowDisable = false
            break
        case .no:
            newModel.isNo = true
            break
        case .dontKnow:
            newModel.isDontKnow = true
            break
        }
        
        if let feedbackModel = self.parentFeedbackModel {
            var fModel = feedbackModel
            fModel.programTypeList.remove(at: index)
            fModel.programTypeList.insert(newModel, at: index)
            
            if newModel.isYes {
                 let newIndex = index + 1
                print(fModel.programTypeList.count)
                if newIndex != fModel.programTypeList.count {
                    var nextModel = fModel.programTypeList[newIndex]
                    nextModel.isrowDisable = false
                    fModel.programTypeList.remove(at: newIndex)
                    fModel.programTypeList.insert(nextModel, at: newIndex)
                }
            } else {
                var programList = [ProgramTypeModel]()
                var firstRowModel = fModel.programTypeList[0]
                firstRowModel.isrowDisable = false
                programList.append(firstRowModel)
                
                for i in 0..<fModel.programTypeList.count {
                    var programModel = fModel.programTypeList[i]
                    if i != 0 {
                        if i > index {
                            programModel.isYes = false
                            programModel.isNo = false
                            programModel.isDontKnow = false
                            programModel.isrowDisable = true
                            programList.append(programModel)
                        } else {
                            programModel.isrowDisable = false
                            programList.append(programModel)
                        }
                    }
                }
                fModel.programTypeList = programList
            }
            self.parentFeedbackModel = fModel
            if let del = self.delegate {
                del.didUpdateFeedbackList(feedbackModel: fModel)
            }
        }
        self.changeNextButtonState()
        DispatchQueue.main.async {
            self.levelListTableView.reloadData()
        }
    }
}
