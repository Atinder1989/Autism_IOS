//
//  FaceNotDetectionView.swift
//  Autism
//
//  Created by Savleen on 07/01/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit

protocol FaceNotDetectionViewDelegate: class {
    func didTapOnOk()
}

class FaceNotDetectionView: UIView {
    weak var delegate: FaceNotDetectionViewDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setDelegate(delegate: FaceNotDetectionViewDelegate) {
        self.delegate = delegate
    }
    @IBAction func backGroundClicked(_ sender: Any) {
        self.delegate.didTapOnOk()
    }
}
