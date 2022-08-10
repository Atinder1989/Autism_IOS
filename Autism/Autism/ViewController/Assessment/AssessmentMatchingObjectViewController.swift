//
//  AssessmentMatchingObjectViewController.swift
//  Autism
//
//  Created by Dilip Technology on 16/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class AssessmentMatchingObjectViewController: UIViewController {

    private var matchingObjectInfo: MatchingObjectInfo!
    private let matchingObjectViewModel = AssessmentMatchingObjectViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    
    @IBOutlet weak var collectionOption: UICollectionView!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewBG:  ImageViewWithID!
    private var answerIndex = -1
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var initialState = true
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isUserInteraction = false {
        didSet {
            self.view.isUserInteractionEnabled = isUserInteraction
        }
    }
    private var selectedIndex = -1 {
        didSet {
            DispatchQueue.main.async {
                self.collectionOption.reloadData()
            }
        }
    }
    
    private var apiDataState: APIDataState = .notCall
    private var touchOnEmptyScreenCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customSetting()
        self.listenModelClosures()
        
        answerIndex = Int(self.matchingObjectInfo.correct_answer)!-1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           self.stopQuestionCompletionTimer()
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
    
extension AssessmentMatchingObjectViewController {
    func setMatchingObjectInfo(info:MatchingObjectInfo,delegate:AssessmentSubmitDelegate) {
    
        self.apiDataState = .dataFetched
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
}

extension AssessmentMatchingObjectViewController {
    func setSortQuestionInfo(info:MatchingObjectInfo,delegate:AssessmentSubmitDelegate) {
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
}

extension AssessmentMatchingObjectViewController {
    private func customSetting() {
        
        self.isUserInteraction = false
        collectionOption.register(UINib(nibName: MatchingObjectCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MatchingObjectCollectionViewCell.identifier)
        labelTitle.text = matchingObjectInfo.question_title

        let screenW:CGFloat = UIScreen.main.bounds.width
        let screenH:CGFloat = UIScreen.main.bounds.height

        if(UIDevice.current.userInterfaceIdiom == .pad) {
            self.imageViewBG.frame = CGRect(x: (screenW-310)/2.0, y: 120, width: 310, height: 310)
            
            if(matchingObjectInfo.image_with_text.count == 2) {
                self.collectionOption.frame = CGRect(x: (screenW-720)/2.0, y: screenH-320, width: 720, height: 300)
            } else {
                self.collectionOption.frame = CGRect(x: (screenW-960)/2.0, y: screenH-320, width: 960, height: 300)
            }

            Utility.setView(view: self.imageViewBG, cornerRadius: 155, borderWidth: 2, color: .darkGray)
        } else {
            self.imageViewBG.frame = CGRect(x: (screenW-100)/2.0, y: 80, width: 100, height: 100)
            
            if(matchingObjectInfo.image_with_text.count == 2) {
                self.collectionOption.frame = CGRect(x: (screenW-320)/2.0, y: screenH-130, width: 320, height: 100)
            } else if(matchingObjectInfo.image_with_text.count == 3) {
                self.collectionOption.frame = CGRect(x: (screenW-360)/2.0, y: screenH-130, width: 360, height: 100)
            } else if(matchingObjectInfo.image_with_text.count == 4) {
                self.collectionOption.frame = CGRect(x: (screenW-480)/2.0, y: screenH-130, width: 480, height: 100)
            }
            
            Utility.setView(view: self.imageViewBG, cornerRadius: 50, borderWidth: 2, color: .darkGray)
        }

        self.perform(#selector(bgImageLoad), with: nil, afterDelay: 1)
        self.perform(#selector(speechQuestionTitle), with: nil, afterDelay: 3)
    }

    @objc func speechQuestionTitle() {
        DispatchQueue.main.async {
            SpeechManager.shared.setDelegate(delegate: self)
            SpeechManager.shared.speak(message:  self.matchingObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            
            AutismTimer.shared.initializeTimer(delegate: self)
        }
    }
    
    @objc func bgImageLoad() {
        self.imageViewBG.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + matchingObjectInfo.bg_image)

    }
    private func listenModelClosures() {
       self.matchingObjectViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.matchingObjectViewModel.accessmentSubmitResponseVO {
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
}

extension AssessmentMatchingObjectViewController {
    
    private func moveToNextQuestion() {
          self.stopQuestionCompletionTimer()
          self.questionState = .submit
          self.success_count = 0
          SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
   
    @objc private func calculateTimeTaken() {
        if !Utility.isNetworkAvailable() {
            return
        }
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1

        if trailPromptTimeForUser == matchingObjectInfo.trial_time && self.timeTakenToSolve < matchingObjectInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.matchingObjectInfo.completion_time {
            self.moveToNextQuestion()
    }
}

    private func stopQuestionCompletionTimer() {
        AutismTimer.shared.stopTimer()
   
}
}

extension AssessmentMatchingObjectViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.matchingObjectInfo.image_with_text.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        var width = self.collectionOption.frame.width-CGFloat((self.matchingObjectInfo.image_with_text.count*20))
            width = width / CGFloat(self.matchingObjectInfo.image_with_text.count)
        print("width = ", width)
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            width = 100
        } else if(self.matchingObjectInfo.image_with_text.count == 2) {
            width = 300
        }
        return CGSize.init(width:width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if(matchingObjectInfo.image_with_text.count == 2) {
            return 100
        } else {
            return 20
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(matchingObjectInfo.image_with_text.count == 2) {
            return 100
        } else {
            return 20
        }
    }

// make a cell for each cell index path
internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier:MatchingObjectCollectionViewCell.identifier, for: indexPath as IndexPath) as! MatchingObjectCollectionViewCell
    
    let optionSelected = self.matchingObjectInfo.image_with_text[indexPath.row]
    let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + optionSelected.image
    cell.imageObject.setImageWith(urlString: urlString)

    cell.greenTickImageView.isHidden = true
    var width = self.collectionOption.frame.width-CGFloat((self.matchingObjectInfo.image_with_text.count*20))
    width = width / CGFloat(self.matchingObjectInfo.image_with_text.count)
    
    if(UIDevice.current.userInterfaceIdiom != .pad) {
        width = 100
    } else if(self.matchingObjectInfo.image_with_text.count == 2) {
        width = 300
    }
    let cornerRadius:CGFloat = width/2.0
    
    
    print("width 2 = ", width)
    cell.setConstraints(value:width)
    
     if selectedIndex == -1 {
        Utility.setView(view: cell.imageObject, cornerRadius: cornerRadius, borderWidth: 2, color: .darkGray)
     } else {
        if indexPath.row == answerIndex {
            if(selectedIndex != answerIndex) {
                Animations.shake(on: cell)
            }
            cell.greenTickImageView.isHidden = false
            cell.greenTickImageView.image = UIImage.init(named: "greenTick")
            Utility.setView(view: cell.imageObject, cornerRadius: cornerRadius, borderWidth: 2, color: .greenBorderColor)
        } else if selectedIndex == indexPath.row {
            if(selectedIndex != answerIndex) {
                cell.greenTickImageView.isHidden = false
                cell.greenTickImageView.image = UIImage.init(named: "cross")
            }
            Utility.setView(view: cell.imageObject, cornerRadius: cornerRadius, borderWidth: 2, color: .redBorderColor)
        } else {
            Utility.setView(view: cell.imageObject, cornerRadius: cornerRadius, borderWidth: 2, color: .darkGray)
        }
    }

    return cell
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if(self.matchingObjectInfo.screen_type == AssessmentQuestionType.matching_object_drag.rawValue) {
        return
    }
    self.selectedIndex = indexPath.row
    self.questionState = .submit

    if indexPath.row == answerIndex {
        self.success_count = 100
        SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.matchingObjectInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    } else {
        let name = self.matchingObjectInfo.image_with_text[answerIndex].name
        let message = SpeechMessage.rectifyAnswer.getMessage() + "\(name)"
        self.success_count = 0
        SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
}
}
// MARK: Speech Manager Delegate Methods
extension AssessmentMatchingObjectViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.matchingObjectViewModel.submitUserAnswer(successCount: self.success_count, info: self.matchingObjectInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, selectedIndex: self.selectedIndex)
            break
        default:
            self.isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false

    }
}


extension AssessmentMatchingObjectViewController: NetworkRetryViewDelegate {
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

extension AssessmentMatchingObjectViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
