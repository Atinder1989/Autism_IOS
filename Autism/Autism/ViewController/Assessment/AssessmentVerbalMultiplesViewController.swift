//
//  AssessmentVerbalMultiplesViewController.swift
//  Autism
//
//  Created by Dilip Technology on 05/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage


class AssessmentVerbalMultiplesViewController: UIViewController {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var questionImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var imgV1: FLAnimatedImageView!
    @IBOutlet weak var imgV2: FLAnimatedImageView!
    @IBOutlet weak var imgV3: FLAnimatedImageView!
    @IBOutlet weak var imgV4: FLAnimatedImageView!
    @IBOutlet weak var imgV5: FLAnimatedImageView!
    @IBOutlet weak var imgV6: FLAnimatedImageView!
    @IBOutlet weak var imgV7: FLAnimatedImageView!
    @IBOutlet weak var imgV8: FLAnimatedImageView!
    @IBOutlet weak var imgV9: FLAnimatedImageView!
    @IBOutlet weak var imgV10: FLAnimatedImageView!
    
    private var verbalQuestionInfo: VerbalQuestionInfo!
    //private var answerResponseTimer: Timer? = nil
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var verbalViewModel = AssessmentVerbalViewModel()
    private weak var delegate: AssessmentSubmitDelegate?
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var touchOnEmptyScreenCount = 0

    
    var currentIndex:Int = 0
    
    var isRightAnswer:Bool = false
    
    private var isUserInteraction = false {
           didSet {
               self.view.isUserInteractionEnabled = isUserInteraction
           }
    }
    
