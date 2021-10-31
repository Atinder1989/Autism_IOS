//
//  NetworkRetryView.swift
//  JioTayari
//
//  Created by Bhavishya on 17/07/18.
//  Copyright © 2018 Somesh. All rights reserved.
//

import UIKit

protocol NetworkRetryViewDelegate: class {
    func didTapOnRetry()
}

class NetworkRetryView: UIView {

    weak var delegate: NetworkRetryViewDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setDelegate(delegate: NetworkRetryViewDelegate) {
        self.delegate = delegate
    }
    @IBAction func btnRetry(_ sender: Any) {
        self.delegate.didTapOnRetry()
    }
}
