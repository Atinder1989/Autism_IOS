//
//  AssesmentMazeObjectController.swift
//  Autism
//
//  Created by mac on 17/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssesmentMazeObjectController: UIViewController {
    
    var selectedIndex:Int = -1
    @IBOutlet weak var answerCollectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var videoPreviewLayer: UIView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!

    private var skipQuestion = false
    private var mazeObjectQuestionInfo: MazeObject!
    private weak var delegate: AssessmentSubmitDelegate?
    private let mazeobjectViewModel = AssesmentMazeObjectViewModel()
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionState: QuestionState = .inProgress
    
    private var isUserInteraction = false {
          didSet {
              self.view.isUserInteractionEnabled = isUserInteraction
          }
    }
    private var touchOnEmptyScreenCount = 0
    private var apiDataState: APIDataState = .notCall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
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
    
    
// MARK: Tableview Delegate/Datasource Methods
extension AssesmentMazeObjectController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         if(UIDevice.current.userInterfaceIdiom == .pad) {
           var size = self.answerCollectionView.frame.width/CGFloat(self.mazeObjectQuestionInfo.answers.count)
           size = size - 15
           return CGSize.init(width: size, height: size)
         } else {
             var size = self.answerCollectionView.frame.width/CGFloat(self.mazeObjectQuestionInfo.answers.count)
             size = size - 15
             return CGSize.init(width: size, height: 40)
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mazeObjectQuestionInfo.answers.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionTextCell.identifier, for: indexPath as IndexPath) as! OptionTextCell
        let content = mazeObjectQuestionInfo.answers[indexPath.row]
        cell.setData(model: content)
        
        cell.imgView.isHidden = true
        
        if(selectedIndex == -1) {
            cell.imgView.isHidden = true
        } else {
            
            if String(format: "%d", selectedIndex+1) == mazeObjectQuestionInfo.correct_answer {
                if(selectedIndex == indexPath.row) {
                    cell.imgView.isHidden = false
                    cell.imgView.image = UIImage.init(named: "greenTick")
                } else {
                    cell.imgView.isHidden = true
                }
            } else {
                if(selectedIndex == indexPath.row) {
                    cell.imgView.isHidden = false
                    cell.imgView.image = UIImage.init(named: "cross")
                } else if String(format: "%d", indexPath.row+1) == mazeObjectQuestionInfo.correct_answer {
                    self.perform(#selector(showCorrectAnswer(_:)), with: cell.imgView, afterDelay: 1)
                } else {
                    cell.imgView.isHidden = true
                    cell.imgView.image = UIImage.init(named: "cross")
                }
            }
        }
        
        cell.textLbl.layer.cornerRadius = 25
        return cell
    }
    
    @objc func showCorrectAnswer(_ imgView:UIImageView)
    {
        imgView.isHidden = false
        imgView.image = UIImage.init(named: "greenTick")
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        answerCollectionView.reloadData()
        
                self.questionState = .submit
                 if String(format: "%d", indexPath.row+1) == mazeObjectQuestionInfo.correct_answer {
                     self.success_count = 100
                    SpeechManager.shared.speak(message: self.mazeObjectQuestionInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                 }
                else {
                    let index = Int(mazeObjectQuestionInfo.correct_answer)! - 1
                    let message = SpeechMessage.rectifyAnswer.getMessage() + self.mazeObjectQuestionInfo.answers[index].name
                    self.success_count = 0
                    SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
    }
    
   
        
}

extension AssesmentMazeObjectController {
    func setSortQuestionInfo(info:MazeObject,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.mazeObjectQuestionInfo = info
        self.delegate = delegate
    }
}

extension AssesmentMazeObjectController {
    private func customSetting() {
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            lblTitle.font = UIFont.init(name: AppFont.helveticaNeue.rawValue, size: 30)
            lblTitle.adjustsFontSizeToFitWidth = true
        }
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        answerCollectionView.register(UINib(nibName: OptionTextCell.identifier, bundle: nil), forCellWithReuseIdentifier: OptionTextCell.identifier)
        lblTitle.text = mazeObjectQuestionInfo.question_title
        ImageDownloader.sharedInstance.downloadImage(urlString: mazeObjectQuestionInfo.image, imageView: self.objectImageView, callbackAfterNoofImages: 1, delegate: self)
       // Utility.setView(view: self.objectImageView, cornerRadius: 10, borderWidth: 2, color: .darkGray)
        AutismTimer.shared.initializeTimer(delegate: self)
        
    }
    private func listenModelClosures() {
       self.mazeobjectViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.mazeobjectViewModel.accessmentSubmitResponseVO {
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

extension AssesmentMazeObjectController {
    private func moveToNextQuestion() {
         self.stopTimer()
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

        if trailPromptTimeForUser == mazeObjectQuestionInfo.trial_time && self.timeTakenToSolve < mazeObjectQuestionInfo.completion_time
        {
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.mazeObjectQuestionInfo.completion_time {
            self.moveToNextQuestion()
    }
}

    private func stopTimer() {
        AutismTimer.shared.stopTimer()
    }
}

// MARK: Speech Manager Delegate Methods
extension AssesmentMazeObjectController: SpeechManagerDelegate {
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
            self.mazeobjectViewModel.submitUserAnswer(successCount: success_count, info: self.mazeObjectQuestionInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount, selectedIndex: selectedIndex)
            break
        default:
            isUserInteraction  = true
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

extension AssesmentMazeObjectController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.apiDataState = .imageDownloaded
            SpeechManager.shared.speak(message:  self.mazeObjectQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}

extension AssesmentMazeObjectController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        print("self.apiDataState = ", self.apiDataState)
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                
            } else if(self.apiDataState == .dataFetched) {
                ImageDownloader.sharedInstance.downloadImage(urlString: mazeObjectQuestionInfo.image, imageView: self.objectImageView, callbackAfterNoofImages: 1, delegate: self)
            } else {
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssesmentMazeObjectController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
