//
//  AssessmentIndependentPlayViewController.swift
//  Autism
//
//  Created by Dilip Technology on 22/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssessmentIndependentPlayViewController: UIViewController {
    private weak var delegate: AssessmentSubmitDelegate?
    private let independentPlayViewModel = AssessmentIndependentPlayViewModel()
    private var independentPlayQuestionInfo: IndependentPlayInfo!
    private let notificationName = "NotificationIdentifier"
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgViewBG: UIImageView!
    @IBOutlet weak var imgViewObject: UIImageView!
    @IBOutlet weak var imgViewGoal: UIImageView!
    
    var minX:CGFloat = 100
    var maxX:CGFloat = UIScreen.main.bounds.width-100
    
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var skipQuestion = false
    private var questionState: QuestionState = .inProgress
    
    private var isUserInteraction = false {
           didSet {
               self.view.isUserInteractionEnabled = isUserInteraction
           }
    }
    
    private var apiDataState: APIDataState = .notCall

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
           NotificationCenter.default.removeObserver(self, name: Notification.Name(notificationName), object: nil)
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
    //MARK:- Touch Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
        let location = touch.location(in: self.view)
        print("location.x", location.x)
        print("location.y = ",location.y)
        
        let carFrame = CGRect(x: self.imgViewObject.frame.origin.x, y: self.imgViewObject.frame.origin.y+40, width: self.imgViewObject.frame.size.width, height: self.imgViewObject.frame.size.height-80)
        
//        if (self.imgViewObject.frame.contains(location) == true)
        if (carFrame.contains(location) == true)
        {
            if(location.x >= maxX) {
                imgViewObject.center = CGPoint(x: maxX, y: imgViewObject.center.y)
            } else if(location.x <= minX) {
                imgViewObject.center = CGPoint(x: minX, y: imgViewObject.center.y)
            } else {
                imgViewObject.center = CGPoint(x: location.x, y: imgViewObject.center.y)
            }
        }
      }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     
        
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            print("location.x", location.x)
            print("location.y = ",location.y)
//            imgViewObject.backgroundColor = .red
            
            let carFrame = CGRect(x: self.imgViewObject.frame.origin.x, y: self.imgViewObject.frame.origin.y+40, width: self.imgViewObject.frame.size.width, height: self.imgViewObject.frame.size.height-80)
            //if (self.imgViewObject.frame.contains(location) == true)
            if (carFrame.contains(location) == true)
            {
                if(location.x >= maxX) {
                    imgViewObject.center = CGPoint(x: maxX, y: imgViewObject.center.y)
                } else if(location.x <= minX) {
                    imgViewObject.center = CGPoint(x: minX, y: imgViewObject.center.y)
                } else {
                    imgViewObject.center = CGPoint(x: location.x, y: imgViewObject.center.y)
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(self.questionState != .submit ) {
            if(imgViewObject.center.x >= maxX-5) {
                self.questionState = .submit
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.independentPlayQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
        }
    }
}

// MARK: Public Methods
extension AssessmentIndependentPlayViewController {
    func setIndependentPlayQuestionInfo(info:IndependentPlayInfo,delegate:AssessmentSubmitDelegate) {
        self.independentPlayQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentIndependentPlayViewController {
    private func customSetting() {
        
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        lblTitle.text = independentPlayQuestionInfo.question_title
        self.reDownloadImages()
        
        let imgWH:CGFloat = 180
        let yPos:CGFloat = (UIScreen.main.bounds.size.height-imgWH)/2.0
        
        imgViewObject.frame = CGRect(x:0, y:yPos, width:imgWH, height:imgWH)
        imgViewGoal.frame = CGRect(x:UIScreen.main.bounds.size.width-imgWH+20, y:yPos, width:imgWH, height:imgWH)
                
        minX = imgViewObject.center.x
        maxX = imgViewGoal.center.x - 150
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            imgViewGoal.frame = CGRect(x:UIScreen.main.bounds.size.width-imgWH-30, y:yPos-20, width:imgWH, height:imgWH)
        }
    }
    
    func reDownloadImages()
    {
        if(independentPlayQuestionInfo.bg_image != "" && independentPlayQuestionInfo.goal_image != "" && independentPlayQuestionInfo.objejct_image != "") {
            
            ImageDownloader.sharedInstance.downloadImage(urlString:  independentPlayQuestionInfo.bg_image, imageView: imgViewBG, callbackAfterNoofImages: 3, delegate: self)
            
            ImageDownloader.sharedInstance.downloadImage(urlString:  independentPlayQuestionInfo.goal_image, imageView: imgViewGoal, callbackAfterNoofImages: 3, delegate: self)

            ImageDownloader.sharedInstance.downloadImage(urlString:  independentPlayQuestionInfo.objejct_image, imageView: imgViewObject, callbackAfterNoofImages: 3, delegate: self)
        }
    }

    private func listenModelClosures() {
       self.independentPlayViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.independentPlayViewModel.accessmentSubmitResponseVO {
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
    
    @objc private func methodOfReceivedNotification(notification: Notification) {
        
         let time:String = UserDefaults.standard.object(forKey: "time") as! String
        
        let timeInt = Int(time)
        
        self.independentPlayViewModel.submitUserAnswer(successCount: timeInt!, info: self.independentPlayQuestionInfo, timeTaken: 0, skip: false)
    }
     
     private func moveToNextQuestion() {
         self.stopTimer()
                    RecordingManager.shared.stopRecording()
                    RecordingManager.shared.stopWaitUserAnswerTimer()
                    self.completeRate = 0
                    self.questionState = .submit
                    SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        
     }
     
     @objc private func calculateTimeTaken() {
         
         if !Utility.isNetworkAvailable() {
             return
         }
         self.timeTakenToSolve += 1
         if self.timeTakenToSolve >= independentPlayQuestionInfo.completion_time  {
             self.moveToNextQuestion()
         } else if trailPromptTimeForUser == independentPlayQuestionInfo.trial_time && self.timeTakenToSolve < independentPlayQuestionInfo.completion_time
         {
             trailPromptTimeForUser = 0
             SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
         }
     }
     
    private func stopTimer() {
        AutismTimer.shared.stopTimer()

    }
     
     private func stopSpeechAndRecorder() {
         SpeechManager.shared.setDelegate(delegate: nil)
         RecordingManager.shared.stopRecording()
         RecordingManager.shared.stopWaitUserAnswerTimer()
     }
}

extension AssessmentIndependentPlayViewController: SpeechManagerDelegate {
    
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob {
                       self.avatarImageView.animatedImage =  getIdleGif()
                   }
               }
        else {
                self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.stopSpeechAndRecorder()
            self.independentPlayViewModel.submitUserAnswer(successCount: completeRate, info: self.independentPlayQuestionInfo, timeTaken: timeTakenToSolve, skip: false)
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

extension AssessmentIndependentPlayViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
        SpeechManager.shared.speak(message:self.independentPlayQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        AutismTimer.shared.initializeTimer(delegate: self)
    }
}

extension AssessmentIndependentPlayViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        print("self.apiDataState = ", self.apiDataState)
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall || self.apiDataState == .dataFetched) {
                self.reDownloadImages()
            } else {
                
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentIndependentPlayViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
