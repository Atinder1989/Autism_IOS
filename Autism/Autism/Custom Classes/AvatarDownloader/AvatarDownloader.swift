//
//  AvatarDownloader.swift
//  Autism
//
//  Created by Savleen on 31/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import FLAnimatedImage

class AvatarDownloader {
    static let sharedInstance = AvatarDownloader()
    private var totalDownloadImagesCount = 0

    func downloadAvatarVariationList(list:[AvatarModel]) {

        for model in list {

            if(model.isDownloaded == false) {

                var imageData:Data? = UserDefaults.standard.object(forKey: model.variation_type) as? Data
                if(imageData == nil) {
                    
                    let stringSpace = ServiceHelper.baseURL.getMediaBaseUrl() + model.file
                    let urlString = stringSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)


                    let url = URL(string: urlString!)!
                    imageData = try? Data(contentsOf: url)
                    UserDefaults.standard.setValue(imageData, forKeyPath: model.variation_type)
                    DatabaseManager.sharedInstance.updateDownloadStatusOfAvatarVariation(variationType: model.variation_type, status: true)                    
                }
            }
                  Utility.hideLoader()
            //self.downloadfile(model: model, listCount: list.count)
        }
                
    }
    
    
}
