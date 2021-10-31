//
//  AutismTimer.swift
//  Autism
//
//  Created by Savleen on 07/01/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import Foundation

protocol AutismTimerDelegate: class {
    func timerUpdate()
}

class AutismTimer: NSObject {
    static let shared = AutismTimer()
    private var appTimer: Timer? = nil
    private override init() {
        super.init()
    }
    weak var delegate: AutismTimerDelegate?

    func initializeTimer(delegate:AutismTimerDelegate?) {
        self.delegate = delegate
        appTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken() {
        print("AutismTimer ===== ")
        if let delegate = self.delegate {
            delegate.timerUpdate()
        }
    }
    
    func stopTimer() {
         if let timer = self.appTimer {
             timer.invalidate()
            appTimer = nil
         }
    }
}

