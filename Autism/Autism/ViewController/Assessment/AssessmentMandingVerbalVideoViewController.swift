//
//  AssessmentMandingVerbalVideoViewController.swift
//  Autism
//
//  Created by Dilip Technology on 18/03/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class AssessmentMandingVerbalVideoViewController: UIViewController {
    
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var userAnswer: UILabel!
    @IBOutlet weak var questionImageView: FLAnimatedImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
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
    
    private var player1: AVPlayer!
    private var playerLayer1: AVPlayerLayer!
    
    private var player2: AVPlayer!
    private var playerLayer2: AVPlayerLayer!
    
    private var player3: AVPlayer!
    private var playerLayer3: AVPlayerLayer!
    
    private var player4: AVPlayer!
    private var playerLayer4: AVPlayerLayer!
    
    private var player5: AVPlayer!
    private var playerLayer5: AVPlayerLayer!
    
    private var player6: AVPlayer!
    private var playerLayer6: AVPlayerLayer!
    
    private var player7: AVPlayer!
    private var playerLayer7: AVPlayerLayer!
    
    private var player8: AVPlayer!
    private var playerLayer8: AVPlayerLayer!
    
    private var player9: AVPlayer!
    private var playerLayer9: AVPlayerLayer!
    
    private var player10: AVPlayer!
    private var playerLayer10: AVPlayerLayer!
    
    private var verbalQuestionInfo: VerbalQuestionInfo!
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
    
    private var observer: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listenModelClosures()
        self.customSetting()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let ob = observer {
            NotificationCenter.default.removeObserver(ob)
            
            if(player1 != nil) {
                player1 = nil
            }
            if(player2 != nil) {
                player2 = nil
            }
            if(player3 != nil) {
                player3 = nil
            }
            if(player4 != nil) {
                player4 = nil
            }
            if(player5 != nil) {
                player5 = nil
            }
            if(player6 != nil) {
                player6 = nil
            }
            if(player7 != nil) {
                player7 = nil
            }
            if(player8 != nil) {
                player8 = nil
            }
            if(player9 != nil) {
                player9 = nil
            }
            if(player10 != nil) {
                player10 = nil
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if(playerLayer1 != nil) {
            playerLayer1.frame = imgV1.bounds
        }
        
        if(playerLayer2 != nil) {
            playerLayer2.frame = imgV2.bounds
        }
        
        if(playerLayer3 != nil) {
            playerLayer3.frame = imgV3.bounds
        }
        
        if(playerLayer4 != nil) {
            playerLayer4.frame = imgV4.bounds
        }
        
        if(playerLayer5 != nil) {
            playerLayer5.frame = imgV5.bounds
        }
        
        if(playerLayer6 != nil) {
            playerLayer6.frame = imgV6.bounds
        }
        
        if(playerLayer7 != nil) {
            playerLayer7.frame = imgV7.bounds
        }
        
        if(playerLayer8 != nil) {
            playerLayer8.frame = imgV8.bounds
        }
        
        if(playerLayer9 != nil) {
            playerLayer9.frame = imgV9.bounds
        }
        
        if(playerLayer10 != nil) {
            playerLayer10.frame = imgV10.bounds
        }
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
extension AssessmentMandingVerbalVideoViewController {
    private func listenModelClosures() {
        self.verbalViewModel.dataClosure = {
            DispatchQueue.main.async {
                if let res = self.verbalViewModel.accessmentSubmitResponseVO {
                    if res.success {
                        if let ob = self.observer {
                            NotificationCenter.default.removeObserver(ob)
                        }
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
       
        self.setCenterVideoFrame()
                        
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

        var xRef:CGFloat = UIScreen.main.bounds.size.width-90
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            xRef = UIScreen.main.bounds.size.width-50
        }
        
        self.imgV2.center = CGPoint(x: xRef, y: self.imgV2.center.y)
        self.imgV3.center = CGPoint(x: xRef, y: self.imgV3.center.y)
        self.imgV4.center = CGPoint(x: xRef, y: self.imgV4.center.y)
        self.imgV5.center = CGPoint(x: xRef, y: self.imgV5.center.y)
        self.imgV6.center = CGPoint(x: xRef, y: self.imgV6.center.y)
        self.imgV7.center = CGPoint(x: xRef, y: self.imgV7.center.y)
        self.imgV8.center = CGPoint(x: xRef, y: self.imgV8.center.y)
        self.imgV9.center = CGPoint(x: xRef, y: self.imgV9.center.y)
        self.imgV10.center = CGPoint(x: xRef, y: self.imgV10.center.y)
        
        if(self.verbalQuestionInfo.image_with_text.count == 0) {
            isUserInteraction = true
        }
        
        observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                              object: nil,
                                              queue: nil) { [weak self] note in


            if(self?.currentIndex == 0) {
                if(self?.player1 != nil)
                {
                    self?.player1.seek(to: CMTime.zero)
                    self!.player1.rate = 0
                    self!.apiDataState = .imageDownloaded

                    self?.initializeTimer()

                    self?.player1.pause()
                }
            } else if(self?.currentIndex == 1) {
                if(self?.player2 != nil)
                {
                    self?.player2.seek(to: CMTime.zero)
                    self!.player2.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player2.pause()
                }
            } else if(self?.currentIndex == 2) {
                if(self?.player3 != nil)
                {
                    self?.player3.seek(to: CMTime.zero)
                    self!.player3.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player3.pause()
                }
            } else if(self?.currentIndex == 3) {
                if(self?.player4 != nil)
                {
                    self?.player4.seek(to: CMTime.zero)
                    self!.player4.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player4.pause()
                }
            } else if(self?.currentIndex == 4) {
                if(self?.player5 != nil)
                {
                    self?.player5.seek(to: CMTime.zero)
                    self!.player5.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player5.pause()
                }
            } else if(self?.currentIndex == 5) {
                if(self?.player6 != nil)
                {
                    self?.player6.seek(to: CMTime.zero)
                    self!.player6.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player6.pause()
                }
            } else if(self?.currentIndex == 6) {
                if(self?.player7 != nil)
                {
                    self?.player7.seek(to: CMTime.zero)
                    self!.player7.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player7.pause()
                }
            } else if(self?.currentIndex == 7) {
                if(self?.player8 != nil)
                {
                    self?.player8.seek(to: CMTime.zero)
                    self!.player8.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player8.pause()
                }
            } else if(self?.currentIndex == 8) {
                if(self?.player9 != nil)
                {
                    self?.player9.seek(to: CMTime.zero)
                    self!.player9.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player9.pause()
                }
            } else if(self?.currentIndex == 9) {
                if(self?.player10 != nil)
                {
                    self?.player10.seek(to: CMTime.zero)
                    self!.player10.rate = 0
                    self!.apiDataState = .imageDownloaded
                    self?.player10.pause()
                }
            }
            SpeechManager.shared.setDelegate(delegate: self)
            SpeechManager.shared.speak(message: self!.verbalQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>0){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[0].image) {
             player1 = AVPlayer(url: url)
             playerLayer1 = AVPlayerLayer(player: player1)
             playerLayer1.videoGravity = .resize
             player1.play()
             imgV1.layer.addSublayer(playerLayer1)
             
             }
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>1){

            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[1].image) {
                 player2 = AVPlayer(url: url)
                 playerLayer2 = AVPlayerLayer(player: player2)
                 playerLayer2.videoGravity = .resize
                 imgV2.layer.addSublayer(playerLayer2)
             }
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>2){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[2].image) {
                 player3 = AVPlayer(url: url)
                 playerLayer3 = AVPlayerLayer(player: player3)
                 playerLayer3.videoGravity = .resize
                 imgV3.layer.addSublayer(playerLayer3)
             }
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>3){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[3].image) {
                 player4 = AVPlayer(url: url)
                 playerLayer4 = AVPlayerLayer(player: player4)
                 playerLayer4.videoGravity = .resize
                 imgV4.layer.addSublayer(playerLayer4)
             }
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>4){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[4].image) {
                 player5 = AVPlayer(url: url)
                 playerLayer5 = AVPlayerLayer(player: player5)
                 playerLayer5.videoGravity = .resize
                 imgV5.layer.addSublayer(playerLayer5)
             }
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>5){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[5].image) {
                 player6 = AVPlayer(url: url)
                 playerLayer6 = AVPlayerLayer(player: player6)
                 playerLayer6.videoGravity = .resize
                 imgV6.layer.addSublayer(playerLayer6)
             }
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>6){
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[6].image) {
                 player7 = AVPlayer(url: url)
                 playerLayer7 = AVPlayerLayer(player: player7)
                 playerLayer7.videoGravity = .resize
                 imgV7.layer.addSublayer(playerLayer7)
             }
        }
        
        if(self.verbalQuestionInfo.image_with_text.count>7){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[7].image) {
                 player8 = AVPlayer(url: url)
                 playerLayer8 = AVPlayerLayer(player: player8)
                 playerLayer8.videoGravity = .resize
                 imgV8.layer.addSublayer(playerLayer8)
             }
        }

        if(self.verbalQuestionInfo.image_with_text.count>8){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[8].image) {
                 player9 = AVPlayer(url: url)
                 playerLayer9 = AVPlayerLayer(player: player9)
                 playerLayer9.videoGravity = .resize
                 player9.play()
                 imgV9.layer.addSublayer(playerLayer9)
             }
        }

        if(self.verbalQuestionInfo.image_with_text.count>9){
            
            if let url = URL.init(string: ServiceHelper.baseURL.getMediaBaseUrl() + self.verbalQuestionInfo.image_with_text[9].image) {
                 player10 = AVPlayer(url: url)
                 playerLayer10 = AVPlayerLayer(player: player10)
                 playerLayer10.videoGravity = .resize
                 imgV10.layer.addSublayer(playerLayer10)
             }
        }
    }

    func showNextImage()
    {
//        let xRef:CGFloat = 10
//        let imgWH:CGFloat = 44
//        let yRef:CGFloat = 80
//        let ySpace:CGFloat = 5
        
        var imgWH:CGFloat = 70
        var xRef:CGFloat = 15
        var yRef:CGFloat = 80
        var ySpace:CGFloat = 5

        if(UIDevice.current.userInterfaceIdiom != .pad) {
            imgWH = 60
            xRef = 50
            yRef = 80
            ySpace = 5
        }
        
        self.isRightAnswer = false
        userAnswer.text = ""

        self.setCenterVideoFrame()
        
        if(currentIndex < self.verbalQuestionInfo.image_with_text.count) {
            
            UIView.animate(withDuration: 0.5,
                                  delay: 0,
                                options: [],
                             animations: {
                                if(self.currentIndex == 1) {
                                    self.imgV1.frame = CGRect(x: xRef, y: yRef+(0*imgWH)+(0*ySpace), width: imgWH, height: imgWH)
                                    self.imgV2.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 2) {
                                    self.imgV2.frame = CGRect(x: xRef, y: yRef+(1*imgWH)+(1*ySpace), width: imgWH, height: imgWH)
                                    self.imgV3.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 3) {
                                    self.imgV3.frame = CGRect(x: xRef, y: yRef+(2*imgWH)+(2*ySpace), width: imgWH, height: imgWH)
                                    self.imgV4.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 4) {
                                    self.imgV4.frame = CGRect(x: xRef, y: yRef+(3*imgWH)+(3*ySpace), width: imgWH, height: imgWH)
                                    self.imgV5.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 5) {
                                    self.imgV5.frame = CGRect(x: xRef, y: yRef+(4*imgWH)+(4*ySpace), width: imgWH, height: imgWH)
                                    self.imgV6.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 6) {
                                    self.imgV6.frame = CGRect(x: xRef, y: yRef+(5*imgWH)+(5*ySpace), width: imgWH, height: imgWH)
                                    self.imgV7.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 7) {
                                    self.imgV7.frame = CGRect(x: xRef, y: yRef+(6*imgWH)+(6*ySpace), width: imgWH, height: imgWH)
                                    self.imgV8.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 8) {
                                    self.imgV8.frame = CGRect(x: xRef, y: yRef+(7*imgWH)+(7*ySpace), width: imgWH, height: imgWH)
                                    self.imgV9.frame = self.questionImageView.frame
                                } else if(self.currentIndex == 9) {
                                    self.imgV9.frame = CGRect(x: xRef, y: yRef+(8*imgWH)+(8*ySpace), width: imgWH, height: imgWH)
                                    self.imgV10.frame = self.questionImageView.frame
                                }
                             }, completion: {_ in
                                self.setBorderForIndex(index: self.currentIndex-1)
                                if(self.currentIndex == 1) {
                                    self.player2.play()
                                } else if(self.currentIndex == 2) {
                                    self.player3.play()
                                } else if(self.currentIndex == 3) {
                                    self.player4.play()
                                } else if(self.currentIndex == 4) {
                                    self.player5.play()
                                } else if(self.currentIndex == 5) {
                                    self.player6.play()
                                } else if(self.currentIndex == 6) {
                                    self.player7.play()
                                } else if(self.currentIndex == 7) {
                                    self.player8.play()
                                } else if(self.currentIndex == 8) {
                                    self.player9.play()
                                } else if(self.currentIndex == 9) {
                                    self.player10.play()
                                }
                             }
            )
        }
    }
    
    func setCenterVideoFrame() {
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            let h:CGFloat = UIScreen.main.bounds.size.height-200
            let w:CGFloat = 4.0*(h/3.0)
            self.questionImageView.frame = CGRect(x: (UIScreen.main.bounds.size.width-w)/2.0, y: 100, width: w, height: h)
        } else {
            let h:CGFloat = UIScreen.main.bounds.size.height-150
            let w:CGFloat = 4.0*(h/3.0)
            self.questionImageView.frame = CGRect(x: (UIScreen.main.bounds.size.width-w)/2.0, y: 75, width: w, height: h)
        }
        print("self.questionImageView.frame = ", self.questionImageView.frame)
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
        print("initializeTimer =================== Yeh print statement dekho dilip")
        AutismTimer.shared.stopTimer()
        print("Atinder implement above line but need to remove above line")

        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    private func moveToNextQuestion() {
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
extension AssessmentMandingVerbalVideoViewController {
    func setVerbalQuestionInfo(info:VerbalQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.verbalQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentMandingVerbalVideoViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
       //*
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob {
                       self.avatarImageView.animatedImage =  getIdleGif()
                   }
               }
        else {
                self.avatarImageView.animatedImage =  getIdleGif()
        }
        //*/
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
        
        //*
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
 //*/
    }
}

//MARK:- RecordingManager Delegate Methods
extension AssessmentMandingVerbalVideoViewController: RecordingManagerDelegate {
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
                self.userAnswer.text = ""

                let answerArray = self.verbalQuestionInfo.image_with_text[currentIndex].name.lowercased().components(separatedBy: ",")
                if answerArray.count > 0 {
                    SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+answerArray[0], uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
                
                
            }
        } else {
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
}

extension AssessmentMandingVerbalVideoViewController: NetworkRetryViewDelegate {
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

extension AssessmentMandingVerbalVideoViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}

