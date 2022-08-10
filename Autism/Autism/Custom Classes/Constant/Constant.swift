//
//  Constant.swift
//  Autism
//
//  Created by IMPUTE on 21/09/19.
//  Copyright © 2019 IMPUTE. All rights reserved.
//

import Foundation
import UIKit
import FLAnimatedImage
// facebook Account Credential
// impute.info@gmail.com
// impute3301

// Gmail Account Credential
//  support@fluent8.com
//  Tokyo##2022

// com.impute.Autism

//Youtube Quote
//https://stackoverflow.com/questions/47408723/youtube-quotas-exceeded

var safeArealLeft:CGFloat = 0
var safeArealRight:CGFloat = 0
var safeArealTop:CGFloat = 0
var safeAreaBottom:CGFloat = 0


enum AppConstant:String {
    case gmailClientID = "611305546671-4c9j5kh6gsag53qj1qkn38qpfmtcl66i.apps.googleusercontent.com"
    case appicationEncryptDecryptKey = "Aq3t6w9y$C&E)H@LcQfTjNnZr4u7x!A%"
    case passwordLength = "8"
    case webviewTimer = "120"
    case speakUtteranceNormalRate = "0.4"
    case postUtteranceDelay = "0.06"
    case screenloadQuestionSpeakTimeDelay = "2"
    case youtubeApiKey = "AIzaSyA0XL2RiwSwXOYL1m8NeNH5CNxV8_Kchxg"//
//    case youtubeApiKey = "AIzaSyBCjT-OJQSKCV4FWTnCz5EY3LhydUx4ujk"//My
    case analyticsKey = "c4a17b4a-24d3-43cc-b7a0-dada8a44c0a3"
    case minCharacterLimit = "3"
    case maxCharacterLimitForNickname = "10"
    case maxCharacterLimitForGuardianName = "40"
    case faceNotDetectTimer = "15"
}

let noseOptions = ["👃", "🐽", "💧", " "]
let eyeOptions = ["👁", "🌕", "🌟", "🔥", "⚽️", "🔎", " "]
let mouthOptions = ["👄", "👅", "❤️", " "]
let hatOptions = ["🎓", "🎩", "🧢", "⛑", "👒", " "]
let features = [FaceTrackQuestionTypeTag.nose.getName(), FaceTrackQuestionTypeTag.leftEye.getName(), FaceTrackQuestionTypeTag.rightEye.getName(), FaceTrackQuestionTypeTag.mouth.getName(), FaceTrackQuestionTypeTag.hat.getName()]
let featureIndices = [[9], [1064], [42], [24, 25], [20]]


var screenLoadTime: Date? = nil
var dateFormat = "yyyy-MM-dd HH:mm:ss"
let learningCommandDelayTime:Int = 2
let learningAnimationDuration:TimeInterval = 3
//let questionRepeatAfterTime:Int = 10
let userProfileReinforcerLimit:Int = 2

var keyExcellent = "Excellent"
var keyHurray = "hurray"
var keyIdle = "Idle"
var keyTalking = "talking"
var keyWrongAnswer = "WrongAnswer"
var keyRaiseHand = "raisehand"//"raise_hand"
var keyTouchNose = "touchnose"
var keyClapping = "claphand"
var keyOpenMouth = "mouthopen"
var keyBigAvatarTalking = "avtar_talking"

var isSkipLearningHidden = true

var trailPromptTimeForUser = 0

var selectedLanguageModel = LanguageModel.init(name: "", code: "", image: "", status: "")


func getIdleGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyIdle) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyIdle) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyIdle)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}


func getHurrayGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyHurray) as? Data
    if(imageData == nil) {

        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyHurray) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyHurray)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getTalkingGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyTalking) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyTalking) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyTalking)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getWrongAnswerGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyWrongAnswer) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyWrongAnswer) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyWrongAnswer)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getExcellentGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyExcellent) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyExcellent) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyExcellent)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getClappingGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyClapping) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyClapping) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyClapping)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getRaiseHandGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyRaiseHand) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyRaiseHand) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyRaiseHand)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getOpenMouthGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyOpenMouth) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyOpenMouth) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyOpenMouth)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getTouchNoseGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyTouchNose) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyTouchNose) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyTouchNose)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}

func getBigAvatarTalkingGif() -> FLAnimatedImage? {
    var imageData:Data? = UserDefaults.standard.object(forKey: keyBigAvatarTalking) as? Data
    if(imageData == nil) {
        
        if let model = DatabaseManager.sharedInstance.getAvatarVariationOfType(variationType: keyBigAvatarTalking) {
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
        let urlString:String! = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString)!
        imageData = try? Data(contentsOf: url)
        UserDefaults.standard.setValue(imageData, forKeyPath: keyBigAvatarTalking)
        }
    }
    let imgFL = FLAnimatedImage(animatedGIFData: imageData)
    return imgFL
}









