//
//  AssessmentBeginViewController.swift
//  Autism
//
//  Created by Savleen on 16/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AssessmentBeginViewController: UIViewController {
   @IBOutlet weak var usernameLbl: UILabel!
   @IBOutlet weak var welcomeLbl: UILabel!
   @IBOutlet weak var introductoryVideoLbl: UILabel!

   @IBOutlet weak var beginAssessmentBtn: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    private var assessmentBeginViewModel = AssessmentBeginViewModel()
  private  let playerVC = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        self.listenModelClosures()
        self.assessmentBeginViewModel.fetchBeginAssessmentScreenLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
  //  Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)

    }
    
    @IBAction func btnVideoTapped(_ sender: UIButton) {
          playVideo()
    }
    
    @IBAction func beginAssessmentTapped(_ sender: UIButton) {
        self.stopPlayer()
        let vc = Utility.getViewController(ofType: AssessmentStartViewController.self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func playVideo() {
        let string = "https://autism-images.s3.ap-northeast-1.amazonaws.com/uploads/common/other/1596956822756ABATherapy-Basedontheprinciplesoflearning.mp4"
        if let url = URL.init(string: string) {
            let player = AVPlayer.init(url: url)
            playerVC.player = player
            playerVC.modalPresentationStyle = .fullScreen
            present(playerVC, animated: true) {
                self.playerVC.player?.play()
            }
        }
    }
    
    func stopPlayer() {
        if let player = playerVC.player {
               player.pause()
               playerVC.player = nil
        }
    }
    
}

//MARK:- Private Methods
extension AssessmentBeginViewController {
    private func customSetting() {
            self.navigationController?.navigationBar.isHidden = true
        
        Utility.setView(view: self.beginAssessmentBtn, cornerRadius: 5, borderWidth: 0, color: .clear)
    }
    
    private func listenModelClosures() {
        self.assessmentBeginViewModel.labelsClosure = {
                DispatchQueue.main.async {
                        if let response = self.assessmentBeginViewModel.labelsResponseVO {
                            self.setLabels(labelresponse: response)
                        }
                }
        }
    }
    
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        if let user = UserManager.shared.getUserInfo() {
            self.usernameLbl.text = labelresponse.getLiteralof(code: AssessmentBeginLabelCode.hello.rawValue).label_text + " " + Utility.deCrypt(text: user.nickname)
            self.avatarImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl()+user.avatar)
        }
        self.beginAssessmentBtn.setTitle(labelresponse.getLiteralof(code: AssessmentBeginLabelCode.begin_Assessment.rawValue).label_text, for: .normal)
        self.introductoryVideoLbl.text = labelresponse.getLiteralof(code: AssessmentBeginLabelCode.introductory_Video.rawValue).label_text
        self.welcomeLbl.text = labelresponse.getLiteralof(code: AssessmentBeginLabelCode.welcome_Autism.rawValue).label_text

    }
}

extension AssessmentBeginViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}

