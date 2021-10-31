//
//  GoogleSpeechService.swift
//  Google TTS Demo
//
//  Created by Savleen on 25/05/21.
//  Copyright © 2021 Alejandro Cotilla. All rights reserved.
//

import UIKit
import AVFoundation

// https://cloud.google.com/text-to-speech/docs/voices

protocol GoogleSpeechServiceDelegate {
    func googleSpeechDidFinish(speechText:String)
    func googleSpeechDidStart(speechText:String)
}

extension GoogleSpeechServiceDelegate {
    func googleSpeechDidStart(speechText:String) {}
}

//enum VoiceType: String {
//    case undefined
////    case waveNetFemale = "en-US-Wavenet-F"
////    case waveNetMale = "en-US-Wavenet-D"
////    case standardFemale = "en-US-Standard-E"
////    case standardMale = "en-US-Standard-D"
//
//    case standardA = "ja-JP-Standard-A"
//    case standardB = "ja-JP-Standard-B"
//    case standardC = "ja-JP-Standard-C"
//    case standardD = "ja-JP-Standard-D"
//
//    case waveNetA = "ja-JP-Wavenet-A"
//    case waveNetB = "ja-JP-Wavenet-B"
//    case waveNetC = "ja-JP-Wavenet-C"
//    case waveNetD = "ja-JP-Wavenet-D"
//
//}

let ttsAPIUrl = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"
let APIKey = "AIzaSyBvXnaW5fIIAcJrgTS8-33MXqGuE2XaG9k"

class GoogleSpeechService: NSObject, AVAudioPlayerDelegate {

    static let shared = GoogleSpeechService()
    private(set) var busy: Bool = false
    
    private var player: AVAudioPlayer?
    //private var completionHandler: (() -> Void)?
    private var delegate: GoogleSpeechServiceDelegate?
    private var speechText = ""
    
    func isGoogleSpeechPlaying() -> Bool {
        if let player = self.player {
            return player.rate == 0 ? false : true
        }
        return false
    }
    
    func pauseGoogleSpeech() {
        if let player = self.player {
            player.pause()
        }
    }
    
    func resumeGoogleSpeech() {
        if let player = self.player {
            player.play()
        }
    }
    
    func stopGoogleSpeech() {
        if let player = player {
            player.pause()
            self.player = nil
            print("player deallocated")
        }
    }

    func speak(delegate: GoogleSpeechServiceDelegate?,text: String) {
        self.delegate = delegate
        guard !self.busy else {
            print("Speech Service busy!")
            return
        }
        self.busy = true
        
        DispatchQueue.global(qos: .background).async {
            let postData = self.buildPostData(text: text, voiceType: Utility.getVoiceTypeForJapaneseUser())
            let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePOSTRequest(url: ttsAPIUrl, postData: postData, headers: headers)

            // Get the `audioContent` (as a base64 encoded string) from the response.
            guard let audioContent = response["audioContent"] as? String else {
                print("Invalid response: \(response)")
                self.busy = false
//                DispatchQueue.main.async {
//                    completion()
//                }
                return
            }
            
            // Decode the base64 string into a Data object
            guard let audioData = Data(base64Encoded: audioContent) else {
                self.busy = false
//                DispatchQueue.main.async {
//                    completion()
//                }
                return
            }
            
            DispatchQueue.main.async {
               // self.completionHandler = completion
                self.player = try! AVAudioPlayer(data: audioData)
                if let player = self.player {
                    self.speechText = text
                    player.delegate = self
                    player.play()
                    if let delegate = self.delegate {
                        delegate.googleSpeechDidStart(speechText: text)
                    }
                }
                
                
            }
        }
    }
    
    private func buildPostData(text: String, voiceType: String) -> Data {
        
        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": "en-US"
        ]
        voiceParams["name"] = voiceType
        
        let params: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": voiceParams,
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16",
                "speakingRate" : 0.75,
            ]
        ]

        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    // Just a function that makes a POST request.
    private func makePOSTRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dict
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let delegate = self.delegate, let player = self.player {
            self.busy = false
            player.delegate = nil
            self.player = nil
            delegate.googleSpeechDidFinish(speechText: self.speechText)
            self.speechText = ""
        }
       // self.completionHandler!()
      //  self.completionHandler = nil
    }
}
