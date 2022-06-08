//
//  AvatarSelectionViewController.swift
//  Autism
//
//  Created by Savleen on 29/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit



class AvatarSelectionViewController: UIViewController {
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var visualAvatarLabel: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
//    @IBOutlet weak var imageView3: UIImageView!
//    @IBOutlet weak var imageView4: UIImageView!
//    @IBOutlet weak var imageView5: UIImageView!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
//    @IBOutlet weak var view3: UIView!
//    @IBOutlet weak var view4: UIView!
//    @IBOutlet weak var view5: UIView!

    private var assessmentSelectionModel = AvatarSelectionViewModel()
    private var selectedAvatarModel:ImageModel? = nil
    private var avatarlist:[ImageModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.setImageView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.customSetting()
        self.listenModelClosures()
        self.assessmentSelectionModel.fetchSelectAvatarScreenLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
          //   Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }
    
    @IBAction func continuetClicked(_ sender: Any) {
        if let model = self.selectedAvatarModel {
            self.assessmentSelectionModel.setAvatarForCurrentUser(model: model)
        } else {
            if let labelRes = self.assessmentSelectionModel.labelsResponseVO {
                Utility.showAlert(title: labelRes.getLiteralof(code: AvatarSelectionLabelCode.information.rawValue).label_text, message: labelRes.getLiteralof(code: AvatarSelectionLabelCode.select_Avatar.rawValue).label_text)
            }
        }
    }
}




//MARK:- Private Methods
extension AvatarSelectionViewController {
      private func customSetting() {
          self.navigationController?.navigationBar.isHidden = true
          Utility.setView(view: self.continueBtn, cornerRadius: Utility.isRunningOnIpad() ? 30 : 20, borderWidth: 0, color: .clear)
      }
    
    private func setImageView() {
        if self.avatarlist.count == 5 {
            let baseurl = ServiceHelper.baseURL.getMediaBaseUrl()
            self.imageView1.setImageWith(urlString: baseurl + self.avatarlist[0].image)
            self.imageView2.setImageWith(urlString: baseurl + self.avatarlist[1].image)
//            self.imageView3.setImageWith(urlString: baseurl + self.avatarlist[2].image)
//            self.imageView4.setImageWith(urlString: baseurl + self.avatarlist[3].image)
//            self.imageView5.setImageWith(urlString: baseurl + self.avatarlist[4].image)
            
            self.addTapGesture()
        }
        
        
    }
    
    private func addTapGesture() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view1.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view2.addGestureRecognizer(tap2)
        
//        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.view3.addGestureRecognizer(tap3)
//
//        let tap4 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.view4.addGestureRecognizer(tap4)
//
//        let tap5 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.view5.addGestureRecognizer(tap5)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let sd = sender, let vw = sd.view {
            let modelIndex = vw.tag - 10000
            selectedAvatarModel = avatarlist[modelIndex]
            self.hideGreentickImageforAll()
            self.showGreenTickImage(viewTag: vw.tag)
        }
    }
    
    private func hideGreentickImageforAll() {
         for mainSW in self.view.subviews {
                       if mainSW.tag == 15000 {
                           for sw in mainSW.subviews {
                               for subVW in sw.subviews {
                                      for imgView in subVW.subviews {
                                          if imgView.tag == 1000 {
                                              if let tickImageView = imgView as? UIImageView {
                                                      tickImageView.isHidden = true
                                              }
                                              break
                                          }
                                      }
                              }
                           }
                       }
                   }
    }
    
    private func showGreenTickImage(viewTag:Int) {
        for mainSW in self.view.subviews {
             if mainSW.tag == 15000 {
                for sw in mainSW.subviews {
                         for subVW in sw.subviews {
                            if subVW.tag == viewTag {
                                for imgView in subVW.subviews {
                                    if imgView.tag == 1000 {
                                        if let tickImageView = imgView as? UIImageView {
                                                tickImageView.isHidden = false
                                        }
                                        break
                                    }
                                }

                            }
                        }
                }
            }
        }
    }
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        //self.continueBtn.setTitle(labelresponse.getLiteralof(code: AvatarSelectionLabelCode.Continue.rawValue).label_text, for: .normal)
        self.screenTitleLabel.text = labelresponse.getLiteralof(code: AvatarSelectionLabelCode.choose_Avatar.rawValue).label_text
        self.visualAvatarLabel.text = labelresponse.getLiteralof(code: AvatarSelectionLabelCode.visual_Avatar.rawValue).label_text
    }
    
    func setData()
    {
        continueBtn.isHidden = false
    }
    
     private func listenModelClosures() {
        
        self.assessmentSelectionModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
          self.assessmentSelectionModel.dataClosure = {
            DispatchQueue.main.async {
                if let res = self.assessmentSelectionModel.avatarListResponseVO {
                    self.avatarlist = res.list
                }
            
                if let labelResponse = self.assessmentSelectionModel.labelsResponseVO {
                    self.setLabels(labelresponse: labelResponse)
                    self.setData()
                }
            }
          }
        
         self.assessmentSelectionModel.setAvatarClosure = { (response) in
            DispatchQueue.main.async {
                if let res = response {
                    if res.success {
                        let vc = Utility.getViewController(ofType: AssessmentBeginViewController.self)
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        if let labelresponse = self.assessmentSelectionModel.labelsResponseVO {
                            Utility.showAlert(title: labelresponse.getLiteralof(code: AvatarSelectionLabelCode.information.rawValue).label_text, message: res.message)
                        }
                    }
                }
            }
        }
    }
}

extension AvatarSelectionViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        self.assessmentSelectionModel.fetchSelectAvatarScreenLabels()
    }
}

extension AvatarSelectionViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setData()
        }
    }
}

