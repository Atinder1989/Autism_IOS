//
//  SpeechManager.swift
//  POC_ARKit
//
//  Created by Atinderpal Singh on 7/9/19.
//  Copyright © 2019 Reliance Jio Infocomm. All rights reserved.
//
// https://www.appcoda.com/text-to-speech-ios-tutorial/
import Foundation
import AVFoundation
import Speech

protocol SpeechManagerDelegate {
    func speechDidFinish(speechText:String)
    func speechDidStart(speechText:String)
}

extension SpeechManagerDelegate {
  //  func speechDidFinish() {}
    func speechDidStart(speechText:String) {}
}

class SpeechManager: NSObject {
    static let shared = SpeechManager()
    private override init() {}
    
    private let synthesizer = AVSpeechSynthesizer()
    private var delegate: SpeechManagerDelegate?
    private var rate = 0
    private var totalLinesToSpeak: Int = 0
    private var currentLineIndex: Int = 0
    
    private var audioPlayer : AVPlayer!

    func setDelegate(delegate: SpeechManagerDelegate?) {
        self.delegate = delegate
    }
    
    func requestAuthorizationPermissions() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            switch authStatus {
            case .authorized:
                print("User authorized to speech recognition")
            case .denied:
                print("User denied access to speech recognition")
            case .restricted:
                print("Speech recognition restricted on this device")
            case .notDetermined:
                print("Speech recognition not yet authorized")
            default:
                print("Default")
            }
        }
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }
    
    private func addObserver(item: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(SpeechManager.playerDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    private func playAudio(url: String) {
        let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + url
        if let url = URL.init(string: urlString) {
            if let player = audioPlayer {
                removeObserver()
                let item = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: item)
                player.play()
                addObserver(item: item)
                if let del = self.delegate {
                    rate = 1
                    del.speechDidStart(speechText: "")
                }
            } else {
                let item = AVPlayerItem(url: url)
                audioPlayer = AVPlayer.init(playerItem: item)
                if let player = audioPlayer {
                    player.play()
                    addObserver(item: item)
                    if let del = self.delegate {
                        rate = 1
                        del.speechDidStart(speechText: "")
                    }
                }
            }
        }
    }
    
    @objc func playerDidFinishPlaying(notification: NSNotification) {
        rate = 0
        if let del = self.delegate {
            del.speechDidFinish(speechText: "")
        }
    }
     
    func speak(message:String,uttrenceRate:Float) {
        if !self.isPlaying() {
            
            if message.contains("uploads/") {
                self.playAudio(url: message)
                return
            }
            
            if let user = UserManager.shared.getUserInfo() {
                if user.languageCode == AppLanguage.en.rawValue {
                    handleSpeechForEnglishUser(message: message, uttrenceRate: uttrenceRate)
                } else if user.languageCode == AppLanguage.ja.rawValue {
                    handleSpeechForJapaneseUser(message:message)
                }
            }
        }
    }
    private func handleSpeechForJapaneseUser(message:String) {
        let replaced = message.replacingOccurrences(of: "<br>", with: ", ")
        GoogleSpeechService.shared.speak(delegate: self, text: replaced)
    }
    
    private func handleSpeechForEnglishUser(message:String,uttrenceRate:Float) {
        let textParagraphs = message.components(separatedBy: "<br>")
        self.totalLinesToSpeak = textParagraphs.count
        self.currentLineIndex = 0
        for pieceOfText in textParagraphs {
            self.rate = 1
            let speechUtterance = AVSpeechUtterance(string: pieceOfText)
            speechUtterance.voice = AVSpeechSynthesisVoice(identifier: Utility.getSpeechIdentifierForEnglishUser())
            speechUtterance.rate = uttrenceRate
            speechUtterance.volume = 1
            speechUtterance.postUtteranceDelay = TimeInterval(AppConstant.postUtteranceDelay.rawValue)!
            synthesizer.delegate = self
            synthesizer.speak(speechUtterance)
        }
    }
    
    
    func isPlaying() -> Bool {
        return rate == 0 ? false : true
    }
    
    func isSpeaking() -> Bool {
        if let user = UserManager.shared.getUserInfo() {
            if user.languageCode == AppLanguage.en.rawValue {
                return self.synthesizer.isSpeaking
            } else if user.languageCode == AppLanguage.ja.rawValue {
                return GoogleSpeechService.shared.isGoogleSpeechPlaying()
            }
        }
        return false
    }
    
    func isPaused() -> Bool {
        if let user = UserManager.shared.getUserInfo() {
            if user.languageCode == AppLanguage.en.rawValue {
                return self.synthesizer.isPaused
            } else if user.languageCode == AppLanguage.ja.rawValue {
                return GoogleSpeechService.shared.isGoogleSpeechPlaying()
            }
        }
        return false
    }
    
    private func resetValues() {
         self.currentLineIndex = 0
         self.totalLinesToSpeak = 0
    }
    
    func stopSpeech() {
        self.rate = 0
        if let user = UserManager.shared.getUserInfo() {
            if user.languageCode == AppLanguage.en.rawValue {
                self.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            } else if user.languageCode == AppLanguage.ja.rawValue {
                return GoogleSpeechService.shared.stopGoogleSpeech()
            }
        }
    }
    
    func pauseSpeech() {
        if let user = UserManager.shared.getUserInfo() {
            if user.languageCode == AppLanguage.en.rawValue {
                self.synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
            } else if user.languageCode == AppLanguage.ja.rawValue {
                return GoogleSpeechService.shared.pauseGoogleSpeech()
            }
        }
    }
    
    func continueSpeech() {
        if let user = UserManager.shared.getUserInfo() {
            if user.languageCode == AppLanguage.en.rawValue {
                self.synthesizer.continueSpeaking()
            } else if user.languageCode == AppLanguage.ja.rawValue {
                return GoogleSpeechService.shared.resumeGoogleSpeech()
            }
        }
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        rate = 1
        currentLineIndex += 1
        if let del = self.delegate {
            del.speechDidStart(speechText: utterance.speechString)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        rate = 0
        if currentLineIndex == totalLinesToSpeak {
            if let del = self.delegate {
                self.resetValues()
                del.speechDidFinish(speechText: utterance.speechString)
            }
        }
    }
    
   
}

extension SpeechManager: GoogleSpeechServiceDelegate {
    func googleSpeechDidFinish(speechText:String) {
        rate = 0
        if let del = self.delegate {
            del.speechDidFinish(speechText: speechText)
        }
    }
    func googleSpeechDidStart(speechText:String) {
        rate = 1
        if let del = self.delegate {
            del.speechDidStart(speechText: speechText)
        }
    }
}
