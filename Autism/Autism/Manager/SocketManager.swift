//
//  SocketManager.swift
//  Autism
//
//  Created by Singh, Atinderpal on 25/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import Foundation
import Starscream
import Foundation
import Speech

protocol SocketManagerDelegate {
    func didSocketConnected()
    func didSocketDisConnected(text: String)
    func didSocketTextReceived(text: String)
    func didSocketRecordingStart()
}

class SocketManager {
    static let shared = SocketManager()
    private var socket: WebSocket?
    private var isConnected = false
    private let server = WebSocketServer()
   // var aws_vocabulary_name = "big_list.txt"
    private var aws_vocabulary_name = "vocab_list3"
    private let auth_id = "01cac0b6-79c2-4767-a73d-809e5fc4df99"
    private let auth_key = "g6828Xg\"RxN&`G9@0S)XO&eG20+=rr"
    private var outputText = ""
    private var bufferSize = 1600
    private var audioEngine: AVAudioEngine?
    private var delegate: SocketManagerDelegate?
}

// MARK: - Public Methods
extension SocketManager {
    func connect(delegate: SocketManagerDelegate) {
        self.delegate = delegate
        self.outputText = ""
        var request = URLRequest(url: URL(string: "ws://impute.co.jp:3001")!)
        request.timeoutInterval = 5
        request.setValue(aws_vocabulary_name, forHTTPHeaderField: "aws_vocabulary_name")
        request.setValue(auth_id, forHTTPHeaderField: "auth_id")
        request.setValue(auth_key, forHTTPHeaderField: "auth_key")
            
        if let socket = socket {
            socket.connect()
        } else {
            socket = WebSocket(request: request)
            if let socket = socket {
                socket.delegate = self
                socket.connect()
            }
        }
    }
}

// MARK: - Private Methods
extension SocketManager {
    private func validateRecordPermissionAndStartTapping() {
        switch AVAudioSession.sharedInstance().recordPermission {
          case .granted:
            beginTappingMicrophone()
        case .denied: break
            //Show permissions denied alert
          case .undetermined:
            requestRecordPermissions()
        default: break
        }
    }
    
    private func requestRecordPermissions() {
      AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
        if granted {
          self.beginTappingMicrophone()
        }
        else {
          //Present Camera Permissions Denied Alert
        }
      }
    }
    

    private func beginTappingMicrophone() {
        
    self.audioEngine = AVAudioEngine()
        if let audioEngine = self.audioEngine {
        audioEngine.reset()
      
      let inputNode = audioEngine.inputNode
      let inputFormat = inputNode.outputFormat(forBus: 0)
      
        let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: Double(16000), channels: 1, interleaved: true)
        let formatConverter =  AVAudioConverter(from:inputFormat, to: recordingFormat!)
        
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(bufferSize), format: inputFormat) { [self] (buffer, time) in
                
            let pcmBuffer = AVAudioPCMBuffer(pcmFormat: recordingFormat!, frameCapacity: AVAudioFrameCount(3200))
                var error: NSError? = nil
                
                let inputBlock: AVAudioConverterInputBlock = {inNumPackets, outStatus in
                  outStatus.pointee = AVAudioConverterInputStatus.haveData
                  return buffer
                }
                
            formatConverter?.convert(to: pcmBuffer!, error: &error, withInputFrom: inputBlock)
                
                if error != nil {
                  print(error!.localizedDescription)
                }
                else if let channelData = pcmBuffer!.int16ChannelData {

                  let channelDataPointer = channelData.pointee
                  let channelData:[Int16] = stride(from: 0,
                                                     to: Int(pcmBuffer!.frameLength),
                                                     by: buffer.stride).map{ channelDataPointer[$0] }
                    let data =  Data.init(bytes: channelData, count: channelData.count)
                    if let socket = socket {
                        socket.write(data: data)
                    }
                }
            }
            
            audioEngine.prepare()
            do {
              try audioEngine.start()
            }
            catch {
              print(error.localizedDescription)
            }
            
            if let del = self.delegate {
                print("****** Socket Recording Start ==========")
                del.didSocketRecordingStart()
            }
        
        }
        
        
    }
    
    private func stopRecording() {
       if let engine = self.audioEngine {
           engine.reset()
           engine.stop()
           engine.inputNode.removeTap(onBus: 0)
           self.audioEngine = nil
       }
       self.delegate = nil
   }
    
    private func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
// MARK: - WebSocketDelegate
extension SocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        print("Socket Event ==== \(event)")
        switch event {
        case .connected( _):
            isConnected = true
            self.validateRecordPermissionAndStartTapping()
            if let delegate = self.delegate {
                delegate.didSocketConnected()
            }
        case .disconnected( _,  _):
            isConnected = false
            if let delegate = self.delegate {
                delegate.didSocketDisConnected(text: self.outputText)
            }
            self.stopRecording()
        case .text(let string):
            let dict = self.convertToDictionary(text: string)
            if let data = dict?["data"] as? String {
                let array = data.components(separatedBy: " ")
                print("array === \(array)")
                for item in array {
                    if !outputText.contains(item) {
                        self.outputText = self.outputText + " " + item + " "
                    }
                }
            }
            print("outputText ==== \(outputText)")
            if let delegate = self.delegate {
                delegate.didSocketTextReceived(text: outputText)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
            self.stopRecording()
        case .error(let error):
            isConnected = false
            self.stopRecording()
            handleError(error)
        }
    }
}
