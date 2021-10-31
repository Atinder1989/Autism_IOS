//
//  LanguageViewController.swift
//  Autism
//
//  Created by IMPUTE on 30/01/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol LanguageViewDelegate {
    func didChangeLanguage()
}

class LanguageViewController: UIViewController {
    @IBOutlet weak var continueTologinButton: UIButton!
    @IBOutlet weak var languageView1: UIView!
    @IBOutlet weak var languageView2: UIView!
    @IBOutlet weak var languageView3: UIView!
    @IBOutlet weak var languageView4: UIView!
    @IBOutlet weak var languageView5: UIView!
    
    @IBOutlet weak var languageView: UIView!

    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var label5: UILabel!
    
    @IBOutlet weak var chooseLanguageLabel: UILabel!
    @IBOutlet weak var selectLanguageLabel: UILabel!

    private var delegate: LanguageViewDelegate?
    private var languageViewModel = LanguageViewModel()
    private var languageList = [LanguageModel]() {
        didSet {
            DispatchQueue.main.async {
                self.setLanguages()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenModelClosures()
        self.customSetting()
        self.languageViewModel.getLanguageList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setDelegate(delegate:LanguageViewDelegate){
        self.delegate = delegate
    }
    
    @IBAction func continueToLoginClicked(_ sender: Any) {
        if selectedLanguageModel.code.count > 0 {
            if let delegate = self.delegate {
                delegate.didChangeLanguage()
                self.dismiss(animated: true, completion:nil)
            } else {
                let vc = Utility.getViewController(ofType: LoginViewController.self)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            Utility.showAlert(title: "Information", message: "Please Select Language")
        }
    }

}

//MARK:- Private Methods
extension LanguageViewController {
    private func customSetting() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        Utility.setView(view: self.continueTologinButton, cornerRadius: 27.5, borderWidth: 0, color: .clear)
        let color = UIColor.init(red: 145/255.0, green: 143/255.0, blue: 249/255.0, alpha: 1)
        Utility.setView(view: self.languageView1, cornerRadius: 13, borderWidth: 2, color: color)
        Utility.setView(view: self.languageView2, cornerRadius: 13, borderWidth: 2, color: color)
        Utility.setView(view: self.languageView3, cornerRadius: 13, borderWidth: 2, color: color)
        Utility.setView(view: self.languageView4, cornerRadius: 13, borderWidth: 2, color: color)
        Utility.setView(view: self.languageView5, cornerRadius: 13, borderWidth: 2, color: color)
        Utility.setView(view: self.imageView1, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.imageView2, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.imageView3, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.imageView4, cornerRadius: 5, borderWidth: 0, color: .clear)
        Utility.setView(view: self.imageView5, cornerRadius: 5, borderWidth: 0, color: .clear)
    }
    
    private func listenModelClosures() {
        self.languageViewModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
        
           languageViewModel.reloadDataClosure = {
               DispatchQueue.main.async {
                    if let response = self.languageViewModel.languageResponseVO {
                        let totalIndices = response.list.count - 1
                        var reversed = [LanguageModel]()
                        for arrayIndex in 0...totalIndices {
                            reversed.append(response.list[totalIndices - arrayIndex])
                        }
                        self.languageList = reversed
                        
                    }
               }
           }
    }
    
    private func setLanguages() {
        if self.languageList.count == 5 {
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.languageList[0].image, imageView: imageView1, callbackAfterNoofImages: self.languageList.count, delegate: self)
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.languageList[1].image, imageView: imageView2, callbackAfterNoofImages: self.languageList.count, delegate: self)
             ImageDownloader.sharedInstance.downloadImage(urlString:  self.languageList[2].image, imageView: imageView3, callbackAfterNoofImages: self.languageList.count, delegate: self)
             ImageDownloader.sharedInstance.downloadImage(urlString:  self.languageList[3].image, imageView: imageView4, callbackAfterNoofImages: self.languageList.count, delegate: self)
             ImageDownloader.sharedInstance.downloadImage(urlString:  self.languageList[4].image, imageView: imageView5, callbackAfterNoofImages: self.languageList.count, delegate: self)
       }
    }
    
    private func setData() {
        self.addTapGesture()
        self.label1.text = self.languageList[0].name
        self.label2.text = self.languageList[1].name
        self.label3.text = self.languageList[2].name
        self.label4.text = self.languageList[3].name
        self.label5.text = self.languageList[4].name
        
        self.languageView.isHidden = false
        self.continueTologinButton.isHidden = false
        //self.selectLanguageLabel.isHidden = false
        self.chooseLanguageLabel.isHidden = false
    }
    
    private func addTapGesture() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.languageView1.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.languageView2.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.languageView3.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.languageView4.addGestureRecognizer(tap4)
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.languageView5.addGestureRecognizer(tap5)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let sd = sender, let vw = sd.view {
            let modelIndex = vw.tag - 1000
            let model = self.languageList[modelIndex]
            if model.status == "Active" {
                selectedLanguageModel = model
                self.resetLanguageList()
                self.showSelectedLanguage(viewTag: vw.tag)
            } else {
                Utility.showAlert(title: "Information", message: "Coming Soon")
            }
        }
    }
    private func resetLanguageList() {
        for mainSW in self.view.subviews {
             if mainSW.tag == 10000 {
                for sw in mainSW.subviews {
                        sw.backgroundColor = .clear
        let borderColor = UIColor.init(red: 145/255.0, green: 143/255.0, blue: 249/255.0, alpha: 1)
        Utility.setView(view: sw, cornerRadius: 13, borderWidth: 2, color: borderColor)
                }
            }
        }
    }
    private func showSelectedLanguage(viewTag:Int) {
        for mainSW in self.view.subviews {
             if mainSW.tag == 10000 {
                for sw in mainSW.subviews {
                    if sw.tag == viewTag {
                        sw.backgroundColor = .white
                        Utility.setView(view: sw, cornerRadius: 13, borderWidth: 0, color: .clear)
                        break
                    }
                }
            }
        }
    }
    
}

extension LanguageViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        self.languageViewModel.getLanguageList()
    }
}

extension LanguageViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setData()
        }
    }
}