    private var apiDataState: APIDataState = .notCall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.listenModelClosures()
        self.customSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
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
extension AssessmentVerbalMultiplesViewController {
    private func listenModelClosures() {
              self.verbalViewModel.dataClosure = {
                        DispatchQueue.main.async {
                            if let res = self.verbalViewModel.accessmentSubmitResponseVO {
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
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        self.questionTitle.text = verbalQuestionInfo.question_title
         
        self.imgV1.frame = self.questionImageView.frame
        self.imgV1.center = view.center
        
        self.imgV1.layer.borderWidth = 2.0
        self.imgV1.layer.borderColor = UIColor.clear.cgColor
        
        self.imgV2.layer.borderWidth = 2.0
        self.imgV2.layer.borderColor = UIColor.clear.cgColor

        self.imgV3.layer.borderWidth = 2.0
        self.imgV3.layer.borderColor = UIColor.clear.cgColor

        self.imgV4.layer.borderWidth = 2.0
        self.imgV4.layer.borderColor = UIColor.clear.cgColor

        self.imgV5.layer.borderWidth = 2.0
        self.imgV5.layer.borderColor = UIColor.clear.cgColor

        self.imgV6.layer.borderWidth = 2.0
        self.imgV6.layer.borderColor = UIColor.clear.cgColor

        self.imgV7.layer.borderWidth = 2.0
        self.imgV7.layer.borderColor = UIColor.clear.cgColor

        self.imgV8.layer.borderWidth = 2.0
        self.imgV8.layer.borderColor = UIColor.clear.cgColor

        self.imgV9.layer.borderWidth = 2.0
        self.imgV9.layer.borderColor = UIColor.clear.cgColor

        self.imgV10.layer.borderWidth = 2.0
        self.imgV10.layer.borderColor = UIColor.clear.cgColor

        let xRef:CGFloat = UIScreen.main.bounds.size.width-64-25
        
        self.imgV2.center = CGPoint(x: xRef, y: self.imgV2.center.y)
        self.imgV3.center = CGPoint(x: xRef, y: self.imgV3.center.y)
        self.imgV4.center = CGPoint(x: xRef, y: self.imgV4.center.y)
        self.imgV5.center = CGPoint(x: xRef, y: self.imgV5.center.y)
        self.imgV6.center = CGPoint(x: xRef, y: self.imgV6.center.y)
        self.imgV7.center = CGPoint(x: xRef, y: self.imgV7.center.y)
        self.imgV8.center = CGPoint(x: xRef, y: self.imgV8.center.y)
        self.imgV9.center = CGPoint(x: xRef, y: self.imgV9.center.y)
        self.imgV10.center = CGPoint(x: xRef, y: self.imgV10.center.y)
        
       // ImageDownloader.sharedInstance.makeTotalZero()
        if(self.verbalQuestionInfo.image.lowercased().contains(".gif") == false) {

            if(self.verbalQuestionInfo.image_with_text.count>0){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[0].image, imageView: self.imgV1, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>1){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[1].image, imageView: self.imgV2, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>2){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[2].image, imageView: self.imgV3, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>3){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[3].image, imageView: self.imgV4, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>4){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[4].image, imageView: self.imgV5, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>5){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[5].image, imageView: self.imgV6, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }

            if(self.verbalQuestionInfo.image_with_text.count>6){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[6].image, imageView: self.imgV7, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }

            if(self.verbalQuestionInfo.image_with_text.count>7){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[7].image, imageView: self.imgV8, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }

            if(self.verbalQuestionInfo.image_with_text.count>8){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[8].image, imageView: self.imgV9, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }

            if(self.verbalQuestionInfo.image_with_text.count>9){
                ImageDownloader.sharedInstance.downloadImage(urlString: self.verbalQuestionInfo.image_with_text[9].image, imageView: self.imgV10, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }

            
        } else {
            
            if(self.verbalQuestionInfo.image_with_text.count>0){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[0].image, imageView: self.imgV1, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>1){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[1].image, imageView: self.imgV2, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>2){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[2].image, imageView: self.imgV3, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>3){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[3].image, imageView: self.imgV4, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>4){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[4].image, imageView: self.imgV5, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>5){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[5].image, imageView: self.imgV6, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>6){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[6].image, imageView: self.imgV7, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
            
            if(self.verbalQuestionInfo.image_with_text.count>7){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[7].image, imageView: self.imgV8, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }

            if(self.verbalQuestionInfo.image_with_text.count>8){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[8].image, imageView: self.imgV9, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }

            if(self.verbalQuestionInfo.image_with_text.count>9){
                ImageDownloader.sharedInstance.downloadGIFImage(urlString: self.verbalQuestionInfo.image_with_text[9].image, imageView: self.imgV10, callbackAfterNoofImages: self.verbalQuestionInfo.image_with_text.count, delegate: self)
            }
        }
    }

    func showNextImage()
    {
        let imgWH:CGFloat = 70
        let yRef:CGFloat = 80
        let ySpace:CGFloat = 5
        
        self.isRightAnswer = false
        userAnswer.text = ""
        if(currentIndex < self.verbalQuestionInfo.image_with_text.count) {
            
            UIView.animate(withDuration: 0.5,
                                  delay: 0,
                                options: [],
                             animations: {
                                if(self.currentIndex == 1) {
                                    self.imgV1.frame = CGRect(x: 50, y: yRef+(0*imgWH)+(0*ySpace), width: imgWH, height: imgWH)
                                    self.imgV2.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 2) {
                                    self.imgV2.frame = CGRect(x: 50, y: yRef+(1*imgWH)+(1*ySpace), width: imgWH, height: imgWH)
                                    self.imgV3.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 3) {
                                    self.imgV3.frame = CGRect(x: 50, y: yRef+(2*imgWH)+(2*ySpace), width: imgWH, height: imgWH)
                                    self.imgV4.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 4) {
                                    self.imgV4.frame = CGRect(x: 50, y: yRef+(3*imgWH)+(3*ySpace), width: imgWH, height: imgWH)
                                    self.imgV5.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 5) {
                                    self.imgV5.frame = CGRect(x: 50, y: yRef+(4*imgWH)+(4*ySpace), width: imgWH, height: imgWH)
                                    self.imgV6.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 6) {
                                    self.imgV6.frame = CGRect(x: 50, y: yRef+(5*imgWH)+(5*ySpace), width: imgWH, height: imgWH)
                                    self.imgV7.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 7) {
                                    self.imgV7.frame = CGRect(x: 50, y: yRef+(6*imgWH)+(6*ySpace), width: imgWH, height: imgWH)
                                    self.imgV8.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 8) {
                                    self.imgV8.frame = CGRect(x: 50, y: yRef+(7*imgWH)+(7*ySpace), width: imgWH, height: imgWH)
                                    self.imgV9.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 9) {
                                    self.imgV9.frame = CGRect(x: 50, y: yRef+(8*imgWH)+(8*ySpace), width: imgWH, height: imgWH)
                                    self.imgV10.frame = self.questionImageView.frame
                                }
                             }, completion: {_ in
                                self.setBorderForIndex(index: self.currentIndex-1)
                                SpeechManager.shared.setDelegate(delegate: self)
                                SpeechManager.shared.speak(message: self.verbalQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                             }
            )
        }
    }
    
    private func setBorderForIndex(index:Int)
    {
        if(self.verbalQuestionInfo.image_with_text.count-1 == index) {
            return
        }
        if(self.verbalQuestionInfo.image_with_text[index].isCorrectAnswer == true) {
            if(index==0) {
                self.imgV1.layer.cornerRadius = self.imgV1.frame.size.width/2.0
                self.imgV1.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==1) {
                self.imgV2.layer.cornerRadius = self.imgV2.frame.size.width/2.0
                self.imgV2.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==2) {
                self.imgV3.layer.cornerRadius = self.imgV3.frame.size.width/2.0
                self.imgV3.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==3) {
                self.imgV4.layer.cornerRadius = self.imgV4.frame.size.width/2.0
                self.imgV4.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==4) {
                self.imgV5.layer.cornerRadius = self.imgV5.frame.size.width/2.0
                self.imgV5.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==5) {
                self.imgV6.layer.cornerRadius = self.imgV6.frame.size.width/2.0
                self.imgV6.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==6) {
                self.imgV7.layer.cornerRadius = self.imgV7.frame.size.width/2.0
                self.imgV7.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==7) {
                self.imgV8.layer.cornerRadius = self.imgV8.frame.size.width/2.0
                self.imgV8.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==8) {
                self.imgV9.layer.cornerRadius = self.imgV9.frame.size.width/2.0
                self.imgV9.layer.borderColor = UIColor.systemGreen.cgColor
            } else if(index==9) {
                self.imgV10.layer.cornerRadius = self.imgV10.frame.size.width/2.0
                self.imgV10.layer.borderColor = UIColor.systemGreen.cgColor
            }
        } else {
            if(index==0) {
                self.imgV1.layer.cornerRadius = self.imgV1.frame.size.width/2.0
                self.imgV1.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==1) {
                self.imgV2.layer.cornerRadius = self.imgV2.frame.size.width/2.0
                self.imgV2.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==2) {
                self.imgV3.layer.cornerRadius = self.imgV3.frame.size.width/2.0
                self.imgV3.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==3) {
                self.imgV4.layer.cornerRadius = self.imgV4.frame.size.width/2.0
                self.imgV4.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==4) {
                self.imgV5.layer.cornerRadius = self.imgV5.frame.size.width/2.0
                self.imgV5.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==5) {
                self.imgV6.layer.cornerRadius = self.imgV6.frame.size.width/2.0
                self.imgV6.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==6) {
                self.imgV7.layer.cornerRadius = self.imgV7.frame.size.width/2.0
                self.imgV7.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==7) {
                self.imgV8.layer.cornerRadius = self.imgV8.frame.size.width/2.0
                self.imgV8.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==8) {
                self.imgV9.layer.cornerRadius = self.imgV9.frame.size.width/2.0
                self.imgV9.layer.borderColor = UIColor.systemRed.cgColor
            } else if(index==9) {
                self.imgV10.layer.cornerRadius = self.imgV10.frame.size.width/2.0
                self.imgV10.layer.borderColor = UIColor.systemRed.cgColor
            }
        }
    }
        
   private func initializeTimer() {
    AutismTimer.shared.initializeTimer(delegate: self)
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
        if(isUserInteraction == false) {
            return
        }
        self.timeTakenToSolve += 1
                
        if self.timeTakenToSolve >= verbalQuestionInfo.trial_time  {
            self.moveToNextQuestion()
        } else {
            
            let time_inteval = verbalQuestionInfo.time_interval+(currentIndex*verbalQuestionInfo.time_interval)
            if (self.timeTakenToSolve >= time_inteval) {
                currentIndex = currentIndex+1
                
                isUserInteraction = false
                RecordingManager.shared.stopRecording()
                
                
                if(currentIndex < self.verbalQuestionInfo.image_with_text.count) {
                    self.showNextImage()
                } else {
                    self.moveToNextQuestion()
                }
            }
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

// MARK: Public Methods
extension AssessmentVerbalMultiplesViewController {
    func setVerbalQuestionInfo(info:VerbalQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.verbalQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentVerbalMultiplesViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        /*
        self.avatarImageView.isHidden = true
        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob {
                       self.avatarImageView.animatedImage =  idleGif
                   }
               }
        else {
                self.avatarImageView.animatedImage =  idleGif
        }
 */
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.stopSpeechAndRecorder()
            self.verbalViewModel.submitVerbalQuestionDetails(info: self.verbalQuestionInfo, completeRate: self.completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
            break
            
        case .inProgress:
            if(isRightAnswer == true) {
                self.showNextImage()
            } else {
                isUserInteraction = true
                RecordingManager.shared.startRecording(delegate: self)
            }
            break
        default:
            isUserInteraction = true
            RecordingManager.shared.startRecording(delegate: self)
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        /*
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
         */
    }
}

//MARK:- RecordingManager Delegate Methods
extension AssessmentVerbalMultiplesViewController: RecordingManagerDelegate {
    func recordingSpeechData(text:String) {
        self.userAnswer.text = text
    }
    
    func recordingStart() {
    }
    
    func recordingFinish(speechText:String) {
        RecordingManager.shared.stopRecording()
        self.checkUserAnswer(text: speechText)
    }
     
    func checkUserAnswer(text:String) {
        if text.count > 0 {
            
            if Utility.sharedInstance.isAnswerMatched(text: text, answer: self.verbalQuestionInfo.image_with_text[currentIndex].name) {
                

                self.verbalQuestionInfo.image_with_text[currentIndex].isCorrectAnswer = true
                
                self.completeRate = self.completeRate + (100/verbalQuestionInfo.image_with_text.count)
                self.currentIndex = self.currentIndex+1
                self.timeTakenToSolve = currentIndex*self.verbalQuestionInfo.time_interval
                if(currentIndex < self.verbalQuestionInfo.image_with_text.count) {
                    self.questionState = .inProgress
                    isUserInteraction = false
                    RecordingManager.shared.stopRecording()
                    self.isRightAnswer = true
                    
                    SpeechManager.shared.speak(message: SpeechMessage.excellentWork.getMessage(self.verbalQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    
                } else {
                    if(self.verbalQuestionInfo.image_with_text.count == currentIndex) {
                        
                    } else {
                    if(currentIndex == 1){
                        self.imgV1.layer.cornerRadius = self.imgV1.frame.size.width/2.0
                        self.imgV1.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 2){
                        self.imgV2.layer.cornerRadius = self.imgV2.frame.size.width/2.0
                        self.imgV2.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 3){
                        self.imgV3.layer.cornerRadius = self.imgV3.frame.size.width/2.0
                        self.imgV3.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 4){
                        self.imgV4.layer.cornerRadius = self.imgV4.frame.size.width/2.0
                        self.imgV4.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 5){
                        self.imgV5.layer.cornerRadius = self.imgV5.frame.size.width/2.0
                        self.imgV5.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 6){
                        self.imgV6.layer.cornerRadius = self.imgV6.frame.size.width/2.0
                        self.imgV6.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 7){
                        self.imgV7.layer.cornerRadius = self.imgV7.frame.size.width/2.0
                        self.imgV7.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 8){
                        self.imgV8.layer.cornerRadius = self.imgV8.frame.size.width/2.0
                        self.imgV8.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 9){
                        self.imgV9.layer.cornerRadius = self.imgV9.frame.size.width/2.0
                        self.imgV9.layer.borderColor = UIColor.systemGreen.cgColor
                    } else if(currentIndex == 10){
                        self.imgV10.layer.cornerRadius = self.imgV10.frame.size.width/2.0
                        self.imgV10.layer.borderColor = UIColor.systemGreen.cgColor
                    }
                    }
                    
                    self.questionState = .submit
                    //self.imgV6.la
                    SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.verbalQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            } else {
                if(currentIndex == self.verbalQuestionInfo.image_with_text.count-1) {
                    
                    currentIndex = currentIndex+1
                                        
                    if(self.verbalQuestionInfo.image_with_text.count != currentIndex) {
                        if(currentIndex == 1){
                            self.imgV1.layer.cornerRadius = self.imgV1.frame.size.width/2.0
                            self.imgV1.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 2){
                            self.imgV2.layer.cornerRadius = self.imgV2.frame.size.width/2.0
                            self.imgV2.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 3){
                            self.imgV3.layer.cornerRadius = self.imgV3.frame.size.width/2.0
                            self.imgV3.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 4){
                            self.imgV4.layer.cornerRadius = self.imgV4.frame.size.width/2.0
                            self.imgV4.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 5){
                            self.imgV5.layer.cornerRadius = self.imgV5.frame.size.width/2.0
                            self.imgV5.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 6){
                            self.imgV6.layer.cornerRadius = self.imgV6.frame.size.width/2.0
                            self.imgV6.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 7){
                            self.imgV7.layer.cornerRadius = self.imgV7.frame.size.width/2.0
                            self.imgV7.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 8){
                            self.imgV8.layer.cornerRadius = self.imgV8.frame.size.width/2.0
                            self.imgV8.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 9){
                            self.imgV9.layer.cornerRadius = self.imgV9.frame.size.width/2.0
                            self.imgV9.layer.borderColor = UIColor.systemRed.cgColor
                        } else if(currentIndex == 10){
                            self.imgV10.layer.cornerRadius = self.imgV10.frame.size.width/2.0
                            self.imgV10.layer.borderColor = UIColor.systemRed.cgColor
                        }
                    }
                    
                    currentIndex = currentIndex-1
//                    self.imgV6.layer.cornerRadius = self.imgV6.frame.size.width/2.0
//                    self.imgV6.layer.borderColor = UIColor.systemRed.cgColor
                }
                self.verbalQuestionInfo.image_with_text[currentIndex].isCorrectAnswer = false
                self.isRightAnswer = false
                
                let answerArray = self.verbalQuestionInfo.image_with_text[currentIndex].name.lowercased().components(separatedBy: ",")
                if answerArray.count > 0 {
                    if(self.verbalQuestionInfo.incorrect_text == "") {
                        var correct_name:String = self.verbalQuestionInfo.image_with_text[currentIndex].name
                        correct_name = correct_name.components(separatedBy: ",").first!
                        
                        SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+correct_name, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    } else {
                        SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage(self.verbalQuestionInfo.incorrect_text.replacingOccurrences(of: "(correct_answer)", with: answerArray[0])), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    }
                }
            }
        } else {
            isUserInteraction = true
            RecordingManager.shared.startRecording(delegate: self)
        }
    }
}


extension AssessmentVerbalMultiplesViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            
            self.apiDataState = .imageDownloaded
            SpeechManager.shared.setDelegate(delegate: self)
            SpeechManager.shared.speak(message: self.verbalQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            self.initializeTimer()
        }
    }
}

extension AssessmentVerbalMultiplesViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall || self.apiDataState == .dataFetched) {
                self.listenModelClosures()
                self.customSetting()
            } else {
                
            }
            SpeechManager.shared.setDelegate(delegate: self)
            RecordingManager.shared.startRecording(delegate: self)
        }
    }
}

extension AssessmentVerbalMultiplesViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
