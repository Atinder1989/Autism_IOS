//
//  MandViewController.swift
//  Autism
//
//  Created by Dilip Saket on 02/07/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import SafariServices

class MandViewController: UIViewController {
    
    private weak var delegate: AssessmentSubmitDelegate?
    let mandViewModel:MandViewModel = MandViewModel()

    var algoResponse:AlgorithmResponseVO!
    var mandInfo:MandInfo!
    
    @IBOutlet var submitButton:UIButton!
    @IBOutlet var scrlViewMand:UIScrollView!
    
    var svc: SFSafariViewController!
    var isYoutubeRunning:Bool = false
    
    let viewHeaderYT = UIView()
    let imgViewAvtarYT = UIImageView()
    let btnHomeYT = UIButton()
    let btnSkipYT = UIButton()

    private var webViewTimer: Timer? = nil
    private var webViewTimeTaken = 0

    var imgViewMandSelected:ImageViewWithMand!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        if(mandInfo?.content_type == AssessmentQuestionType.mand.rawValue) {
            self.submitButton.isHidden = true
            self.scrlViewMand.isHidden = false
            self.scrlViewMand.backgroundColor = .clear
            self.screenDesigningMand()
        } else if(self.algoResponse != nil) {
            self.mandInfo = algoResponse.data?.mandInfo

            self.submitButton.isHidden = true
            self.scrlViewMand.isHidden = false
            self.scrlViewMand.backgroundColor = .clear
            self.screenDesigningMand()
        }
        self.listenModelClosures()
    }
    
    func screenDesigningMand() {
        var screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let screenHeight:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.height)

        self.scrlViewMand.frame = CGRect(x: (screenWidth-screenHeight)/2.0, y: 0, width: screenHeight, height: screenHeight)

        screenWidth = screenHeight
        
        var wh:CGFloat = 240
        var xySpace:CGFloat = 20
        
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            wh = 120
        }

        var xRef:CGFloat = (screenWidth-wh-wh-xySpace)/2.0
        var yRef:CGFloat = (screenHeight-wh-wh-xySpace)/2.0
        
        if(self.mandInfo.array_of_objects.count <= 2) {
            xySpace = 50
            yRef = yRef+xySpace
        }
        
        var index:Int = 0
        for mand in self.mandInfo.array_of_objects {
            
            let fm = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            let imgView:ImageViewWithMand = ImageViewWithMand.init(frame: fm)
            imgView.mand = mand
            imgView.isUserInteractionEnabled = true
            imgView.backgroundColor = .clear
            self.scrlViewMand.addSubview(imgView)

            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            imgView.addGestureRecognizer(gestureRecognizer)

            let url = ServiceHelper.baseURL.getMediaBaseUrl()+mand.icon_image
            print("url = ", url)
            
            if(mand.icon_image == "") {
                imgView.image = UIImage.init(named: "MenuIcon")
            } else {
                imgView.setImageWith(urlString: url)
            }
            
            index = index+1
            
            if(index%4 == 1) {
                xRef = xRef+xySpace+wh
            } else if(index%4 == 2) {
                yRef = yRef+xySpace+wh
                xRef = xRef-xySpace-wh
            } else if(index%4 == 3) {
                xRef = xRef+xySpace+wh
            } else if(index%4 == 0) {
                xRef = ((screenWidth-wh-wh-xySpace)/2.0)+(CGFloat((index/4))*screenHeight)
                yRef = (screenHeight-wh-wh-xySpace)/2.0
            }
        }
    }
    
    @IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        self.imgViewMandSelected = (gestureRecognizer.view as? ImageViewWithMand)!
        imgViewMandSelected.alpha = 0.7
        
        if imgViewMandSelected.mand?.mand_type == "youtube" {
            self.showWebView()
        } else {
            self.submitMandResponse()
        }
    }

    func submitMandResponse() {
        
        if(self.algoResponse == nil) {
            self.submitMandQuestionDetails(mandInfo: self.mandInfo, mand: self.imgViewMandSelected.mand!)
        } else {
            self.submitButtonClicked()
        }
    }
    
    private func listenModelClosures() {
       self.mandViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.mandViewModel.accessmentSubmitResponseVO {
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

    func submitMandQuestionDetails(mandInfo:MandInfo, mand:MandObject) {
        self.view.isUserInteractionEnabled = false
        self.mandViewModel.submitMandQuestionDetails(info: mandInfo, mand: mand, timeTaken: 0, successCount: 0)
    }
    
    @IBAction func submitButtonClicked() {
        self.view.isUserInteractionEnabled = false
        self.mandViewModel.submitLearningMandAnswer(response: algoResponse)
    }

    func setResponse(algoResponse:AlgorithmResponseVO) {
        self.algoResponse = algoResponse
    }
    
    //MARK: -
    @objc func hideYoutube()
    {
        self.stopWebViewTimer()
        self.hideWebView()
    }
    
    @objc func btnHomeYTClicked()
    {
        DispatchQueue.main.async {

            self.stopWebViewTimer()
            self.svc.dismiss(animated: false, completion: {
                self.svc = nil
                self.isYoutubeRunning = false
//                SpeechManager.shared.setDelegate(delegate: self)
            })
            UserManager.shared.exitAssessment()
        }
    }
    
    @objc func btnSkipYTClicked()
    {
        DispatchQueue.main.async {

            self.viewHeaderYT.isHidden = true
            self.stopWebViewTimer()
            
                self.svc.dismiss(animated: false, completion: {
                    self.svc = nil
                    self.isYoutubeRunning = false
//                SpeechManager.shared.setDelegate(delegate: self)
                self.perform(#selector(self.callNextQuestion), with: nil, afterDelay: 1.0)
            })
        }
    }
    
    @objc func callNextQuestion()
    {
        self.submitMandResponse()
//        if let question = self.questionResponse {
//            self.moveToNextQuestion(res: question)
//        }
    }
    @objc private func calculateTimeTaken() {
        print("Webview Timer =====")
        self.webViewTimeTaken += 1
        if self.webViewTimeTaken == Int(AppConstant.webviewTimer.rawValue) {
            self.stopWebViewTimer()
            self.hideWebView()
        }
    }
    
    private func stopWebViewTimer() {
        if let timer = self.webViewTimer {
            timer.invalidate()
            self.webViewTimer = nil
            self.webViewTimeTaken = 0
        }
    }
    
    private func showWebView(_ animated:Bool = true) {
    
        if(svc == nil) {
            //svc = SFSafariViewController.init(url: URL(string: "https://www.youtubekids.com/")!)
            svc = SFSafariViewController.init(url: URL(string: "https://www.youtube.com/")!)
            if #available(iOS 13.0, *) {
                svc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
        
            svc.modalPresentationStyle = .fullScreen
        }
        // You can also init the view controller with the SFSafariViewController:url: method
        svc.delegate = self
        if #available(iOS 10.0, *) {
            // The color to tint the background of the navigation bar and the toolbar.
            svc.preferredBarTintColor = .white//readerMode ? .blue : .orange
            // The color to tint the the control buttons on the navigation bar and the toolbar.
            svc.preferredControlTintColor = .white
        } else {
            // Fallback on earlier versions
        }
        
        DispatchQueue.main.async(execute: { [self] in
  
//        })
//        DispatchQueue.main.async {
            
            SpeechManager.shared.setDelegate(delegate: nil)
            self.present(self.svc, animated: false, completion: {
                
                self.isYoutubeRunning = true
                self.viewHeaderYT.isHidden = false
                self.viewHeaderYT.frame = CGRect(x:-1, y:-1, width: UIScreen.main.bounds.size.width+2, height: 54)
                self.viewHeaderYT.backgroundColor = .white
                
                if(self.svc != nil) {
                    self.svc.view.window!.addSubview(self.viewHeaderYT)
                }
            
                self.imgViewAvtarYT.frame = CGRect(x:UIScreen.main.bounds.size.width-180, y:4, width: 50, height: 50)
                self.imgViewAvtarYT.clipsToBounds = true
                self.imgViewAvtarYT.layer.cornerRadius = 20.0
                self.imgViewAvtarYT.backgroundColor = UIColor.init(white: 1.0, alpha: 0.1)
            
                if let user = UserManager.shared.getUserInfo() {
                    self.imgViewAvtarYT.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + user.avatar)
                }
                self.viewHeaderYT.addSubview(self.imgViewAvtarYT)
                        
                self.btnHomeYT.backgroundColor = .clear
                //self.btnHomeYT.setImage(UIImage.init(named: "home"), for: .normal)
                self.btnHomeYT.setImage(UIImage.init(named: "home"), for: .normal)
                self.btnHomeYT.setTitleColor(.black, for: .normal)
                self.btnHomeYT.frame = CGRect(x:UIScreen.main.bounds.size.width-120, y:4, width: 50, height: 50)
                self.btnHomeYT.addTarget(self, action: #selector(self.btnHomeYTClicked), for: .touchDown)
                self.viewHeaderYT.addSubview(self.btnHomeYT)
                        
                self.btnSkipYT.backgroundColor = .clear
                //self.btnSkipYT.setImage(UIImage.init(named: "back"), for: .normal)
                self.btnSkipYT.setImage(UIImage.init(named: "skip"), for: .normal)
                self.btnSkipYT.setTitleColor(.black, for: .normal)
                self.btnSkipYT.frame = CGRect(x:UIScreen.main.bounds.size.width-60, y:4, width: 50, height: 50)// CGRect(x:10, y:4, width: 40, height: 40)
                self.btnSkipYT.addTarget(self, action: #selector(self.btnSkipYTClicked), for: .touchDown)
                self.viewHeaderYT.addSubview(self.btnSkipYT)
            })
//        }
    })
        self.initializeWebViewTimer()
   }
    
    private func initializeWebViewTimer() {
         webViewTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }

    private func hideWebView() {
        
        viewHeaderYT.isHidden = true
        if(svc != nil) {
            svc.dismiss(animated: false, completion: {
                self.svc = nil
                self.isYoutubeRunning = false
//                SpeechManager.shared.setDelegate(delegate: self)
            })
        }
        self.submitMandResponse()
//        if let question = self.questionResponse {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.moveToNextQuestion(res: question)
//            }
//        }
    }
}

extension MandViewController {
    func setMandQuestionInfo(info:MandInfo, delegate:AssessmentSubmitDelegate) {
        self.mandInfo = info
        self.delegate = delegate
    }
}

class ImageViewWithMand : UIImageView {
    var mand : MandObject?
    var commandInfo:ScriptCommandInfo?
}

extension MandViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        //Tells the delegate that the initial URL load completed.
    }
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        //Tells the delegate that the user tapped an Action button.
        return []
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
        self.stopWebViewTimer()
        SpeechManager.shared.speak(message:"", uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        self.submitMandResponse()
//        if let question = self.questionResponse {
//           self.moveToNextQuestion(res: question)
//        }
    }
}
