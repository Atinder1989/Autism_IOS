//
//  VideoPlayerAsset.swift
//  AppleJioTV
//
//  Created by Atinderpal Singh on 30/10/17.
//  Copyright © 2017 SushantAlone. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayerAssetDelegate: class {
    func willPlayAsset(asset: VideoPlayerAsset, item: VideoItem)
    func assetConfigurationError (error: NSError?,errorString: String)
}

class VideoPlayerAsset: AVURLAsset {
    weak var assetDelegate: VideoPlayerAssetDelegate?
    // MARK: - Initialization
    convenience init(item: VideoItem) {
        var videoUrl = item.url.replacingOccurrences(of: "\t", with: "")
        videoUrl = videoUrl.replacingOccurrences(of: " ", with: "")
        if let url = URL.init(string: videoUrl) {
            self.init(url: url, options: nil)
            self.configureAsset(item: item)
        } else {
            self.init(url: URL.init(string: "")!, options: nil)
        }
    }
    // MARK: - Configure Asset
    private func configureAsset(item: VideoItem) {
        self.loadValuesAsynchronously(forKeys: VideoPlayer.assetKeysRequiredToPlay, completionHandler: {() -> Void in
            DispatchQueue.main.async {
                
                if let delegate = self.assetDelegate {
                for key in VideoPlayer.assetKeysRequiredToPlay {
                    var error: NSError?
                    if self.statusOfValue(forKey: key, error: &error) == .failed {
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description",
                                comment: "Can't use this AVAsset because one of it's keys failed to load")
                        delegate.assetConfigurationError(error: error,errorString: stringFormat)
                        return
                    }
                }
                // We can't play this asset.
                if !self.isPlayable {
                    let userInfo: [AnyHashable: Any] = [
                        NSLocalizedDescriptionKey: NSLocalizedString("Unplayable",
                        value: "Asset Not Playable", comment: "This asset is not playable") ]
                    let error: NSError = NSError(domain: "Internal", code: 8000, userInfo: userInfo as? [String: Any])
                    delegate.assetConfigurationError(error: error, errorString: "")
                    return
                }
                    delegate.willPlayAsset(asset: self, item: item)
                }
            }
        })
    }
}
