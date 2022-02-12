//
//  AsessmentTestViewController.swift
//  Autism
//
//  Created by Admin on 28/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AsessmentSequenceViewController: UIViewController {
    
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var sequenceCollectionView: UICollectionView!
    @IBOutlet weak var sequenceCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sequenceCollectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    private weak var delegate: AssessmentSubmitDelegate?
    private var sequenceInfo: SequenceResponseInfo!
    private var shuffledArray = [ImageModel]()
    private var sequenceViewModel = AsessmentSequenceViewModel()
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isUserInteraction = false {
        didSet {
            self.view.isUserInteractionEnabled = isUserInteraction
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        self.configureCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
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
extension AsessmentSequenceViewController {
    func setSequenceQuestionInfo(info:SequenceResponseInfo,delegate:AssessmentSubmitDelegate) {
        self.sequenceInfo = info
        self.delegate = delegate
    }
}
//MARK:- Private Methods
extension AsessmentSequenceViewController {
     
     @objc private func calculateTimeTaken() {
         self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1

        if trailPromptTimeForUser == sequenceInfo.trial_time && self.timeTakenToSolve < sequenceInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.sequenceInfo.completion_time {
            self.moveToNextQuestion()
         
        }
     }
      private func moveToNextQuestion() {
        self.stopTimer()
        self.questionState = .submit
        self.completeRate = 0
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
     
    private func stopTimer() {
        AutismTimer.shared.stopTimer()
     }
    
  private func customSetting() {
    self.isUserInteraction = false
    SpeechManager.shared.setDelegate(delegate: self)
    SpeechManager.shared.speak(message:  self.sequenceInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    self.questionTitle.text = self.sequenceInfo.question_title
    self.shuffledArray = self.sequenceInfo.optionList.shuffled()
   // let row = self.shuffledArray.count / 4
   // self.sequenceCollectionViewHeightConstraint.constant = CGFloat(120 * 2)
     sequenceCollectionView.register(SequenceCell.nib, forCellWithReuseIdentifier: SequenceCell.identifier)
    AutismTimer.shared.initializeTimer(delegate: self)
  }
 
  private func configureCollectionView() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPressGesture(gesture:)))
        self.sequenceCollectionView.addGestureRecognizer(longPressGesture)
  }
    
  private func listenModelClosures() {
               self.sequenceViewModel.submitAnswerClosure = {
                   if let res = self.sequenceViewModel.accessmentSubmitResponseVO {
                       DispatchQueue.main.async {
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
    
  @objc private func actionLongPressGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = self.sequenceCollectionView.indexPathForItem(at: gesture.location(in: self.sequenceCollectionView)) else {
                break
            }
            sequenceCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            sequenceCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            sequenceCollectionView.endInteractiveMovement()
        default:
            sequenceCollectionView.cancelInteractiveMovement()
        }
    }
}

//MARK:- UICollectionView Delegate and Datasource Methods

extension AsessmentSequenceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(self.sequenceCollectionView.frame.width) / 4
        return CGSize(width: width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shuffledArray.count
    }
    
    // make a cell for each cell index path
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SequenceCell.identifier, for: indexPath) as! SequenceCell
        cell.setData(model: self.shuffledArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
 func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
     let value = shuffledArray.remove(at: sourceIndexPath.item)
     shuffledArray.insert(value, at: destinationIndexPath.item)
    var isEqual = true
    for (index,model) in self.sequenceInfo.optionList.enumerated() {
        if model.id != self.shuffledArray[index].id {
            isEqual = false
           break
        }
    }
    if isEqual {
        self.questionState = .submit
        self.completeRate = 100
        SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.sequenceInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
 }
}

// MARK: Speech Manager Delegate Methods
extension AsessmentSequenceViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob && type != .wrongAnswer {
                self.avatarImageView.animatedImage =  getIdleGif()
            }
        } else {
                self.avatarImageView.animatedImage =  getIdleGif()
        }

        switch self.questionState {
        case .submit:
            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.sequenceViewModel.submitUserAnswer(completeRate: completeRate, info: self.sequenceInfo, timeTaken: timeTakenToSolve, skip: self.skipQuestion)
            break
        default:
            self.isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

         if let type = Utility.getSpeechMessageType(text: speechText) {
                   switch type {
                   case .hurrayGoodJob:
                       self.avatarImageView.animatedImage =  getHurrayGif()
                       return
                   case .wrongAnswer:
                       self.avatarImageView.animatedImage =  getWrongAnswerGif()
                       return
                   default:
                       break
                   }
               }
        self.avatarImageView.animatedImage =  getTalkingGif()
    }
}

extension AsessmentSequenceViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AsessmentSequenceViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
