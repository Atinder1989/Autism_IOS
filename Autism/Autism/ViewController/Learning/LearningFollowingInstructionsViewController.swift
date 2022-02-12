//
//  LearningFollowingInstructionsViewController.swift
//  Autism
//
//  Created by Savleen on 02/06/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class LearningFollowingInstructionsViewController: UIViewController {
    private let commandViewModal: LearningFollowingInstructionsViewModel = LearningFollowingInstructionsViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private let itemSize:CGFloat = 350
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var imagesCollectionView: UICollectionView!

    private var imageList = [AnimationImageModel]()
    private var command_array: [ScriptCommandInfo] = []
    private var isChildAction = false

    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var avatarCenterImageView: FLAnimatedImageView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCollectionViewCell()
        self.customSetting()
        if self.command_array.count == 0 {
            self.commandViewModal.fetchLearningQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    

    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.commandViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
    
   
}

//MARK:- Public Methods
extension LearningFollowingInstructionsViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()

        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.commandViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
        }
    }
}

//MARK:- Private Methods
extension LearningFollowingInstructionsViewController {
    private func registerCollectionViewCell() {
        imagesCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    private func initializeFrame() {
        let width:CGFloat = 300
        let height:CGFloat = 360
        let xAxis:CGFloat = (UIScreen.main.bounds.width/2) - (width/2)
        let yAxis:CGFloat = (UIScreen.main.bounds.height/2) - (height/2)
        self.avatarCenterImageView.frame = CGRect.init(x: xAxis, y: yAxis, width: width, height: height)
    }
    private func customSetting() {
        initializeFrame()
        isChildAction = false
        self.speechTitle.text = ""
        self.avatarCenterImageView.animatedImage =  getIdleGif()
        self.avatarCenterImageView.isHidden = true
        self.imagesCollectionView.isHidden = true
        self.imageList = []
    }
   
    
    private func listenModelClosures() {
       self.commandViewModal.clearScreenClosure = {
            DispatchQueue.main.async {
                self.customSetting()
                self.commandViewModal.updateCurrentCommandIndex()
            }
       }
        
       self.commandViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.commandViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async { [weak self] in
                if let this = self {
                    this.speechTitle.text = text
                }
            }
       }
        
       self.commandViewModal.showAvatarClosure = { commandInfo in
           DispatchQueue.main.async { [weak self] in
            if let option = commandInfo.option,let this = self {
                if option.Position == ScriptCommandOptionType.center.rawValue {
                    this.avatarCenterImageView.isHidden = false
                }
            }
           }
       }
        
        self.commandViewModal.talkAvatarClosure = { commandInfo in
              DispatchQueue.main.async {  [weak self] in
                 if let option = commandInfo.option,let this = self  {
                     if option.Position == ScriptCommandOptionType.center.rawValue {
                        this.avatarCenterImageView.isHidden = false
                        this.avatarCenterImageView.animatedImage =  getTalkingGif()
                     }
                 }
              }
        }
        
        self.commandViewModal.moveAvatarClosure = { commandInfo in
              DispatchQueue.main.async { [weak self] in
                 if let option = commandInfo.option,let this = self {
                     if option.avatar_move == ScriptCommandOptionType.center_to_right.rawValue {
                        this.centerToleftAnimation()
                     }
                 }
              }
        }
        
        self.commandViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                self.isChildAction = state
             }
        }
        
        self.commandViewModal.showImageClosure = { questionInfo in
             DispatchQueue.main.async { [weak self] in
                 if let this = self {
                    var model:AnimationImageModel = AnimationImageModel()
                    model.url = questionInfo.value
                    model.value_id = questionInfo.value_id
                    this.imageList.append(model)
                    this.imagesCollectionView.isHidden = false
                    this.collectionViewWidthConstraint.constant = this.itemSize * CGFloat(this.imageList.count)
                    this.imagesCollectionView.reloadData()
                 }
             }
        }
        
                self.commandViewModal.blinkImageClosure = { questionInfo in
                    DispatchQueue.main.async { [weak self] in
                        if let this = self {
                            var findIndex = -1
                            for (index, element) in this.imageList.enumerated() {
                                if element.value_id == questionInfo.value_id {
                                    findIndex = index
                                    break
                                }
                            }
                            var updatedElement = this.imageList[findIndex]
                            updatedElement.isBlink = true
                            this.imageList.remove(at: findIndex)
                            this.imageList.insert(updatedElement, at: findIndex)
                            this.imagesCollectionView.reloadData()
                        }
                    }
                }
   }
        
    private func blinkImage(count:Int,imageView:UIImageView) {
        if count == 0 {
            for (index,element) in self.imageList.enumerated() {
                var model:AnimationImageModel = AnimationImageModel()
                model = element
                model.isBlink = false
                self.imageList.remove(at: index)
                self.imageList.insert(model, at: index)
            }
            return
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, animations: {
                    imageView.alpha = 0.2
                }) { [weak self] finished in
                    if let this = self {
                    imageView.alpha = 1
                        this.blinkImage(count: count - 1,imageView:imageView)
                    }
                }
        }
    }
     
    private func centerToleftAnimation()
    {
        DispatchQueue.main.async { [weak self] in
            if let this = self {
            let xAxis:CGFloat = UIScreen.main.bounds.width - this.avatarCenterImageView.frame.width - 50
            UIView.animate(withDuration: 1, animations: {
                this.avatarCenterImageView.frame = CGRect.init(x: xAxis, y: this.avatarCenterImageView.frame.origin.y, width: this.avatarCenterImageView.frame.width, height: this.avatarCenterImageView.frame.height)
            }) {  finished in
                this.commandViewModal.updateCurrentCommandIndex()
            }
                
            }

        }
     }

 }

extension LearningFollowingInstructionsViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


extension LearningFollowingInstructionsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       return CGSize(width: itemSize - 20, height: self.imagesCollectionView.frame.height-20)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageList.count
    }
    
    // make a cell for each cell index path
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        let model = self.imageList[indexPath.row]
        cell.dataImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl()+model.url)
        if model.isBlink {
            self.blinkImage(count: 2, imageView: cell.dataImageView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isChildAction {
            return
        }
        self.commandViewModal.calculateChildAction(state: true)
    }
    
}
