//
//  Utility.swift
//  HealthApp
//
//  Created by IMPUTE on 26/11/19.
//  Copyright © 2019 IMPUTE. All rights reserved.
//

import UIKit
import MBProgressHUD
import SystemConfiguration
import ReachabilitySwift
import ARKit
import AVFoundation

class Log {
    static  func DLog(message: AnyObject, function: String = #function) {
        #if DEBUG
        print("\(function): \(message)")
        #endif
    }
}

class Utility {

    static let sharedInstance = Utility()
    static private var activityIndicator: MBProgressHUD?
    private var toastLabel: UILabel?
    private static let cryptLib = CryptLib()
    var countriesDictionary:[String:[String]] = [:]

    var reachability: Reachability!
    private init() {}
    
    
    // MARK: - Loader Methods
    static func showLoader() {
        DispatchQueue.main.async {
            if activityIndicator == nil {
                if let window = AppDelegate.shared?.window {
                    activityIndicator = MBProgressHUD.showAdded(to: window, animated: true)
                    activityIndicator?.label.text = "Loading..."
                }
            } else {
                hideLoader()
                showLoader()
            }
        }
    }
   
    static func hideLoader() {
        DispatchQueue.main.async {
            if let indicator = self.activityIndicator {
                indicator.hide(animated: true)
                activityIndicator = nil
            }
        }
    }
     
