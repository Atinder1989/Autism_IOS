//
//  StageView.swift
//  Stage
//
//  Created by IMPUTE on 18/12/19.
//  Copyright © 2019 Atinder. All rights reserved.
//

import UIKit

protocol StageViewDelegate {
    func didClickOnStageView(stage : StageView)
    func didClickOnProgressBar(stage : StageView,sender:UIView)

}

class StageView: UIView {

    private var lockImageView = UIImageView()
    private var stageNameBackgroundView = UIView()
    private var multiColorProgress : KATCircularProgress!
    private var nameTxtView = UITextView()
    private var percentLabel = UILabel()
    private var delegate: StageViewDelegate?

    var program: LearningProgramModel?
    var imageView = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        let xSpacing = Utility.isRunningOnIpad() ? 30 : 25
        self.imageView = UIImageView(frame: CGRect.init(x: xSpacing/2, y: 0, width: Int(frame.width)-xSpacing, height: Int(frame.height)-xSpacing))
        addSubview(imageView)
        
        let size = Utility.isRunningOnIpad() ? 50 : 35
        self.stageNameBackgroundView = UIView.init(frame: CGRect.init(x: 0, y: Int(frame.height) - size, width: Int(frame.width), height: size))
        Utility.setView(view: self.stageNameBackgroundView, cornerRadius: 5, borderWidth: 1, color: .black)
        stageNameBackgroundView.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        addSubview(stageNameBackgroundView)
        
        self.multiColorProgress = KATCircularProgress.init(frame: CGRect.init(x: Int(frame.width) - (size-5), y: Int(2.5), width: size-5, height: size-5))
        stageNameBackgroundView.addSubview(multiColorProgress)
        
        self.percentLabel = UILabel(frame: CGRect.init(x: Int(2.5), y: 5, width: size-10, height: size-10))
        self.percentLabel.textColor = .black
        self.percentLabel.textAlignment = .center
        self.percentLabel.numberOfLines = 0
        self.percentLabel.font = UIFont.systemFont(ofSize: Utility.isRunningOnIpad() ? 8 : 5)
        multiColorProgress.addSubview(self.percentLabel)

        let lockSize = Utility.isRunningOnIpad() ? 40 : 20
        let lockXAxis = Utility.isRunningOnIpad() ? Int(frame.width) - 40 : Int(frame.width) - 20
        self.lockImageView = UIImageView.init(frame: CGRect.init(x: lockXAxis, y: 5, width: lockSize, height: lockSize))
        self.lockImageView.image = UIImage.init(named: "lock")
        stageNameBackgroundView.addSubview(lockImageView)
        
        self.nameTxtView = UITextView(frame: CGRect.init(x: 0, y: 0, width: Int(frame.width) - size + 5, height: size))
        self.nameTxtView.textColor = .black
        self.nameTxtView.isUserInteractionEnabled = true
        self.nameTxtView.isEditable = false
        self.nameTxtView.isSelectable = false
        self.nameTxtView.textAlignment = .left
        self.nameTxtView.font = UIFont.boldSystemFont(ofSize: Utility.isRunningOnIpad() ? 12 : 8)
        self.nameTxtView.backgroundColor = .white
        stageNameBackgroundView.addSubview(self.nameTxtView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setData(name:String,program:LearningProgramModel?) {
        
        self.program = program
        if let p = program {
            self.tag = p.tag
            self.imageView.image = UIImage.init(named: p.program_image)
            self.stageNameBackgroundView.isHidden = false
            self.nameTxtView.text = p.program_name
            
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnStage(_:)))
//            self.addGestureRecognizer(tap)
            
            if p.isLocked {
                self.lockImageView.isHidden = false
                self.multiColorProgress.isHidden = true
                self.percentLabel.isHidden = true
                self.imageView.alpha = 0.5
            } else {
                self.lockImageView.isHidden = true
                self.multiColorProgress.isHidden = false
                self.percentLabel.isHidden = false
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnStage(_:)))
                self.addGestureRecognizer(tap)

//                let tapProgress = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnProgress(_:)))
//                self.multiColorProgress.addGestureRecognizer(tapProgress)
                            
                self.setProgressData(program: p)
                self.percentLabel.text = "0 %"
                if p.assement_attempt_status {
                    self.percentLabel.text = "\(p.assement_complete_rate)" + " %"
                }
                if p.trial_attempt_status {
                    self.percentLabel.text = "\(p.trial_complete_rate)" + " %"
                }
             
            }
            
        } else {
            self.stageNameBackgroundView.isHidden = true
            self.imageView.image = UIImage.init(named: name)
        }
    }
    
    func setDelegate(delegate:StageViewDelegate) {
        self.delegate = delegate
    }
    
    @objc private func handleTapOnStage(_ sender: UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.6,
            animations: { [weak self] in
                if let this = self {
                    this.transform = CGAffineTransform(scaleX: 2, y: 2)
                }
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6,
                    animations: { [weak self] in
                        if let this = self {
                            this.transform = CGAffineTransform.identity
                        }
                    },
                    completion: { [weak self] _ in
                                if let this = self,let del = this.delegate {
                                    del.didClickOnStageView(stage: this)
                                }
                })
        })
        
    }
    
    @objc private func handleTapOnProgress(_ sender: UITapGestureRecognizer? = nil) {
        if let del = self.delegate {
            if let s = sender,let v = s.view {
                del.didClickOnProgressBar(stage: self,sender: v)
            }
        }
    }
    
    private func setProgressData(program: LearningProgramModel) {
        self.multiColorProgress.sliceItems.removeAllObjects()
        
        var total:CGFloat  = 0.0
        if (program.assement_attempt_status) {
            let assessmentRate = Float(program.assement_complete_rate)
            total = total + CGFloat(assessmentRate)
            let assement_complete_rate_Item: SliceItem = SliceItem.init()
            assement_complete_rate_Item.itemColor = Utility.getAssessmentProgressColor(score: assessmentRate)
            assement_complete_rate_Item.itemValue = assessmentRate
            self.multiColorProgress.sliceItems.add(assement_complete_rate_Item)
        }
        if (program.trial_attempt_status) {
            self.multiColorProgress.sliceItems.removeAllObjects()
            let trial_complete_rate_Item: SliceItem = SliceItem.init()
            total = total + CGFloat(program.trial_complete_rate)
            trial_complete_rate_Item.itemColor = Utility.getAssessmentProgressColor(score: Float(program.trial_complete_rate))
            trial_complete_rate_Item.itemValue = Float(program.trial_complete_rate)
            self.multiColorProgress.sliceItems.add(trial_complete_rate_Item)
        }
        if self.multiColorProgress.sliceItems.count == 0  || total == 0.0 {
            let emptyItem: SliceItem = SliceItem.init()
            emptyItem.itemColor = .lightGray
            emptyItem.itemValue = Float(100)
            self.multiColorProgress.sliceItems.add(emptyItem)
        }
        
        self.multiColorProgress.lineWidth = 5.0
        self.multiColorProgress.setAnimationDuration(2)
        self.multiColorProgress.reloadData()
        
    }
    
    
}


