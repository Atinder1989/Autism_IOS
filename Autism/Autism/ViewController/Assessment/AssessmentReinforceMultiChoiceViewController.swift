//
//  AssessmentReinforceMultiChoiceViewController.swift
//  Autism
//
//  Created by Dilip Technology on 12/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentReinforceMultiChoiceViewController: UIViewController {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    private weak var delegate: AssessmentSubmitDelegate?
    private var reinforceMultiChoiceInfo: ReinforceMultiChoiceInfo!
    private var reinforceMultiChoiceViewModel = ReinforceMultiChoiceViewModel()
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var questionState: QuestionState = .inProgress
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
extension AssessmentReinforceMultiChoiceViewController {
    func setQuestionInfo(info:ReinforceMultiChoiceInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.reinforceMultiChoiceInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentReinforceMultiChoiceViewController {
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
        
        
        if(self.reinforceMultiChoiceInfo.imagesList.count <= 4) {
            print("UIScreen.main.bounds.size.width = ", UIScreen.main.bounds.size.width)
            if(UIScreen.main.bounds.size.width > 1100){
                self.collectionViewWidthConstraint.constant = CGFloat(self.reinforceMultiChoiceInfo.imagesList.count * 300)
                self.collectionViewHeightConstraint.constant = 340
            } else {
                self.collectionViewWidthConstraint.constant = CGFloat(self.reinforceMultiChoiceInfo.imagesList.count * 240)
                self.collectionViewHeightConstraint.constant = 300
            }
        } else {
            self.collectionViewHeightConstraint.constant = 600
        }
        
        self.questionTitle.text = self.reinforceMultiChoiceInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func listenModelClosures() {
            self.navigationController?.navigationBar.isHidden = true
            self.reinforceMultiChoiceViewModel.dataClosure = {
                DispatchQueue.main.async {
                    if let res = self.reinforceMultiChoiceViewModel.accessmentSubmitResponseVO {
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
    
  
    
    @objc private func calculateTimeTaken() {
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1
        if self.timeTakenToSolve == Int(AppConstant.screenloadQuestionSpeakTimeDelay.rawValue) {
            SpeechManager.shared.speak(message:  self.reinforceMultiChoiceInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if trailPromptTimeForUser == reinforceMultiChoiceInfo.trial_time && self.timeTakenToSolve < reinforceMultiChoiceInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else {
            if self.timeTakenToSolve >= reinforceMultiChoiceInfo.completion_time   {
                self.moveToNextQuestion()
            }
        }
    }
    
    func stopTimer() {
        AutismTimer.shared.stopTimer()

    }
    
}

extension AssessmentReinforceMultiChoiceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(self.reinforceMultiChoiceInfo.imagesList.count == 3) {
            self.collectionViewWidthConstraint.constant = CGFloat(3 * 320)
            self.collectionViewHeightConstraint.constant = 300
            return CGSize.init(width: 300, height: 300)
        } else if(self.reinforceMultiChoiceInfo.imagesList.count == 6) {
            self.collectionViewWidthConstraint.constant = CGFloat(3 * 280)
            self.collectionViewHeightConstraint.constant = 600
            return CGSize.init(width: 260, height: 260)
        } else if(self.reinforceMultiChoiceInfo.imagesList.count == 4) {
            if(UIScreen.main.bounds.size.width > 1100){
                self.collectionViewWidthConstraint.constant = CGFloat(4 * 300)
                self.collectionViewHeightConstraint.constant = 340
                return CGSize.init(width: 280, height: 280)
            } else {
                self.collectionViewWidthConstraint.constant = CGFloat(4 * 240)
                self.collectionViewHeightConstraint.constant = 300
                return CGSize.init(width: 220, height: 220)
            }
        } else if(self.reinforceMultiChoiceInfo.imagesList.count == 8) {
            self.collectionViewWidthConstraint.constant = CGFloat(4 * 240)
            self.collectionViewHeightConstraint.constant = 500
            return CGSize.init(width: 220, height: 220)
        } else {
            self.collectionViewWidthConstraint.constant = CGFloat(self.reinforceMultiChoiceInfo.imagesList.count * 240)
            self.collectionViewHeightConstraint.constant = 300
            return CGSize.init(width: 220, height: 220)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reinforceMultiChoiceInfo.imagesList.count
    }
    
    // make a cell for each cell index path
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        let model = self.reinforceMultiChoiceInfo.imagesList[indexPath.row]
        cell.setData(model: model)
        cell.greenTickImageView.isHidden = true
        var cornerRadius = cell.frame.size.width / 2
        var borderWidth:CGFloat = 2
        
        if (self.reinforceMultiChoiceInfo.question_type == AssessmentQuestionType.touch_object.rawValue) {
            cornerRadius = 0.0
            borderWidth = 0.0
            cell.dataImageView.transform = CGAffineTransform(rotationAngle: CGFloat(model.degrees * .pi/180))
        } else {
            cell.dataImageView.transform = CGAffineTransform(rotationAngle: 0)
        }
        
        if selectedIndex == -1 {
          Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .darkGray)
        } else {
            if indexPath.row == Int(self.reinforceMultiChoiceInfo.correct_answer)! - 1 {
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
        self.selectedIndex = indexPath.row
        self.questionState = .submit
        let answerIndex = Int(self.reinforceMultiChoiceInfo.correct_answer)! - 1
        if indexPath.row == answerIndex {
                    self.completeRate = 100
                   SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.reinforceMultiChoiceInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

        } else {
            self.completeRate = 0
               SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(self.reinforceMultiChoiceInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

        }
    }
    
}

// MARK: Speech Manager Delegate Methods
extension AssessmentReinforceMultiChoiceViewController: SpeechManagerDelegate {
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
            self.reinforceMultiChoiceViewModel.submitQuestionDetails(info: self.reinforceMultiChoiceInfo, completeRate: completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, selectedIndex: self.selectedIndex)
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

extension AssessmentReinforceMultiChoiceViewController: NetworkRetryViewDelegate {
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

extension AssessmentReinforceMultiChoiceViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
