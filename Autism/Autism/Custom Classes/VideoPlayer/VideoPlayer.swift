//
//  VideoPlayer.swift
//  AppleJioTV
//
//  Created by Abhishek Srivastava on 27/10/17.
//  Copyright © 2017 SushantAlone. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import AudioToolbox

enum VideoPlayerStatus {
    case readyToPlay
    case failed(message: String?, error: Error?)
    case bufferEmpty
    case playbackLikelyToKeepUp
    case rate(rate: Double)
    case reachedToEnd
    case interruptionBegan
    case interruptionEnded
    case updateUI(Float, String, String)
    case none
}
protocol JTPlayerDelegate: NSObjectProtocol {
    func didChangeJTPlayerStatus(status: VideoPlayerStatus)
}
private var playerViewControllerKVOContext = 0
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
class VideoPlayer: AVPlayer {
    enum VideoPlayerObserver: String {
        case playerRate                       =  "rate"
        case playerStatus                     =  "status"
        case playerPlayBackLikelyToKeepUp     =  "playbackLikelyToKeepUp"
        case playerPlaybackBufferEmpty        =  "playbackBufferEmpty"
    }
    private var playerTimeObserverToken: Any?
    private var playerItem: AVPlayerItem?
    weak var playerDelegate: JTPlayerDelegate?
    private var item: VideoItem?
   // private var observer: Any?

    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    // MARK: - Initialization
    convenience init(item: VideoItem) {
        self.init()
        let asset = VideoPlayerAsset.init(item: item)
        asset.assetDelegate = self
       // setupHeadSetToggle()
        addPlayerInterruptionNotification()
        setupNowPlayingInfoCenterForLockScreen()
//        do{
//         //   try AVAudioSession.sharedInstance().setActive(false)
//        }catch{print(error)}
    }
    // MARK: - Add Interuption Notification
    private func addPlayerInterruptionNotification() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleInterruption),
