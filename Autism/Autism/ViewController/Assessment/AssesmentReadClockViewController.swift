//
//  AssesmentReadClockViewController.swift
//  Autism
//
//  Created by mac on 19/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage

class AssesmentReadClockViewController: UIViewController,AMClockViewDelegate {
    
    var readclockQuestionInfo: Readclock!
             
    private weak var delegate: AssessmentSubmitDelegate?
    private let readclockViewModel = AssesmentReadclockViewModel()
                    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
       
    private var completeRate = 0
    private var timeTakenToSolve = 0
    private var initialState = true
    
    @IBOutlet weak var cView1: AMClockView!
    @IBOutlet weak var timeLabel: UILabel!
    let dateFormatter = DateFormatter()

    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.customSetting()
        self.listenModelClosures()
    }
    
    func setSortQuestionInfo(info:Readclock,delegate:AssessmentSubmitDelegate) {
        self.readclockQuestionInfo = info
        self.delegate = delegate
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
          self.stopTimer()
          self.stopSpeechAndRecorder()
          UserManager.shared.exitAssessment()
    }
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
        self.skipQuestion = true
        self.moveToNextQuestion()
        }
    }
    
    
}


// MARK: Private Methods
extension AssesmentReadClockViewController {
    private func listenModelClosures() {
       self.readclockViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.readclockViewModel.accessmentSubmitResponseVO {
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
    
    private func customSetting() {
    
      SpeechManager.shared.setDelegate(delegate: self)
      
      lblTitle.text = readclockQuestionInfo.question_title
      lblTime.text = readclockQuestionInfo.answer_time
      self.finishDownloading()
          
      cView1.delegate = self
      cView1.timeZone = TimeZone(identifier: "Asia/Tokyo")
      dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
      dateFormatter.dateFormat = "HH:mm"
      
      cView1.selectedDate = dateFormatter.date(from: readclockQuestionInfo.answer_time)
    
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
        if self.timeTakenToSolve >= readclockQuestionInfo.trial_time  {
            self.moveToNextQuestion()
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

extension AssesmentReadClockViewController {
    
    func clockView(_ clockView: AMClockView, didChangeDate date: Date) {
        if let timeZone = clockView.timeZone {
            dateFormatter.timeZone = timeZone
        }
        timeLabel.text = "selected time: " + dateFormatter.string(from: date);
    }
}

extension AssesmentReadClockViewController: SpeechManagerDelegate {
    
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
        
        RecordingManager.shared.startRecording(delegate: self)
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.stopSpeechAndRecorder()
            self.readclockViewModel.submitUserAnswer(successCount: 100, info: self.readclockQuestionInfo, timeTaken: self.timeTakenToSolve)
            
            break
        default:
            break
        }
    }
    
    func speechDidStart(speechText:String) {
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

extension AssesmentReadClockViewController: RecordingManagerDelegate {
    
    func recordingSpeechData(text:String) {
//        self.userAnswer.text = text.lowercased()
    }
    
    func recordingStart() {
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.checkUserAnswer(text: speechText)
    }
    
    func checkUserAnswer(text:String) {
        if text.count > 0 {
            
            let strAnswer0 = self.readclockQuestionInfo.hour+self.readclockQuestionInfo.minute
            var strAnswer:String = ""
            if(self.readclockQuestionInfo.minute == "00") {
                
                strAnswer = self.readclockQuestionInfo.hour+" o'clock"
                let strAnswer1 = self.readclockQuestionInfo.hour+":"+((self.readclockQuestionInfo.minute.count == 1) ? ("0"+self.readclockQuestionInfo.minute) : self.readclockQuestionInfo.minute)

                if(text.lowercased().contains(strAnswer0) || text.lowercased().contains(strAnswer) || text.lowercased().contains(strAnswer1)) {
                    self.handleCorretTime()
                } else {
                    self.handleWrongTime()
                }
            } else if(self.readclockQuestionInfo.minute == "15") {
                //It's quarter past 6.
                //It's 15 past 6
                //It's 45 to 7.
                strAnswer = self.readclockQuestionInfo.hour+":"+((self.readclockQuestionInfo.minute.count == 1) ? ("0"+self.readclockQuestionInfo.minute) : self.readclockQuestionInfo.minute)
                
                let strAnswer1 = self.readclockQuestionInfo.minute+" past "+self.readclockQuestionInfo.hour
                let strAnswer2 = self.readclockQuestionInfo.minute+"+"+self.readclockQuestionInfo.hour
                
                var strAnswer3 = ""
                if(self.readclockQuestionInfo.hour == "12") {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to 1"
                } else {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to "+String(Int(self.readclockQuestionInfo.hour)!+1)
                }
                
                let strAnswer4 = "quarter past "+self.readclockQuestionInfo.hour
                let strAnswer5 = "15 past "+self.readclockQuestionInfo.hour
                
                if(text.lowercased().contains(strAnswer0) || text.lowercased().contains(strAnswer) || text.lowercased().contains(strAnswer1) || text.lowercased().contains(strAnswer2) || text.lowercased().contains(strAnswer3) || text.lowercased().contains(strAnswer4) || text.lowercased().contains(strAnswer5)) {
                    self.handleCorretTime()
                } else {
                    self.handleWrongTime()
                }
            } else if(self.readclockQuestionInfo.minute == "30") {
                //It's half past 6.
                //It's 30 past 6.
                //It's 30 to 7.
                
                strAnswer = self.readclockQuestionInfo.hour+":"+((self.readclockQuestionInfo.minute.count == 1) ? ("0"+self.readclockQuestionInfo.minute) : self.readclockQuestionInfo.minute)
                let strAnswer1 = self.readclockQuestionInfo.minute+" past "+self.readclockQuestionInfo.hour
                let strAnswer2 = self.readclockQuestionInfo.minute+"+"+self.readclockQuestionInfo.hour
                
                var strAnswer3 = ""
                if(self.readclockQuestionInfo.hour == "12") {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to 1"
                } else {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to "+String(Int(self.readclockQuestionInfo.hour)!+1)
                }
                
                let strAnswer4 = "half past "+self.readclockQuestionInfo.hour
                let strAnswer5 = "30 past "+self.readclockQuestionInfo.hour
                                
                if(text.lowercased().contains(strAnswer0) || text.lowercased().contains(strAnswer) || text.lowercased().contains(strAnswer1) || text.lowercased().contains(strAnswer2) || text.lowercased().contains(strAnswer3) || text.lowercased().contains(strAnswer4) || text.lowercased().contains(strAnswer5)) {
                    self.handleCorretTime()
                } else {
                    self.handleWrongTime()
                }
            } else if(self.readclockQuestionInfo.minute == "45") {
                //It's 45 past 6.
                //It's 15 to 7.
                //It's quarter to 7.
                strAnswer = self.readclockQuestionInfo.hour+":"+((self.readclockQuestionInfo.minute.count == 1) ? ("0"+self.readclockQuestionInfo.minute) : self.readclockQuestionInfo.minute)
                let strAnswer1 = self.readclockQuestionInfo.minute+" past "+self.readclockQuestionInfo.hour
                let strAnswer2 = self.readclockQuestionInfo.minute+"+"+self.readclockQuestionInfo.hour
                
                var strAnswer3 = ""
                if(self.readclockQuestionInfo.hour == "12") {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to 1"
                } else {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to "+String(Int(self.readclockQuestionInfo.hour)!+1)
                }
                
                let strAnswer4 = "45 past "+self.readclockQuestionInfo.hour

                var strAnswer5 = ""
                if(self.readclockQuestionInfo.hour == "12") {
                    strAnswer5 = "quarter to 1"
                } else {
                    strAnswer5 = "quarter to "+String(Int(self.readclockQuestionInfo.hour)!+1)
                }
                
                if(text.lowercased().contains(strAnswer0) || text.lowercased().contains(strAnswer) || text.lowercased().contains(strAnswer1) || text.lowercased().contains(strAnswer2) || text.lowercased().contains(strAnswer3) || text.lowercased().contains(strAnswer4) || text.lowercased().contains(strAnswer5)) {
                    self.handleCorretTime()
                } else {
                    self.handleWrongTime()
                }
            } else {
                
                strAnswer = self.readclockQuestionInfo.hour+":"+((self.readclockQuestionInfo.minute.count == 1) ? ("0"+self.readclockQuestionInfo.minute) : self.readclockQuestionInfo.minute)
                
                let strAnswer1 = self.readclockQuestionInfo.minute+"+"+self.readclockQuestionInfo.hour
                let strAnswer2 = self.readclockQuestionInfo.minute+" past "+self.readclockQuestionInfo.hour
                var strAnswer3 = ""
                
                if(self.readclockQuestionInfo.hour == "12") {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to 1"
                } else {
                    strAnswer3 = String(60-Int(self.readclockQuestionInfo.minute)!)+" to "+String(Int(self.readclockQuestionInfo.hour)!+1)
                }
                
                if(text.lowercased().contains(strAnswer0) || text.lowercased().contains(strAnswer) || text.lowercased().contains(strAnswer1) || text.lowercased().contains(strAnswer2) || text.lowercased().contains(strAnswer3)) {
                    self.handleCorretTime()
                } else {
                    self.handleWrongTime()
                }
            }
            
        } else {
            SpeechManager.shared.speak(message: "Lets Try Again", uttrenceRate: 0.4)
        }
    }
    
    func handleCorretTime()
    {
        questionState = .submit
        self.completeRate = 100
        SpeechManager.shared.speak(message: self.readclockQuestionInfo.correct_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                
        self.stopTimer()
    }
    
    func handleWrongTime()
    {
        self.completeRate = 0
        SpeechManager.shared.speak(message: self.readclockQuestionInfo.incorrect_text, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
}

extension AssesmentReadClockViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            SpeechManager.shared.speak(message: self.readclockQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            AutismTimer.shared.initializeTimer(delegate: self)
        }
    }
}

extension AssesmentReadClockViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssesmentReadClockViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
