//
//  JTPlayerController.swift
//  AppleJioTV
//
//  Created by Atinderpal Singh on 1/11/17.
//  Copyright © 2017 SushantAlone. All rights reserved.
//

import Foundation
import UIKit
import AVKit

struct VideoItem {
    var url: String
}

protocol PlayerControllerDelegate: class {
    func didChangeJTPlayerStatus(status: VideoPlayerStatus)
}
class PlayerController: NSObject {
var videoPlayer: VideoPlayer?
var avPlayerController: AVPlayerViewController?
   private weak var delegate: PlayerControllerDelegate?
    override init() {
        super.init()
    }
    // MARK: - Initialize Player Controller
    func initializePlayer(delegate: PlayerControllerDelegate) {
        self.delegate = delegate
        avPlayerController = AVPlayerViewController()
        if let controller = self.avPlayerController {
            controller.view.backgroundColor = .clear
        controller.videoGravity = .resizeAspectFill
            controller.showsPlaybackControls = false
        }
    }
    // MARK: - Play Video
    func playVideo(item: VideoItem) {
        if let player = videoPlayer {
            let asset = VideoPlayerAsset.init(item: item)
            asset.assetDelegate = player
        } else {
            videoPlayer = VideoPlayer.init(item: item)
            if let player = videoPlayer, let controller = self.avPlayerController {
                player.playerDelegate = self
                controller.player = videoPlayer
            }
           
        }
    }
    func stopVideo() {
        if let player = videoPlayer,let controller = avPlayerController {
            player.stop()
            player.playerDelegate = nil
            videoPlayer = nil
            delegate = nil
            controller.player = nil
            avPlayerController = nil
        }
    }
    func playPauseCommandToPlayer() {
        if let videoPlayerInstance = self.videoPlayer {
            if videoPlayerInstance.isPlaying {
                videoPlayerInstance.pause()
            } else {
                videoPlayerInstance.play()
            }
        }
    }
    func seekToTimeVideoPlayer(time: CMTime) {
        if let player = videoPlayer {
            player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
}

extension PlayerController: JTPlayerDelegate {
    func didChangeJTPlayerStatus(status: VideoPlayerStatus) {
        if let delegate = self.delegate {
            delegate.didChangeJTPlayerStatus(status: status)
        }
    }
}
