//
//  UIImageView+Extension.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/12.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SwiftyGif

extension UIImageView {
    func setImageWith(urlString:String,placeholderImage:String = "") {
        var imageUrl = urlString.replacingOccurrences(of: "\t", with: "")
        imageUrl = imageUrl.replacingOccurrences(of: " ", with: "")
        if let url = URL.init(string: imageUrl ) {
            let ph = UIImage.init(named: placeholderImage)
            self.sd_setImage(with: url, placeholderImage: ph, options: .refreshCached) {[weak self] (image, error, cache, url) in
                if let this = self {
                if let img = image {
                    this.image = img
                } else {
                    this.image = ph
                }
                }
            }
        }
    }
    
    func setGifWith(urlString:String) {
        if let url = URL.init(string:urlString) {
            self.setGifFromURL(url)
        }
    }
    
    func setGifFromBundle(gifname:String) {
        do {
            let gif = try UIImage(gifName: gifname)
            self.setGifImage(gif, loopCount: -1) // Will loop forever
        } catch {
            print(error)
        }
        
    }
}

//
