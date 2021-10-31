//
//  AssessmentIntroVideoViewController.swift
//  Autism
//
//  Created by Savleen on 14/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import AVFoundation

class AssessmentIntroVideoViewController: UIViewController {
    private weak var delegate: AssessmentSubmitDelegate?
    private var introVideoQuestionInfo: IntroVideoQuestionInfo!
    private let introVideoViewModel = AssessmentIntroVideoViewModel()

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var bufferLoaderView: UIView!
    @IBOutlet weak var homebutton: UIButton!
    @IBOutlet weak var skipButton: UIButton!

    private var bufferLoaderTimer: Timer?
    private var skipQuestion = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        listenModelClosures()
        self.addPlayer()
        self.view.bringSubviewToFront(self.homebutton)
        self.view.bringSubviewToFront(self.skipButton)
        self.view.bringSubviewToFront(self.bufferLoaderView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
              super.viewWillAppear(animated)
              Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
          
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.introVideoViewModel.stopVideo()
        self.hideBufferLoader()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.introVideoViewModel.pausePlayer()
           SpeechManager.shared.setDelegate(delegate: nil)
           UserManager.shared.exitAssessment()
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
         self.skipQuestion = true
            self.moveToNextQuestion(message: SpeechMessage.moveForward.getMessage())
        }
    }
}

// MARK: Public Methods
extension AssessmentIntroVideoViewController {
    func setIntroVideoInfo(info:IntroVideoQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.introVideoQuestionInfo = info
        self.delegate = delegate
    }
}

extension AssessmentIntroVideoViewController {
    private func customSetting() {
        SpeechManager.shared.setDelegate(delegate: self)
        Utility.setView(view: self.playerView, cornerRadius: 15, borderWidth: 0, color: .clear)
    }
    
    private func listenModelClosures() {
       self.introVideoViewModel.dataClosure = { [weak self] in
          DispatchQueue.main.async {
            if let this = self {
                if let res = this.introVideoViewModel.accessmentSubmitResponseVO {
                        if res.success {
                            this.dismiss(animated: true) {
                                if let del = this.delegate {
                                    del.submitQuestionResponse(response: res)
                               }
                           }
                    }
                }
            }
          }
      }
        
        self.introVideoViewModel.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.moveToNextQuestion(message: "")
                }
            }
        }
        
        self.introVideoViewModel.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.introVideoViewModel.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
    }
    
    private func showBufferLoader() {
        self.bufferLoaderView.isHidden = false
        if let timer = self.bufferLoaderTimer {
            timer.invalidate()
        }
        self.bufferLoaderTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.2),
                        target: self,
                        selector: #selector(self.startBufferLoaderAnimation),
                        userInfo: nil, repeats: true)
    }

    @objc private func startBufferLoaderAnimation () {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {() -> Void in
                self.bufferLoaderView.transform = self.bufferLoaderView.transform.rotated(by: CGFloat(Double.pi))
            }, completion: {(_ finished: Bool) -> Void in
            })
        }
    }

    private func hideBufferLoader() {
        if let timer = self.bufferLoaderTimer {
            self.bufferLoaderView.isHidden = true
            timer.invalidate()
            self.bufferLoaderTimer = nil
        }
    }
    
    private func moveToNextQuestion(message:String) {
       self.introVideoViewModel.pausePlayer()
       SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    
    private func addPlayer() {
    
        if let playerController = introVideoViewModel.playerController {
            if let avplayerController = playerController.avPlayerController {
                self.addChild(avplayerController)
                self.view.addSubview(avplayerController.view)
                avplayerController.view.frame = self.view.frame
                self.playVideo()
            }
        }
        
    }
    
    private func playVideo() {
        let string = ServiceHelper.baseURL.getMediaBaseUrl()+introVideoQuestionInfo.video_url
        let item = VideoItem.init(url: string)
        introVideoViewModel.playVideo(item: item)
    }
    

    
}
extension AssessmentIntroVideoViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

// MARK: Speech Manager Delegate Methods
extension AssessmentIntroVideoViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        SpeechManager.shared.setDelegate(delegate: nil)
        self.introVideoViewModel.submitUserAnswer(info: self.introVideoQuestionInfo, skip: self.skipQuestion)
    }
    func speechDidStart(speechText:String) {
       
    }
}
