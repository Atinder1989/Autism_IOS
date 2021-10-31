//
//  AssessmentSoundImitationViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/12.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation

class AssessmentSoundImitationViewController: UIViewController {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswerLbl: UILabel!
    @IBOutlet weak var soundImageView: UIImageView!

    private weak var delegate: AssessmentSubmitDelegate?
    private var soundInfo: SoundImitationInfo!
    private var player : AVPlayer?
    private var timeTakenToSolve = 0
    private var soundViewModel = AssessmentSoundViewModel()
    private var questionState: QuestionState = .inProgress
    private var completeRate = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.listenModelClosures()
        self.customSetting()
        self.loadSound()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
}

// MARK: Public Methods
extension AssessmentSoundImitationViewController {
    func setQuestionInfo(info:SoundImitationInfo,delegate:AssessmentSubmitDelegate) {
        self.soundInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentSoundImitationViewController {
    private func listenModelClosures() {
                 self.soundViewModel.dataClosure = {
                           DispatchQueue.main.async {
                               if let res = self.soundViewModel.accessmentSubmitResponseVO {
                                   if res.success {
                                    DispatchQueue.main.async {
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
    
    private func customSetting() {
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = self.soundInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    private func loadSound() {
        self.isSoundIconHidden(state: false)

        do {
                    
            if let _ = player {
                self.player = nil
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            }
            
            guard let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl()+self.soundInfo.audio_file) else { return }
            let playerItem = AVPlayerItem.init(url: url)
            player = AVPlayer.init(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            player?.play()
            
           
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.isSoundIconHidden(state: true)
        RecordingManager.shared.startRecording(delegate: self)

    }
    
    private func isSoundIconHidden(state:Bool) {
        //self.soundImageView.isHidden = state
    }
      
     @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
         self.timeTakenToSolve += 1

        if self.timeTakenToSolve >= soundInfo.completion_time {
            self.stopTimer()
            RecordingManager.shared.stopRecording()
            RecordingManager.shared.stopWaitUserAnswerTimer()
            self.questionState = .submit
            self.completeRate = 0
            SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } 
     }
     
    private func stopTimer() {
        AutismTimer.shared.stopTimer()
         
     }
    
}

//MARK:- RecordingManager Delegate Methods

extension AssessmentSoundImitationViewController: RecordingManagerDelegate {
    
    func recordingStart() {
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.checkUserAnswer(text: speechText)
    }
    
    func checkUserAnswer(text:String) {
        if text.count > 0 {
            if text.lowercased().contains(self.soundInfo.answer.lowercased()) {
                completeRate = 100
                self.questionState = .submit
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.soundInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else {
                self.userAnswerLbl.text = ""
                self.questionState = .wrongAnswer
                SpeechManager.shared.speak(message: SpeechMessage.wrongAnswer.getMessage(self.soundInfo.incorrect_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)

              // self.loadSound()
            }
        } else {
            self.loadSound()
        }
    }
}


extension AssessmentSoundImitationViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
         switch self.questionState {
               case .submit:
                   self.stopTimer()
                   SpeechManager.shared.setDelegate(delegate: nil)
                   RecordingManager.shared.stopRecording()
                   RecordingManager.shared.stopWaitUserAnswerTimer()
                   
                   self.soundViewModel.submitSoundQuestionDetails(info: self.soundInfo, completeRate: completeRate, timetaken: self.timeTakenToSolve)
                   break
         case .wrongAnswer:
            self.loadSound()
            break
               default:
                        RecordingManager.shared.startRecording(delegate: self)
                   break
               }
        
    }
    
    func speechDidStart(speechText:String) {}
    
    func recordingSpeechData(text: String) {
        DispatchQueue.main.async {
            print("text === \(text)")
            self.userAnswerLbl.text = text
        }
    }
}

extension AssessmentSoundImitationViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentSoundImitationViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