//                                               name: .AVAudioSessionInterruption,
//                                               object: AVAudioSession.sharedInstance())
//
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
        
        
        
    }
    // MARK: - Handle Interuption Notification
    @objc func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        if let delegate = self.playerDelegate {
        
        if type == .began {
            print("began INTRUPPTION")
            // Interruption began, take appropriate actions (save state, update user interface)
            delegate.didChangeJTPlayerStatus(status: .interruptionBegan)
        } else if type == .ended {
            print("End INTRUPPTION")
            let dict = notification.userInfo
            guard let optionsValue =
                dict?[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                delegate.didChangeJTPlayerStatus(status: .interruptionEnded)
            }
        }
        }
        
    }
    // MARK: - Set Up HeadSet Toggle
    private func setupHeadSetToggle() {
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(handleHeadSetToggle))
    }
    // MARK: - Handle HeadSet Toggle
    @objc func handleHeadSetToggle() {
        if self.isPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    // MARK: - Set NowPlaying Info Center For Lock Screen
    private func setupNowPlayingInfoCenterForLockScreen() {
            MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] _ in
                if let this = self {
                    this.play()
                }
                return .success
            }
            MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] _ in
                if let this = self {
                    this.pause()
                }
                return .success
            }
    }
    // MARK: - Play Video
     func playVideo() {
        if self.currentItem != nil {
            self.removePlayerObserver()
        }
        self.replaceCurrentItem(with: self.playerItem)
        self.addPlayerNotificationObserver()
        self.allowsExternalPlayback = true; // for airplay
        self.play()
    }
    func stop() {
        self.removePlayerObserver()
        self.item = nil
    }
    // MARK: - Observer Methods
    // MARK: - Add Player Observer
    private func addPlayerNotificationObserver () {
        self.addObserver(self, forKeyPath: VideoPlayerObserver.playerRate.rawValue,
                         options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: VideoPlayerObserver.playerStatus.rawValue,
                                     options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: VideoPlayerObserver.playerPlayBackLikelyToKeepUp.rawValue,
                                     options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: VideoPlayerObserver.playerPlaybackBufferEmpty.rawValue,
                                     options: .new, context: nil)
        
//        observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
//                                                          object: self.currentItem,
//                                              queue: nil) { [weak self] note in
//            if let this = self, let delegate = this.playerDelegate {
//                this.item = nil
//                delegate.didChangeJTPlayerStatus(status: .reachedToEnd)
//            }
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didItemReachedtoEnd(_:)),
                                    name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
    //    NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged), name:AVAudioSession.routeChangeNotification, object: nil)

    }
    
    
    func addPlayerPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        // Add time observer
        playerTimeObserverToken =
    self.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {[weak self] time in
        
        if let this = self, let del = this.playerDelegate {
                let sliderValue = Float(CMTimeGetSeconds(time))
                let currentTimeDuration = this.createTimeString(time: sliderValue)
                let totalItemDuration = this.createTimeString(time: Float((this.getPlayerDuration())))
            let status = VideoPlayerStatus.updateUI(sliderValue, currentTimeDuration, totalItemDuration)
            del.didChangeJTPlayerStatus(status: status)
                }
              }
    }
    
    func getPlayerDuration() -> Double {
        guard let currentItem = self.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
    func getCurrentTime() -> Double {
        return CMTimeGetSeconds(currentItem?.currentTime() ?? CMTime.init(seconds: 0.0,
                                preferredTimescale: CMTimeScale.init(0)))
    }
    // MARK: - Player Helper Method
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    // MARK: - Remove Player Observer
    func removePlayerObserver() {
        self.pause()
        if let timeObserverToken = playerTimeObserverToken {
            self.removeTimeObserver(timeObserverToken)
        }
//        if let ob = observer {
//            NotificationCenter.default.removeObserver(ob)
//        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
        
      //  NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification,
                                       //           object: nil)
        
        if let existingItem = self.currentItem {
            existingItem.removeObserver(self, forKeyPath: VideoPlayerObserver.playerStatus.rawValue)
            existingItem.removeObserver(self, forKeyPath: VideoPlayerObserver.playerPlaybackBufferEmpty.rawValue)
            existingItem.removeObserver(self, forKeyPath: VideoPlayerObserver.playerPlayBackLikelyToKeepUp.rawValue)
        }
        self.playerTimeObserverToken = nil
    }
    // MARK: - Player Notification
    @objc private func didItemReachedtoEnd(_ notification: Notification) {
        self.item = nil
        if let delegate =  self.playerDelegate {
            delegate.didChangeJTPlayerStatus(status: .reachedToEnd)
        }
    }
    
    @objc private func audioRouteChanged(note: Notification) {
      if let userInfo = note.userInfo {
        if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? Int {
            if reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
            self.play()
          }
        }
      }
    }
    
    // MARK: - Player Observer Method
    // Update our UI when player or `player.currentItem` changes.
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if let delegate = self.playerDelegate {
        
        if keyPath == VideoPlayerObserver.playerRate.rawValue {
            if let newRate = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.doubleValue {
                delegate.didChangeJTPlayerStatus(status: .rate(rate: newRate))
            }
            } else if keyPath == VideoPlayerObserver.playerPlaybackBufferEmpty.rawValue {
                print("$$$$$$$$$$$$$$$$$ buffer empty")
                delegate.didChangeJTPlayerStatus(status: .bufferEmpty)
        } else if keyPath == VideoPlayerObserver.playerPlayBackLikelyToKeepUp.rawValue {
            delegate.didChangeJTPlayerStatus(status: .playbackLikelyToKeepUp)
        } else if keyPath == VideoPlayerObserver.playerStatus.rawValue {
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
            } else {
                newStatus = .unknown
            }
            switch newStatus {
            case .readyToPlay:

                if playerTimeObserverToken == nil {
                    self.addPlayerPeriodicTimeObserver()
                }
                delegate.didChangeJTPlayerStatus(status: .readyToPlay)
            case .failed:
                if let item = self.currentItem, let e = item.error {
                    delegate.didChangeJTPlayerStatus(status: .failed(message: e.localizedDescription, error: item.error))
                }
            default:
                print("unknown")
            }
        }
        
        }
        
    }
// MARK: - Class Deinitialisation
    deinit {
        print("player deinit")
        }
}
// MARK: - VideoPlayerAssetDelegate Method
extension VideoPlayer: VideoPlayerAssetDelegate {
    func willPlayAsset(asset: VideoPlayerAsset, item: VideoItem) {
        let newPlayerItem = AVPlayerItem(asset: asset,
                    automaticallyLoadedAssetKeys: VideoPlayer.assetKeysRequiredToPlay)
        self.playerItem = newPlayerItem
        self.playVideo()
        self.item = item
    }
    func assetConfigurationError (error: NSError?,errorString: String)
    {
        if let e = error {
            print(errorString)
            print(e.localizedDescription)
            print(e.code)
        }
    }
}
