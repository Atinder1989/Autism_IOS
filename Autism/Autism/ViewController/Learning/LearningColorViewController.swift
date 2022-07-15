//
//  LearningColorViewController.swift
//  Autism
//
//  Created by Savleen on 14/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

struct AnimationImageModel {
    var url : String
    var value_id : String
    var correct_option : ScriptCommandOptionType
    var isShowFinger = false
    var isShowTapFingerAnimation = false
    var isCircleShape = ""
    var isBlink = false
    
    init() {
        self.url = ""
        self.value_id = ""
        self.correct_option = .none
    }
}

class LearningColorViewController: UIViewController {
    private let commandSolidViewModal: LearningColorViewModel = LearningColorViewModel()
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []

    private var itemSize:CGFloat = 266
    private var isTouch = false
    private var isImagesDownloaded = false
    private var isChildAction = false
    private var videoItem: VideoItem?
    private var isChildActionCompleted = false {
        didSet {
            if isChildActionCompleted {
                DispatchQueue.main.async {
                    self.commandSolidViewModal.calculateChildAction(state: self.isChildActionCompleted, touch: self.isTouch)
             
                }
            }
        }
    }
    private var selectedIndex = -1 {
        didSet {
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        }
    }
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipLearningButton: UIButton!
    @IBOutlet weak var bufferLoaderView: UIView!
    private var bufferLoaderTimer: Timer?

    private var imageList = [AnimationImageModel]() {
        didSet{
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        }
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            itemSize = 140
        }
        // Do any additional setup after loading the view.
//crash resolved        self.skipLearningButton.isHidden = isSkipLearningHidden
        self.customSetting()
        if self.command_array.count == 0 {
            self.commandSolidViewModal.fetchLearningSolidQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopPlayer()
        self.hideBufferLoader()
        self.commandSolidViewModal.stopAllCommands()
    }
    
    @IBAction func restartVideoClicked(_ sender: Any) {
        self.stopTimer()
        self.commandSolidViewModal.seekToTimePlayer(time: CMTime.zero)
        self.playVideo()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        self.moveToNextCommand()
    }

    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        self.commandSolidViewModal.pausePlayer()
        self.commandSolidViewModal.stopAllCommands()
        UserManager.shared.exitAssessment()
    }
   
}
//MARK:- Public Methods
extension LearningColorViewController {
    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        if command_array.count > 0 {
            self.command_array = command_array
            self.commandSolidViewModal.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)

        }
    }
}

