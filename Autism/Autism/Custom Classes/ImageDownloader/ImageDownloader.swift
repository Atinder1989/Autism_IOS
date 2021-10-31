//
//  ImageDownloader.swift
//  Autism
//
//  Created by Savleen on 10/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import UIKit
import FLAnimatedImage

protocol ImageDownloaderDelegate:NSObject {
    func finishDownloading()
}
class ImageDownloader {
   static let sharedInstance = ImageDownloader()
    private var totalCount = 0
    
    func downloadImage(urlString:String,imageView: UIImageView,callbackAfterNoofImages:Int,delegate:ImageDownloaderDelegate?) {
        self.resetData()
        // Create URL
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        let trimmedString = stringSpace.trimmingCharacters(in: .whitespaces)
        
        if let url = URL.init(string: trimmedString ) {
        // Create Data Task
        let dataTask = URLSession.shared.dataTask(with: url) {[weak self] (data, _, _) in
            if let data = data {
                // Create Image and Update Image View
                guard let me = self else { return }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    imageView.image = image
                    me.totalCount = me.totalCount  + 1
                    if me.totalCount == callbackAfterNoofImages {
                        me.totalCount = 0
                        if let del = delegate {
                            del.finishDownloading()
                        }
                    }
                }
            }
        }
        // Start Data Task
        dataTask.resume()
        }
    }
    
    func downloadGIFImage(urlString:String,imageView: FLAnimatedImageView,callbackAfterNoofImages:Int,delegate:ImageDownloaderDelegate?) {
        self.resetData()
        // Create URL
        let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        let trimmedString = stringSpace.trimmingCharacters(in: .whitespaces)
        
        if let url = URL.init(string: trimmedString ) {
        // Create Data Task
        let dataTask = URLSession.shared.dataTask(with: url) {[weak self] (data, _, _) in
            if let data = data {
                // Create Image and Update Image View
                guard let me = self else { return }
                DispatchQueue.main.async {                    
                    let imgFL = FLAnimatedImage(animatedGIFData: data)
                    imageView.animatedImage = imgFL
                    me.totalCount = me.totalCount  + 1
                    if me.totalCount == callbackAfterNoofImages {
                        me.totalCount = 0
                        if let del = delegate {
                            del.finishDownloading()
                        }
                    }
                }
            }
        }
        // Start Data Task
        dataTask.resume()
        }
    }
    
    private func resetData() {
        self.totalCount = 0
    }
    
}

