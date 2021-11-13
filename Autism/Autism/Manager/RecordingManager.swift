//
//  RecordingManager.swift
//  POC_ARKit
//
//  Created by Atinderpal Singh on 7/11/19.
//  Copyright © 2019 Reliance Jio Infocomm. All rights reserved.
//

//554c29bd539dfd6f401ffb58cc13dc16f93e6ba8

import Foundation
import Speech


protocol RecordingManagerDelegate {
    func recordingStart()
    func recordingSpeechData(text:String)
    func recordingFinish(speechText:String)
}

extension RecordingManagerDelegate {
    func recordingStart() {}
    func recordingFinish(speechText:String) {}
    func recordingSpeechData(text:String) {}
}

class RecordingManager:NSObject {
    private override init() {}
    
    // Singleton Method
    static let shared = RecordingManager()

    private var delegate: RecordingManagerDelegate?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: Utility.getLanguageCode()))
    private var recognitionRequest : SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
   // private let audioEngine = AVAudioEngine()
    private var audioEngine: AVAudioEngine?

    private var waitForUserAnswerTimer = Timer()
    private var isfinalTextTimer: Timer? = nil

    private var predictedResult: SFSpeechRecognitionResult? = nil
    private var isRecorder = false
    
    func startRecording(delegate: RecordingManagerDelegate) {
        // Setup audio engine and speech recognizer
        if self.isRecording() {
            return
        }
        
        if SpeechManager.shared.isPlaying() {
            return
        }
        
        if !FaceDetection.shared.isFaceDetected {
            return
        }
        
        self.delegate = delegate
        recognitionRequest = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        self.audioEngine = AVAudioEngine()
        if let engine = self.audioEngine {
        isRecorder = true
        let node = engine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            if let request = self.recognitionRequest {
                request.append(buffer)
            }
        }
        
        // Prepare and start recording
        engine.prepare()
        do {
            try engine.start()
        } catch {
            return print(error)
        }
        }
                
        recognitionTask = nil
        if let request = self.recognitionRequest {
            request.shouldReportPartialResults = true
            speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: Utility.getLanguageCode()))
            recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
                if let r = result {
                    self.predictedResult = r
                        print("String is === \(r.bestTranscription.formattedString)")
                        print(r.isFinal)
                    if let del = self.delegate {
                            
                            if let user = UserManager.shared.getUserInfo() {
                                if user.languageCode == AppLanguage.ja.rawValue {
                                    del.recordingSpeechData(text: r.bestTranscription.formattedString.hiragana)
                                } else {
                                    del.recordingSpeechData(text: r.bestTranscription.formattedString)
                                }
                            }
                                                        
                         }
                } else if let error = error {
                    print(error)
                }
            })
        }
        if let del = self.delegate {
            print("****** Recording Start ==========")
            del.recordingStart()
        }
        self.waitForUserAnswerTimer = Timer.scheduledTimer(timeInterval: TimeInterval(4), target: self, selector: #selector(userAnswerTimerAction), userInfo: nil, repeats: false)
    }
    
   
     func stopRecording() {
        if let engine = self.audioEngine {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
            self.audioEngine = nil
        }
        if let task = recognitionTask {
            task.cancel()
            recognitionTask = nil
        }
        self.delegate = nil
        self.isRecorder = false
    }
    
    func isRecording() -> Bool {
//        if let _ = self.audioEngine {
//            return true
//        }
//        return false
        
        return isRecorder
    }
    
    func pauseRecording() {
        if let engine = self.audioEngine {
            engine.pause()
        }
    }
    
    @objc  private func userAnswerTimerAction() {
        print("Recording Manager Timer ======")
        userAnswerRecorded()
    }
    
    func stopWaitUserAnswerTimer() {
        print("stopWaitUserAnswerTimer ##### ")
        waitForUserAnswerTimer.invalidate()
    }
    
    private func userAnswerRecorded() {
        self.stopWaitUserAnswerTimer()
        if let del = self.delegate {
            if let result = predictedResult {
                
                if let user = UserManager.shared.getUserInfo() {
                    if user.languageCode == AppLanguage.ja.rawValue {
                        del.recordingFinish(speechText: result.bestTranscription.formattedString.hiragana)
                    } else {
                        del.recordingFinish(speechText: result.bestTranscription.formattedString)
                    }
                }

            } else {
                del.recordingFinish(speechText: "")
            }
        }
        self.predictedResult = nil
    }
}



private extension CFStringTokenizer {
    var hiragana: String { string(to: kCFStringTransformLatinHiragana) }
    var katakana: String { string(to: kCFStringTransformLatinKatakana) }

    private func string(to transform: CFString) -> String {
        var output: String = ""
        while !CFStringTokenizerAdvanceToNextToken(self).isEmpty {
            output.append(letter(to: transform))
        }
        return output
    }

    private func letter(to transform: CFString) -> String {
        let mutableString: NSMutableString =
            CFStringTokenizerCopyCurrentTokenAttribute(self, kCFStringTokenizerAttributeLatinTranscription)
                .flatMap { $0 as? NSString }
                .map { $0.mutableCopy() }
                .flatMap { $0 as? NSMutableString } ?? NSMutableString()
        CFStringTransform(mutableString, nil, transform, false)
        return mutableString as String
    }
}


enum Kana { case hiragana, katakana }

func convert(_ input: String, to kana: Kana) -> String {
    let trimmed: String = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let tokenizer: CFStringTokenizer =
        CFStringTokenizerCreate(kCFAllocatorDefault,
                                trimmed as CFString,
                                CFRangeMake(0, trimmed.utf16.count),
                                kCFStringTokenizerUnitWordBoundary,
                                Locale(identifier: "ja") as CFLocale)
    switch kana {
    case .hiragana: return tokenizer.hiragana
    case .katakana: return tokenizer.katakana
    }
}


extension String {
    var hiragana: String { convert(self, to: .hiragana) }
    var katakana: String { convert(self, to: .katakana) }
}

//let names: [String] = ["相葉雅紀", "松本潤", "二宮和也", "大野智", "櫻井翔"]
//for name in names {
//    print("\(name.katakana) / \(name.hiragana)")
//}