//MARK:- Private Methods
extension LearningColorViewController {
    
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.commandSolidViewModal.updateCurrentCommandIndex()
    }
    
    private func customSetting() {
        self.imageList = []
        self.isTouch = false
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        self.speechTitle.text = ""
        isChildActionCompleted = false
        self.playerView.isHidden = true
        self.imagesCollectionView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.isChildAction = false
        self.bufferLoaderView.isHidden = true
        selectedIndex = -1
        isImagesDownloaded = false
        imagesCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    
    private func listenModelClosures() {
        self.commandSolidViewModal.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.commandSolidViewModal.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.commandSolidViewModal.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
       self.commandSolidViewModal.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
               
       self.commandSolidViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.commandSolidViewModal.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.commandSolidViewModal.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.commandSolidViewModal.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.commandSolidViewModal.childActionStateClosure = { state in
             DispatchQueue.main.async {
                //self.view.isUserInteractionEnabled = state
                self.isChildAction = state

             }
        }
       
       self.commandSolidViewModal.showImagesClosure = {commandInfo in
            DispatchQueue.main.async {
                var array : [AnimationImageModel] = []
                if let option = commandInfo.option {
                    let correctOption = (Int(option.correct_option) ?? 0) - 1
                   
                    self.collectionViewWidthConstraint.constant = self.itemSize * CGFloat(commandInfo.valueList.count)
                    for (index, element) in commandInfo.valueList.enumerated() {
                        var scModel = AnimationImageModel.init()
                        scModel.url = element
                        scModel.value_id = commandInfo.value_idList[index]
                        
                        if index == correctOption {
                            scModel.correct_option = ScriptCommandOptionType.actiontrue
                        } else {
                            scModel.correct_option = ScriptCommandOptionType.actionfalse
                        }
                        scModel.isShowFinger = false
                        scModel.isShowTapFingerAnimation = false
                        scModel.isCircleShape = option.show_circle
                        array.append(scModel)
                    }
                }
                self.imageList.removeAll()
                self.imageList = array
                self.imagesCollectionView.isHidden = false
            }
       }
        self.commandSolidViewModal.showFingerClosure = {
             DispatchQueue.main.async {
                self.selectedIndex = -1
                self.updateImageListWithShowFinger()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.resetImageList()
                }
             }
        }
        self.commandSolidViewModal.showTapFingerAnimationClosure = {
             DispatchQueue.main.async {
                self.updateImageListWithShowTapFingerAnimation()
                let deadlineTime = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.commandSolidViewModal.calculateChildAction(state: false, touch: self.isTouch)
                    self.commandSolidViewModal.updateCurrentCommandIndex()
                }
             }
        }
        
        self.commandSolidViewModal.blinkImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                if let option = questioninfo.option {
                    self.blinkImage(questioninfo, count: Int(option.time_in_second) ?? Int(learningAnimationDuration))
                }
             }
        }
    }
    
    private func blinkImage(_ questionInfo:ScriptCommandInfo, count: Int) {
        if count == 0 {
            if(questionInfo.condition.lowercased() == "no") {
                self.commandSolidViewModal.updateCurrentCommandIndex()
            }
            return
        }
        
        var index:Int = 0
        for model in self.imageList {
            
            if model.value_id == questionInfo.value_id {
                DispatchQueue.main.async {
                    let cell = self.imagesCollectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: IndexPath.init(row: index, section: 0)) as! ImageCell
                    self.blinkImageView(questionInfo, cell, count)
                    
//                    UIView.animate(withDuration: learningAnimationDuration, animations: {
//                        cell.alpha = 0.2
//                    }) { [self] finished in
//                        UIView.animate(withDuration: learningAnimationDuration, animations: {
//                            cell.alpha = 1.0
//                        }) { [self] finished in
//                            blinkImage(questionInfo, count: count - 1)
//                        }
//                    }
                }
                break;
            }
            index = index+1
        }
    }
    
    func blinkImageView(_ questionInfo:ScriptCommandInfo, _ cell:ImageCell, _ count: Int) {
        
        if count == 0 {
            if(questionInfo.condition.lowercased() == "no") {
                self.commandSolidViewModal.updateCurrentCommandIndex()
            }
            return
        }

        DispatchQueue.main.async {

        UIView.animate(withDuration: learningAnimationDuration-2, animations: {
            //cell.dataImageView.alpha = 0.2
            self.imagesCollectionView.alpha = 0.2
        }) { [self] finished in
            UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                //cell.dataImageView.alpha = 1.0
                self.imagesCollectionView.alpha = 1.0
            }) { [self] finished in
                blinkImageView(questionInfo, cell, count - 1)
            }
        }
        }
    }
    
    private func updateImageListWithShowFinger() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isShowFinger = true
            } else {
                scModel.isShowFinger = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func updateImageListWithShowTapFingerAnimation() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isShowTapFingerAnimation = true
                scModel.isShowFinger = true
            } else {
                scModel.isShowTapFingerAnimation = false
                scModel.isShowFinger = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func resetImageList() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            scModel.isShowFinger = false
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = commandSolidViewModal.playerController {
            if let avplayerController = playerController.avPlayerController {
                self.playerView.isHidden = false
                self.playerView.addSubview(avplayerController.view)
                avplayerController.view.frame = self.playerView.bounds
                self.videoItem = VideoItem.init(url: string)
                self.playVideo()
                self.thumbnailImage = Utility.getThumbnailImage(urlString: string, time: CMTimeMake(value: 5, timescale: 2))
            }
        }
        
    }
    
    private func showBufferLoader() {
        self.playerView.bringSubviewToFront(self.bufferLoaderView)
        self.bufferLoaderView.isHidden = false
        if let timer = self.bufferLoaderTimer {
            timer.invalidate()
        }
        self.bufferLoaderTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.2),
                        target: self,
                        selector: #selector(self.startBufferLoaderAnimation),
                        userInfo: nil, repeats: true)
    }

    @objc private func startBufferLoaderAnimation () {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {() -> Void in
                self.bufferLoaderView.transform = self.bufferLoaderView.transform.rotated(by: CGFloat(Double.pi))
            }, completion: {(_ finished: Bool) -> Void in
            })
        }
    }

    private func hideBufferLoader() {
        if let timer = self.bufferLoaderTimer {
            self.bufferLoaderView.isHidden = true
            timer.invalidate()
            self.bufferLoaderTimer = nil
        }
    }
    
    
    private func playVideo() {
        if let item = self.videoItem {
        commandSolidViewModal.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.commandSolidViewModal.stopVideo()
    }
    
    private func videoFinished() {
        self.restartButton.isHidden = false
        self.nextButton.isHidden = false
        if let image = self.thumbnailImage {
            self.thumnailImageView.image = image
            self.thumnailImageView.isHidden = false
        }
        self.initializeTimer()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.commandSolidViewModal.getCurrentCommandInfo(),let option = info.option {
            let time = Int(option.switch_command_time) ?? 0
            if self.videoFinishWaitingTime >= time  {
                self.moveToNextCommand()
            }
        }
    }
    
    private func stopTimer() {
        if let timer = self.videoFinishTimer {
            print("Video Timer Stop ======== ")
            timer.invalidate()
            self.videoFinishTimer = nil
            self.videoFinishWaitingTime = 0
        }
    }

 }

