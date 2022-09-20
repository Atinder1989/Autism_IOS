//
//  AssesmentFindObjectVC.swift
//  Autism
//
//  Created by mac on 18/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssesmentFindObjectVC: UIViewController {
    
    private var findObjectQuestionInfo: FindObject!
    private weak var delegate: AssessmentSubmitDelegate?
    private let findobjectViewModel = AssesmentFindObjectViewModel()
    @IBOutlet weak var optionCollectionView: UICollectionView!
    @IBOutlet weak var backGroundThemeImageView: UIImageView!

    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
     
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var wrongAnswerCount = 0
    private var questionState: QuestionState = .inProgress
    private var imageFetchCount = 0
    private var isUserInteraction = false {
          didSet {
              self.view.isUserInteractionEnabled = isUserInteraction
          }
    }
    private var skipQuestion = false
    private var noOfCorrectAnswerList:[ImageModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.optionCollectionView.reloadData()
            }
        }
    }
    
    private var apiDataState: APIDataState = .notCall
    private var touchOnEmptyScreenCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
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
extension AssesmentFindObjectVC {
        func setSortQuestionInfo(info:FindObject,delegate:AssessmentSubmitDelegate) {
            self.apiDataState = .dataFetched
            self.findObjectQuestionInfo = info
            self.delegate = delegate
        }
    }

extension AssesmentFindObjectVC {
    private func customSetting() {
        isUserInteraction = false
        self.backGroundThemeImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.findObjectQuestionInfo.bg_image)
        Utility.setView(view: self.backGroundThemeImageView, cornerRadius: 10, borderWidth: 2, color: .darkGray)
        SpeechManager.shared.setDelegate(delegate: self)
        optionCollectionView.register(UINib(nibName: ImageCell.identifier, bundle: nil), forCellWithReuseIdentifier: ImageCell.identifier)
        lblTitle.text = findObjectQuestionInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)
    }
   
    private func listenModelClosures() {
       self.findobjectViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.findobjectViewModel.accessmentSubmitResponseVO {
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
    
    private func isAnswerAlreadyTapped(selectedmodel:ImageModel)->Bool {
        var isExist = false
        for model in self.noOfCorrectAnswerList {
            if model.id == selectedmodel.id {
                isExist = true
                break
            }
        }
        return isExist
    }
    

}

extension AssesmentFindObjectVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.optionCollectionView.frame.width/4, height: self.optionCollectionView.frame.height/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.findObjectQuestionInfo.images.count
    }

// make a cell for each cell index path
internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ImageCell.identifier, for: indexPath as IndexPath) as! ImageCell
       let model = self.findObjectQuestionInfo.images[indexPath.row]
       cell.setData(model: model)
    if model.isCorrectAnswer {
          cell.greenTickImageView.isHidden = false
          cell.greenTickImageView.image = UIImage.init(named: "greenTick")
    } else {
        cell.greenTickImageView.isHidden = true
    }
    return cell
}

    
    
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedModel = self.findObjectQuestionInfo.images[indexPath.row]
    if selectedModel.name == self.findObjectQuestionInfo.correct_answer {
        if !isAnswerAlreadyTapped(selectedmodel: selectedModel) {
            self.updateList(index: indexPath.row)
            self.noOfCorrectAnswerList.append(selectedModel)
                  if self.noOfCorrectAnswerList.count == self.findObjectQuestionInfo.correct_answer_TapCount {
                      self.success_count = 100
                      self.questionState = .submit
                      self.stopTimer()
                      SpeechManager.shared.speak(message: self.findObjectQuestionInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                  }
        }
     } else {
        self.wrongAnswerCount += 1
        SpeechManager.shared.speak(message: self.findObjectQuestionInfo.incorrect_text
                                   , uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
}
    private func updateList(index:Int) {
        var questionInfo = self.findObjectQuestionInfo
        var model = questionInfo?.images[index]
        model?.isCorrectAnswer = true
        questionInfo?.images.remove(at: index)
        questionInfo?.images.insert(model!, at: index)
        self.findObjectQuestionInfo = questionInfo
    }
    
}

extension AssesmentFindObjectVC {
   
@objc private func calculateTimeTaken() {
    
    if !Utility.isNetworkAvailable() {
        return
    }
        self.timeTakenToSolve += 1
    trailPromptTimeForUser += 1

    if self.timeTakenToSolve == Int(AppConstant.screenloadQuestionSpeakTimeDelay.rawValue) {
        SpeechManager.shared.speak(message:  self.findObjectQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
        else if trailPromptTimeForUser == findObjectQuestionInfo.trial_time && self.timeTakenToSolve < findObjectQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.findObjectQuestionInfo.completion_time  {
            self.moveToNextQuestion()
       }
    }
    
    private func moveToNextQuestion() {
       self.stopTimer()
       self.questionState = .submit
       self.success_count = 0
       SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
func stopTimer() {
    AutismTimer.shared.stopTimer()
}
    
}

// MARK: Speech Manager Delegate Methods
extension AssesmentFindObjectVC: SpeechManagerDelegate {
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
            self.findobjectViewModel.submitUserAnswer(successCount: success_count, info: self.findObjectQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, wrongAnswerCount: wrongAnswerCount)
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

extension AssesmentFindObjectVC: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
    }
}
extension AssesmentFindObjectVC: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        print("self.apiDataState = ", self.apiDataState)
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            
            self.backGroundThemeImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.findObjectQuestionInfo.bg_image)
            self.optionCollectionView.reloadData()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}


extension AssesmentFindObjectVC: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}

