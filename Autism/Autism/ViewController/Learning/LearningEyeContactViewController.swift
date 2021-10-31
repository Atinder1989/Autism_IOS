//
//  LearningEyeContactViewController.swift
//  Autism
//
//  Created by Savleen on 29/03/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class LearningEyeContactViewController: UIViewController {
    private let eyeContactViewModal: LearningEyeContactViewModel = LearningEyeContactViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var avatarCenterImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarLeftImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarRightImageView: FLAnimatedImageView!

    @IBOutlet weak var skipLearningButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.skipLearningButton.isHidden = isSkipLearningHidden
        self.customSetting()
        if self.command_array.count == 0 {
            self.eyeContactViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.eyeContactViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipLearningClicked(_ sender: Any) {
        self.eyeContactViewModal.stopAllCommands()
        self.eyeContactViewModal.skipLearningSubmitLearningMatchingAnswer()
    }
}

//MARK:- Public Methods
extension LearningEyeContactViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()

        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.eyeContactViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
        }
    }
}

//MARK:- Private Methods
extension LearningEyeContactViewController {
    
    private func customSetting() {
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  talkingGif
        self.avatarLeftImageView.animatedImage =  talkingGif
        self.avatarRightImageView.animatedImage =  talkingGif
        self.avatarCenterImageView.isHidden = true
        self.avatarLeftImageView.isHidden = true
        self.avatarRightImageView.isHidden = true

    }
    
    
    private func listenModelClosures() {
       self.eyeContactViewModal.clearScreenClosure = {
            DispatchQueue.main.async {
                self.customSetting()
                self.eyeContactViewModal.updateCurrentCommandIndex()
            }
       }
        
       self.eyeContactViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
                
       self.eyeContactViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.eyeContactViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
        
       self.eyeContactViewModal.showAvatarClosure = { commandInfo in
           DispatchQueue.main.async {
            if let option = commandInfo.option {
                self.avatarCenterImageView.isHidden = true
                self.avatarLeftImageView.isHidden = true
                self.avatarRightImageView.isHidden = true
                
                if option.Position == ScriptCommandOptionType.center.rawValue {
                    self.avatarCenterImageView.isHidden = false
                }
            }
           }
       }
           
       self.eyeContactViewModal.talkAvatarClosure = { commandInfo in
             DispatchQueue.main.async {
                if let option = commandInfo.option {
                    if option.Position == ScriptCommandOptionType.center.rawValue {
                        self.avatarCenterImageView.isHidden = false
                    } else if option.Position == ScriptCommandOptionType.right.rawValue {
                        self.avatarRightImageView.isHidden = false
                    } else if option.Position == ScriptCommandOptionType.left.rawValue {
                        self.avatarLeftImageView.isHidden = false
                    }
                }
             }
       }
        
       self.eyeContactViewModal.hideAvatarClosure = { commandInfo in
              DispatchQueue.main.async {
                if let option = commandInfo.option {
                    if option.Position == ScriptCommandOptionType.center.rawValue {
                        self.avatarCenterImageView.isHidden = true
                    } else if option.Position == ScriptCommandOptionType.right.rawValue {
                        self.avatarRightImageView.isHidden = true
                    } else if option.Position == ScriptCommandOptionType.left.rawValue {
                        self.avatarLeftImageView.isHidden = true
                    }
                }
             }
       }
   }
  
 }

extension LearningEyeContactViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