extension LearningColorViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        
        let cornerRadius = (itemSize-20)/2.0//cell.frame.size.width / 2
        let borderWidth:CGFloat = 2
        
        if model.isCircleShape != "no" {
        Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .darkGray)
        }
        
        cell.dataImageView.image = nil
        //let url = ServiceHelper.baseURL.getMediaBaseUrl()+model.url
        ImageDownloader.sharedInstance.downloadImage(urlString: model.url, imageView: cell.dataImageView, callbackAfterNoofImages: self.imageList.count, delegate: self)
        
        cell.handImageView.isHidden = true
        cell.greenTickImageView.isHidden = true
        cell.handImageView.isHidden = !model.isShowFinger
        
        if selectedIndex >= 0  {
            if model.correct_option ==  ScriptCommandOptionType.actiontrue  {
                cell.greenTickImageView.isHidden = false
                cell.greenTickImageView.image = UIImage.init(named: "greenTick")
                if model.isCircleShape != "no" {
                Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .greenBorderColor)
                }

            } else if indexPath.row == self.selectedIndex {
                cell.greenTickImageView.isHidden = false
                cell.greenTickImageView.image = UIImage.init(named: "cross")
                if model.isCircleShape != "no" {
                Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .redBorderColor)
                }
            }
        }
        if model.isShowTapFingerAnimation {
            if model.isCircleShape != "no" {
            Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .greenBorderColor)
            }
            Animations.shake(on: cell.dataImageView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isChildAction {
            return
        }
        self.isTouch = true
        self.selectedIndex = indexPath.row
        let model = self.imageList[indexPath.row]
        if model.correct_option == ScriptCommandOptionType.actiontrue {
            self.isChildActionCompleted = true
        } else {
            self.isChildActionCompleted = false
        }
    }
    
}



extension LearningColorViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


extension LearningColorViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
            self.commandSolidViewModal.updateCurrentCommandIndex()
        }
    }
}
