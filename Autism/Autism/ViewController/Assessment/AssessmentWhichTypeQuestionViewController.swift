//
//  AssessmentQ10InputPictureOutputVerbalsViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/09.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentWhichTypeQuestionViewController: UIViewController {
    
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    private weak var delegate: AssessmentSubmitDelegate?
    private var whichTypeQuestionInfo: WhichTypeQuestionInfo!
    private var whichTypeViewModel = AssessmentWhichTypeQuestionViewModel()
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var questionState: QuestionState = .inProgress
    private var isImagesDownloaded = false

     private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
       }
    private var skipQuestion = false
    private var selectedIndex = -1 {
        didSet {
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        }
    }
    private var touchOnEmptyScreenCount = 0
    private var apiDataState: APIDataState = .notCall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        self.listenModelClosures()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        SpeechManager.shared.setDelegate(delegate: nil)
        UserManager.shared.exitAssessment()
    }
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
           self.skipQuestion = true
           self.moveToNextQuestion()
        }
    }
}

// MARK: Public Methods
extension AssessmentWhichTypeQuestionViewController {
    func setQuestionInfo(info:WhichTypeQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.whichTypeQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentWhichTypeQuestionViewController {
    private func moveToNextQuestion() {
         self.stopTimer()
         self.questionState = .submit
         self.completeRate = 0
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }

    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        imagesCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        
        let size:CGFloat = UIScreen.main.bounds.width / CGFloat(self.whichTypeQuestionInfo.image_with_text.count)
        self.collectionViewHeightConstraint.constant = size
        self.collectionViewWidthConstraint.constant = UIScreen.main.bounds.width
        
        self.questionTitle.text = self.whichTypeQuestionInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func listenModelClosures() {
            self.navigationController?.navigationBar.isHidden = true
            self.whichTypeViewModel.dataClosure = {
                DispatchQueue.main.async {
                    if let res = self.whichTypeViewModel.accessmentSubmitResponseVO {
                        if res.success {
                            self.dismiss(animated: true) {
                                if let del = self.delegate {
                                    del.submitQuestionResponse(response: res)
                                }
                            }
                        }
                    }
                }
            }
    }
    
//    private func initializeTimer() {
//        answerResponseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
//    }
    
    @objc private func calculateTimeTaken() {
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1

        if self.timeTakenToSolve == Int(AppConstant.screenloadQuestionSpeakTimeDelay.rawValue) {
            SpeechManager.shared.speak(message:  self.whichTypeQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if trailPromptTimeForUser == whichTypeQuestionInfo.trial_time && self.timeTakenToSolve < whichTypeQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else {
            if self.timeTakenToSolve >= whichTypeQuestionInfo.completion_time  {
                self.moveToNextQuestion()
            }
        }
    }
    
    func stopTimer() {
        AutismTimer.shared.stopTimer()

    }
}

extension AssessmentWhichTypeQuestionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size:CGFloat = UIScreen.main.bounds.width / CGFloat(self.whichTypeQuestionInfo.image_with_text.count) - 20
        return CGSize.init(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.whichTypeQuestionInfo.image_with_text.count
    }
    
    // make a cell for each cell index path
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        let model = self.whichTypeQuestionInfo.image_with_text[indexPath.row]
       // cell.setData(model: model)
        
     //   ImageDownloader.sharedInstance.downloadImage(urlString: model.image, imageView: cell.dataImageView, callbackAfterNoofImages: self.whichTypeQuestionInfo.image_with_text.count, delegate: self)
        
        cell.dataImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + model.image, placeholderImage: "")
        
        cell.greenTickImageView.isHidden = true
        var cornerRadius = cell.frame.size.width / 2
        var borderWidth:CGFloat = 2
        
        if (self.whichTypeQuestionInfo.question_type == AssessmentQuestionType.touch_object.rawValue) {
            cornerRadius = 0.0
            borderWidth = 0.0
            cell.dataImageView.transform = CGAffineTransform(rotationAngle: CGFloat(model.degrees * .pi/180))            
        } else {
            cell.dataImageView.transform = CGAffineTransform(rotationAngle: 0)
        }
        
        if(self.whichTypeQuestionInfo.show_circle == "No") {
            cornerRadius = 0.0
            borderWidth = 0.0
        }
        
        if selectedIndex == -1 {
          Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .darkGray)
        } else {
            if indexPath.row == Int(self.whichTypeQuestionInfo.correct_answer)! - 1 {
                 cell.greenTickImageView.isHidden = false
                 cell.greenTickImageView.image = UIImage.init(named: "greenTick")
                 Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .greenBorderColor)
             }
             else if selectedIndex == indexPath.row {
                Animations.shake(on: cell)
                 cell.greenTickImageView.isHidden = false
                 cell.greenTickImageView.image = UIImage.init(named: "cross")
                 Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .redBorderColor)
                
             } else {
                 Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .darkGray)
             }
        }
      return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if !isImagesDownloaded {
//            return
//        }
        
        
        self.selectedIndex = indexPath.row
        self.questionState = .submit
        let answerIndex = Int(self.whichTypeQuestionInfo.correct_answer)! - 1
        if indexPath.row == answerIndex {
                    self.completeRate = 100
                   SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.whichTypeQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

        } else {
            let name = self.whichTypeQuestionInfo.image_with_text[answerIndex].name
            self.completeRate = 0
               SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+"\(name)", uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

        }
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentWhichTypeQuestionViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob && type != .wrongAnswer {
                       self.avatarImageView.animatedImage =  idleGif
                   }
               } else {
                       self.avatarImageView.animatedImage =  idleGif
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.whichTypeViewModel.submitVerbalQuestionDetails(info: self.whichTypeQuestionInfo, completeRate: completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, selectedIndex: self.selectedIndex)
            break
        default:
            isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .hurrayGoodJob:
                self.avatarImageView.animatedImage =  hurrayGif
                return
            case .wrongAnswer:
                self.avatarImageView.animatedImage =  wrongAnswerGif
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage =  talkingGif
    }
}

extension AssessmentWhichTypeQuestionViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                self.listenModelClosures()
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentWhichTypeQuestionViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}


extension AssessmentWhichTypeQuestionViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
           // self.commandSolidViewModal.updateCurrentCommandIndex()
        }
    }
}
