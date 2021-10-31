//
//  CustomWebView.swift
//  Autism
//
//  Created by Savleen on 11/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import WebKit

protocol CustomWebViewDelegate:NSObject {
    func didClickOnArrow()
    func didClickOnHome()

}

class CustomWebView: UIView, WKNavigationDelegate {
    
    var delegate: CustomWebViewDelegate?

    var webView = WKWebView()
    
    let viewHeader:UIView = UIView()

    override func awakeFromNib() {
           super.awakeFromNib()
        
        //OLD CODE
        let webViewConfiguration = WKWebViewConfiguration()
       // webViewConfiguration.allowsInlineMediaPlayback = false
        var frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        if(UIScreen.main.bounds.height > UIScreen.main.bounds.width) {
            frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        }

        
        webView = WKWebView(frame: frame, configuration: webViewConfiguration)
           webView.backgroundColor = .clear
           webView.navigationDelegate = self
           webView.addObserver(self, forKeyPath: "URL", options: [.new,.old], context: nil)
           self.loadWebPage()
           self.addSubview(webView)
        
        self.insertCSSString(into: webView)
          
        viewHeader.frame = CGRect(x:self.webView.frame.size.width-160, y:0, width:160, height: 57)
        viewHeader.backgroundColor = .white
        webView.addSubview(viewHeader)
        
        let imgViewAvtar = UIImageView()
        imgViewAvtar.frame = CGRect(x:100, y:10, width: 40, height: 40)
        imgViewAvtar.clipsToBounds = true
        imgViewAvtar.layer.cornerRadius = 20.0
        imgViewAvtar.backgroundColor = UIColor.init(white: 1.0, alpha: 0.1)
        if let user = UserManager.shared.getUserInfo() {
            imgViewAvtar.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + user.avatar)
        }
        viewHeader.addSubview(imgViewAvtar)
        
        let btnHome = UIButton()
        btnHome.backgroundColor = .clear
        btnHome.setImage(UIImage.init(named: "home"), for: .normal)
        btnHome.setTitleColor(.black, for: .normal)
        btnHome.frame = CGRect(x:10, y:10, width: 40, height: 40)
        btnHome.addTarget(self, action: #selector(btnHomeClicked), for: .touchDown)
        viewHeader.addSubview(btnHome)
        
        let btnCross = UIButton()
        btnCross.backgroundColor = .clear
        btnCross.setImage(UIImage.init(named: "skip"), for: .normal)
        btnCross.setTitleColor(.black, for: .normal)
        btnCross.frame = CGRect(x:50, y:10, width: 40, height: 40)
        btnCross.addTarget(self, action: #selector(btnCrossClicked), for: .touchDown)
        viewHeader.addSubview(btnCross)
        viewHeader.isHidden = true        
    }
        

    @objc func btnHomeClicked()
    {
        if let del = self.delegate {
            del.didClickOnHome()
        }
    }
    
    @objc func btnCrossClicked()
    {
        if let del = self.delegate {
            del.didClickOnArrow()
        }
     }

    func loadWebPage() {
        //WKWebView.clean()

        if let lastopenurl = UserDefaults.standard.string(forKey: "WebviewLastOpenedSessionUrl") {
            if let url = URL.init(string: lastopenurl) {
                          webView.load(URLRequest(url: url,
                                                         cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60.0))
                
            }
            
        } else {
            
            if let url = URL.init(string: "https://www.youtube.com/") {
                          webView.load(URLRequest(url: url,
                                                         cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60.0))
                
            }
            
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
          if let url:NSURL = change?[.newKey] as? NSURL {
              if !url.relativeString.contains("about:blank") {
                  UserDefaults.standard.set(url.relativeString, forKey: "WebviewLastOpenedSessionUrl")
              }
          }
      }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("error 1 = ", error)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        let strURL = webView.url?.absoluteString ?? ""
         print("strURL= ", strURL)
        if strURL.contains("youtube.com") {
//            UserDefaults.standard.set(strURL, forKey: "youtubeURL")
          decisionHandler(.allow) //<------------------ this part
        } else {
            decisionHandler(.cancel) //<------------------ this part
            webView.load(URLRequest.init(url: URL.init(string: "https://www.youtube.com/")!))
//            decisionHandler(.allow)
//            let sul:String = UserDefaults.standard.object(forKey: "youtubeURL") as? String ?? ""
//
//            if(sul != "") {
//                print("ul = ", sul)
//
//                webView.load(URLRequest.init(url: URL.init(string: sul)!))
//            } else {
//                webView.load(URLRequest.init(url: URL.init(string: "https://www.youtube.com/")!))
//            }
        }
    }
    
      func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      }
      
      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.viewHeader.isHidden = false
        Utility.hideLoader()
      }
    
      func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        print("error 2 = ", error)
        Utility.hideLoader()
      }
    
    func insertCSSString(into webView: WKWebView) {
    let jsString = "document.querySelectorAll('*[style]').forEach(el => el.style.overflow = 'scroll');"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
}


extension WKWebView {
    class func clean() {
        guard #available(iOS 9.0, *) else {return}

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
        }
    }
}
