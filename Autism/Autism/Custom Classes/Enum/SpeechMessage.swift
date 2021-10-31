//
//  SpeechMessage.swift
//  Autism
//
//  Created by Savleen on 07/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation


 enum SpeechEnglishMessage: String {
    case moveForward = "No Problem, Lets Move forward"
    case hurrayGoodJob = "Good Job"
    case wrongAnswer = "Wrong Answer"
    case keepTrying = "Keep Trying"
    case excellentWork = "Excellent Work"
    case greatToKnowYou = "Great to know you "
    case lookingForYou = "Hey Where are you <br> I am looking for you"
    case welcomeBack = "welcomeBack good to see you again"
    case rectifyAnswer = "This is "
}

 enum SpeechJapaneseMessage: String {
    case moveForward = "いいよ。では、つぎに"
    case hurrayGoodJob = "すごいね"
    case wrongAnswer = "ちがうよ"
    case keepTrying = "つづけて"
    case excellentWork = "いいね"
    case greatToKnowYou = "お会いできてうれしいです。"
    case lookingForYou = "Hey Where are you <br> I am looking for you"
    case welcomeBack = "welcomeBack good to see you again"
    case rectifyAnswer = "これは"

}

enum SpeechMessage: String {
    case moveForward = "moveForward"
    case hurrayGoodJob = "hurrayGoodJob"
    case wrongAnswer = "wrongAnswer"
    case keepTrying = "keepTrying"
    case excellentWork = "excellentWork"
    case greatToKnowYou = "greatToKnowYou"
    case lookingForYou = "lookingForYou"
    case welcomeBack = "welcomeBack"
    case rectifyAnswer = "rectifyAnswer"
    case none = "none"
    
    func getMessage() -> String {
        var message = ""
        if let user = UserManager.shared.getUserInfo() {
            switch self {
                case .moveForward:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.moveForward.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.moveForward.rawValue
                    }
                break
                case .hurrayGoodJob:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.hurrayGoodJob.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.hurrayGoodJob.rawValue
                    }
                break
                case .keepTrying:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.keepTrying.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.keepTrying.rawValue
                    }
                break
                case .excellentWork:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.excellentWork.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.excellentWork.rawValue
                    }
                break
                case .greatToKnowYou:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.greatToKnowYou.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.greatToKnowYou.rawValue
                    }
                break
                case .lookingForYou:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.lookingForYou.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.lookingForYou.rawValue
                    }
                break
                case .welcomeBack:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.welcomeBack.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.welcomeBack.rawValue
                    }
                break
                case .wrongAnswer:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.wrongAnswer.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.wrongAnswer.rawValue
                    }
                break
                case .rectifyAnswer:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.rectifyAnswer.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.rectifyAnswer.rawValue
                    }
                break
            default:break
            }
        }
        
        return message
    }
    
   
    func getMessage(_ correctText:String) -> String {
        var message = correctText
        if(message != "") {
           return message
        }
        if let user = UserManager.shared.getUserInfo() {
            switch self {
                case .moveForward:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.moveForward.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.moveForward.rawValue
                    }
                break
                case .hurrayGoodJob:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.hurrayGoodJob.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.hurrayGoodJob.rawValue
                    }
                break
                case .keepTrying:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.keepTrying.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.keepTrying.rawValue
                    }
                break
                case .excellentWork:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.excellentWork.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.excellentWork.rawValue
                    }
                break
                case .greatToKnowYou:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.greatToKnowYou.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.greatToKnowYou.rawValue
                    }
                break
                case .lookingForYou:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.lookingForYou.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.lookingForYou.rawValue
                    }
                break
                case .welcomeBack:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.welcomeBack.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.welcomeBack.rawValue
                    }
                break
                case .wrongAnswer:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.wrongAnswer.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.wrongAnswer.rawValue
                    }
                break
                case .rectifyAnswer:
                    if user.languageCode == AppLanguage.en.rawValue {
                        message = SpeechEnglishMessage.rectifyAnswer.rawValue
                    }  else if user.languageCode == AppLanguage.ja.rawValue {
                        message = SpeechJapaneseMessage.rectifyAnswer.rawValue
                    }
                break
            default:break
            }
        }
        
        return message
    }
}
