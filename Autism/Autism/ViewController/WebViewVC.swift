//
//  WebViewVC.swift
//  Autism
//
//  Created by mac on 24/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import WebKit

protocol WebviewDelegate:NSObject {
    func webviewdismiss(response:AssessmentQuestionResponseVO!)
}
class WebViewVC: UIViewController,WKNavigationDelegate {
    
     private var webView = WKWebView()
  //  private let webView = WKWebView(frame: .zero)
     private var timeTakenToSolve = 0
     private var webCompletionTimer: Timer? = nil
     private weak var delegate: WebviewDelegate?
     private var res: AssessmentQuestionResponseVO!
     private var link = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
    }
    
    func setwebviewwith(link:String,delegate:WebviewDelegate,response:AssessmentQuestionResponseVO){
        self.link = link
        self.delegate = delegate
        self.res = response
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.webView.loadHTMLString("", baseURL: nil)
    }


}
extension WebViewVC {
private func customSetting() {
    Utility.showLoader()
    webView.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    webView.backgroundColor = .clear
    webView.navigationDelegate = self
    webView.addObserver(self, forKeyPath: "URL", options: [.new,.old], context: nil)
    self.view.addSubview(webView)
    let url = URL(string: link)!
    webView.load(URLRequest(url: url,
                                   cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
           timeoutInterval: 10.0))
    self.initializeTimer()
}
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("New Url is  =====")
        print(change?[.newKey])
        if let url:NSURL = change?[.newKey] as! NSURL {
            if !url.relativeString.contains("about:blank") {
                UserDefaults.standard.set(url.relativeString, forKey: "WebviewLastOpenedSessionUrl")
            }
        }
    }
    
  
    
   
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Utility.hideLoader()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Utility.hideLoader()
    }
    

}
extension WebViewVC {
        private func initializeTimer() {
             webCompletionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
         }
        @objc private func calculateTimeTaken() {
            print("web view timer")
            self.timeTakenToSolve += 1
            print(timeTakenToSolve)
            if self.timeTakenToSolve == Int(AppConstant.webviewTimer.rawValue) {
                self.stopTimer()
            }
}
    
private func stopTimer() {
    webCompletionTimer?.invalidate()
    
    if let del = self.delegate {
        del.webviewdismiss(response:self.res)
    }
    //self.navigationController?.popViewController(animated: true)
}
    
}
