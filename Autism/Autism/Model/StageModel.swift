//
//  StageModel.swift
//  Stage
//
//  Created by IMPUTE on 18/12/19.
//  Copyright © 2019 Atinder. All rights reserved.
//

import Foundation
import UIKit

protocol StageModel {
    var stageView: StageView {get set}
}

struct LearningStage: StageModel {
    var stageView : StageView
    init(frame:CGRect,image:ForestStageImage,program:LearningProgramModel?) {
        let sView = StageView.init(frame: frame)
        sView.setData(name: image.rawValue, program: program)
        self.stageView = sView
    }
}


