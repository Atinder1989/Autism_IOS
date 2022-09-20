//
//  NetworkRetryView.swift
//  JioTayari
//
//  Created by Bhavishya on 17/07/18.
//  Copyright © 2018 Somesh. All rights reserved.
//

import UIKit

protocol PauseViewDelegate: class {
    func didTapOnPlay()
}

class PauseView: UIView {

    weak var delegate: PauseViewDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setDelegate(delegate: PauseViewDelegate) {
        self.delegate = delegate
    }
    @IBAction func btnRetry(_ sender: Any) {
        self.delegate.didTapOnPlay()
    }
}