    static func getSize(_ text: String, font: UIFont, boundingSize:CGSize) -> CGSize {
        //let size = CGSize(width: 348, height: 20000.0)
        let attributedText = NSAttributedString(string: text.removingPercentEncoding ?? "",
                                                attributes: [NSAttributedString.Key.font: font])
        let rect: CGRect = attributedText.boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, context: nil)
        return rect.size
    }

    // MARK: - Show Alert
    static func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            if let topController = UIApplication.topViewController() {
                if topController is UIAlertController {
                } else {
                    let alert = UIAlertController(title: title, message: message,
                                                  preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    topController.present(alert, animated: true, completion: nil)
                }
             }
        }
    }

    // MARK: - Network Methods
    static func isNetworkAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func startNetworkNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification, object: reachability)
        reachability = Reachability.init()
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    @objc func reachabilityChanged(note: Notification) {
        DispatchQueue.main.async {
        let rrr = note.object as? Reachability
        if (rrr?.isReachable == true) {
            // Utility.sharedInstance.showToast(message:"Network Available")
            print("Network Available")
         } else {
            print("Network Not Available")
            if let topvc = UIApplication.topViewController() {
                if let delegate = topvc as? NetworkRetryViewDelegate {
                    Utility.showRetryView(delegate:delegate)
                    //Utility.showRetryView(delegate: topvc as! NetworkRetryViewDelegate)
                    topvc.view.isUserInteractionEnabled = true
                    SpeechManager.shared.setDelegate(delegate: nil)
                    RecordingManager.shared.stopRecording()
                    RecordingManager.shared.stopWaitUserAnswerTimer()
                }
               
            }
        }
        }
    }
    
    func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }
    
    // MARK: - Set View CornerRadius,BorderWidth,Color
    class func setView(view : UIView, cornerRadius: CGFloat, borderWidth : CGFloat, color : UIColor)
        {
            view.layer.cornerRadius = cornerRadius
            view.layer.borderWidth = borderWidth
            view.layer.borderColor = color.cgColor
            view.layer.masksToBounds = true
        }
  
    // MARK: - Get ViewController From Storyboard
    static func getViewController<T:UIViewController>(ofType viewController:T.Type) -> T
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: type(of: T()))) as! T
    }
    
    static func getView<T: UIView>(of view: T.Type) -> T {
         if let nib = Bundle.main.loadNibNamed(view.identifier, owner: nil, options: nil)?.first as? T {
             return nib
         }
         return T()
    }
     
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        if orientation.contains([.landscapeRight,.landscapeLeft]) {
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
            else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            }
            else if UIDevice.current.orientation == UIDeviceOrientation.portrait {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            }
        } else if orientation.contains([.portrait])  {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
       // UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    static func textSize(text: String, font: UIFont?) -> CGSize {
       // let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
       // return text.size(withAttributes: attributes as [NSAttributedString.Key : Any])
        
        let fontAttributes = [NSAttributedString.Key.font: font]
          //let myText = "Your Text Here"
         return text.size(withAttributes: fontAttributes)
    }
    
    // MARK: - Show Toast
       func showToast(message: String) {
           DispatchQueue.main.async {
               if self.toastLabel != nil {
                   NSObject.cancelPreviousPerformRequests(withTarget: self,
                                   selector: #selector(self.addToastLabel(message:)), object: nil)
                   self.toastLabel = nil
               }
               self.addToastLabel(message: message)
           }
       }

       @objc private func addToastLabel(message: String) {
           let font = UIFont(name: AppFont.helveticaNeue.rawValue, size: 12.0)
            let size: CGSize = Utility.textSize(text: message, font: font)
           self.toastLabel =
               UILabel(frame: CGRect(x: UIScreen.main.bounds.width/2 - size.width/2,
                                     y: UIScreen.main.bounds.height-150, width: size.width + 10, height: 35))
        if let tLabel = self.toastLabel {
        
            tLabel.backgroundColor = UIColor.black
            tLabel.textColor = UIColor.white
            tLabel.textAlignment = .center
            tLabel.font = font
            tLabel.text = message
            tLabel.alpha = 1.0
            tLabel.layer.cornerRadius = 10
            tLabel.numberOfLines = 0
            tLabel.clipsToBounds  =  true
            if let shared = AppDelegate.shared, let window = shared.window {
                window.addSubview(tLabel)
            }
           UIView.animate(withDuration: 3.0, delay: 0.0, options: .curveEaseOut, animations: {
            tLabel.alpha = 0.0
           }, completion: {_ in
            tLabel.removeFromSuperview()
               self.toastLabel = nil
           })
        
        }
       }
    // MARK: - Encryption/ Decryption Methods
    
    static func encrypt(text:String) -> String  {
        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: text, key: AppConstant.appicationEncryptDecryptKey.rawValue)
        return cipherText!
    }
    
    static func deCrypt(text:String) -> String {
        let decryptedString = cryptLib.decryptCipherTextRandomIV(withCipherText: text, key: AppConstant.appicationEncryptDecryptKey.rawValue)
        return decryptedString ?? ""
    }

    static func convertDateToString(date:Date,format:String) -> String {
         let df = DateFormatter()
         df.dateFormat = format
        return df.string(from:date)
    }
    
    static func convertStringToDate(strDate:String,format:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: strDate)
    }
    
    static func getLanguageCode() -> String {
        if let user = UserManager.shared.getUserInfo() {
            if let type = AppLanguage.init(rawValue: user.languageCode) {
                return type.getLanguageCode()
            }
        }
        return ""
    }
    
    static func getSpeechIdentifierForEnglishUser() -> String {
        if let user = UserManager.shared.getUserInfo() {
            if let type = AppLanguage.init(rawValue: user.languageCode),let gender = AvatarGender.init(rawValue: user.avatar_gender) {
                return type.getEnglishSpeechIdentifier(gender: gender)
            }
        }
        return ""
    }
    
    static func getVoiceTypeForJapaneseUser() -> String {
        if let user = UserManager.shared.getUserInfo() {
            if let type = AppLanguage.init(rawValue: user.languageCode),let gender = AvatarGender.init(rawValue: user.avatar_gender) {
                return type.getJapaneseSpeechIdentifier(gender: gender)
            }
        }
        return ""
    }
    

     func uploadImage(image: UIImage,responseProcessingBlock: @escaping (String,Error?) -> () ) {
        let paramName = "image"
        let fileName = "drawing.png"
        
        let url = URL(string: ServiceHelper.getUploadImageUrl())

        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        let session = URLSession.shared

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    print(json["item"] as! String)
                    let url = json["item"] as! String
                    print(url)
                  responseProcessingBlock(url,error)
                }
            }  else {
                responseProcessingBlock("",error)
            }
            
            
        }).resume()
    }
    
   static func getSpeechMessageType(text:String) -> SpeechMessage? {
           if let user = UserManager.shared.getUserInfo() {
               if user.languageCode == AppLanguage.en.rawValue {
                   if text == SpeechEnglishMessage.moveForward.rawValue {
                       return .moveForward
                   } else if text == SpeechEnglishMessage.hurrayGoodJob.rawValue {
                       return .hurrayGoodJob
                   } else if text == SpeechEnglishMessage.wrongAnswer.rawValue {
                       return .wrongAnswer
                   } else if text == SpeechEnglishMessage.keepTrying.rawValue {
                       return .keepTrying
                   } else if text == SpeechEnglishMessage.excellentWork.rawValue {
                       return .excellentWork
                   } else if text == SpeechEnglishMessage.greatToKnowYou.rawValue {
                       return .greatToKnowYou
                   }
               } else if user.languageCode == AppLanguage.ja.rawValue {
                   if text == SpeechJapaneseMessage.moveForward.rawValue {
                       return .moveForward
                   } else if text == SpeechJapaneseMessage.hurrayGoodJob.rawValue {
                       return .hurrayGoodJob
                   } else if text == SpeechJapaneseMessage.wrongAnswer.rawValue {
                       return .wrongAnswer
                   } else if text == SpeechJapaneseMessage.keepTrying.rawValue {
                       return .keepTrying
                   } else if text == SpeechJapaneseMessage.excellentWork.rawValue {
                       return .excellentWork
                   } else if text == SpeechJapaneseMessage.greatToKnowYou.rawValue {
                       return .greatToKnowYou
                   }
               }
           }
           return nil
       }
    
    func isARFaceTrackingConfigurationOnCurrentDevice () -> Bool {
           return ARFaceTrackingConfiguration.isSupported
    }
    
    
    func isAnswerMatched(text:String,answer:String) ->Bool {
        let answerArray = answer.lowercased().components(separatedBy: ",")
        let textArray:[String] = text.lowercased().components(separatedBy: " ")
        var newAnswerArray = [String]()
        for string in answerArray {
            let arr = string.lowercased().components(separatedBy: " ")
            for newString in arr {
                newAnswerArray.append(newString)
            }
        }
        print(newAnswerArray)
        var isExist = false
        for value in textArray {
            for item in newAnswerArray {
                if value == item {
                    isExist = true
                    break
                }
            }
            if isExist {
                break
            }
         }
         return isExist
      }
    
    
    private static func createRetryView(delegate: NetworkRetryViewDelegate) -> UIView {
        let retryView = self.getView(of: NetworkRetryView.self)
         let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width,
         height: UIScreen.main.bounds.height)
           retryView.frame = frame
           retryView.setDelegate(delegate: delegate)
           return retryView
       }
    
       static func showRetryView(delegate: NetworkRetryViewDelegate) {
         DispatchQueue.main.async {
           if let topVC = UIApplication.topViewController() {
               let rViews = topVC.view.allSubViewsOf(type: NetworkRetryView.self)
                   if rViews.count == 0 {
                    topVC.view.addSubview(self.createRetryView(delegate: delegate))
                   }
               }
           }
       }
       static func hideRetryView() {
           DispatchQueue.main.async {
           if let topVC = UIApplication.topViewController() {
               let rViews = topVC.view.allSubViewsOf(type: NetworkRetryView.self)
               if rViews.count > 0 {
                   rViews[0].removeFromSuperview()
                   }
               }
           }
       }
    
    static func getThumbnailImage(urlString:String,time:CMTime) -> UIImage? {
        if let sourceURL = URL(string: urlString) {
        let asset = AVAsset(url: sourceURL)
           print(asset)
           let assetImageGenerator = AVAssetImageGenerator(asset: asset)
           assetImageGenerator.appliesPreferredTrackTransform = true // Testing to see if image is tilted or not
//           var time = asset.duration
//           time.value = min(time.value, 2)
           do {
               let imageRef = try assetImageGenerator.copyCGImage(at: time , actualTime: nil)
                print("Thumbnail Image === ")
                print(imageRef)
               return UIImage(cgImage: imageRef)
           } catch  let error {
               print("*** Error generating thumbnail: \(error.localizedDescription)")
               return nil
           }
        }
        return nil
    }
    
    static func getWish() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12 : return WishType.goodMorning.getWish()
        case 12 :  return WishType.goodNoon.getWish()
        case 13..<17 : return WishType.goodAfterNoon.getWish()
        case 17..<22 : return WishType.goodEvening.getWish()
        default: return WishType.goodNight.getWish()
        }
    }
    
    static func getDateDifferenceInSeconds(startDate:Date,endDate:Date) -> Int {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([ .second])
        let datecomponents = calendar.dateComponents(unitFlags, from: startDate, to: endDate)
        let seconds = datecomponents.second
        if let s = seconds {
            return s
        }
        return 0
    }
    
    static func getAssessmentProgressColor(score:Float) -> UIColor {
        var color = UIColor.clear
            if score < 50 // Red
            {
                color = UIColor.init(red: 255/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1)
            } else if score >= 50 && score <= 60 // Yellow
            {
                color = UIColor.init(red: 255/255.0, green: 177/255.0, blue: 29/255.0, alpha: 1)
            } else {
                color = UIColor.init(red: 82/255.0, green: 232/255.0, blue: 140/255.0, alpha: 1)
            }
        return color
    }
    
    func loadCountriesList() {
        do {
        let path = Bundle.main.path(forResource: "world-cities", ofType: "txt") 
        let text = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let lineArray = text.components(separatedBy: "\n") // Separating Lines
            for eachLA in lineArray
            {
                let wordArray = eachLA.components(separatedBy: ",")
                for (index, element) in wordArray.enumerated() {
                    if index == 1 {
                        if countriesDictionary[element] == nil  {
                            countriesDictionary[element] = []
                        }
                    } else if index == 2 {
                        if let value:[String] = countriesDictionary[wordArray[1]] {
                            var array:[String] = [element]
                            array.append(contentsOf: value)
                            countriesDictionary[wordArray[1]] = array.uniqued()
                        } else {
                        }
                    }
                }
            }
            
            print(countriesDictionary)

        } catch {
        }
    }
    
    
}

