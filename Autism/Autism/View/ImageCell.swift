//
//  ImageCell.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/10.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol ImageCellDelegate:NSObject {
    func finishDownloading()
}

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var greenTickImageView: UIImageView!
    @IBOutlet weak var handImageView: UIImageView!

    @IBOutlet weak var tickWidthLayout: NSLayoutConstraint!
    @IBOutlet weak var tickHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var tickTrailLayout: NSLayoutConstraint!
    @IBOutlet weak var tickLeadLayout: NSLayoutConstraint!
    
    private weak var delegate: ImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(model:ImageModel) {
        self.dataImageView.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl()+model.image)
    }

    func setLayouts(wh:CGFloat, t:CGFloat, l:CGFloat) {
        tickWidthLayout.constant = wh
        tickHeightLayout.constant = wh
        tickTrailLayout.constant = t
        tickLeadLayout.constant = l
    }
}
