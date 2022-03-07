//
//  UserManager.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class UserManager {
    private init() {}
    public static let shared = UserManager()
   private var isActionPerformed:Bool = false

    private var user: UserModel? = nil {
        didSet {
            DatabaseManager.sharedInstance.clearDatabaseWithEntityName(DatabaseEntity.User.rawValue)
            if let userVo = self.user {
                DatabaseManager.sharedInstance.saveUserInfo(model: userVo)
            }
        }
    }
    
    func saveUserInfo(userVO: UserModel) {
           self.user = userVO
    }
    
    func getUserInfo() -> UserModel? {
           return self.user
    }
    
    func clearCurrentUserData() {
        self.user = nil
        UserDefaults.standard.setValue(nil, forKeyPath: keyExcellent)
        UserDefaults.standard.setValue(nil, forKeyPath: keyIdle)
        UserDefaults.standard.setValue(nil, forKeyPath: keyWrongAnswer)
        UserDefaults.standard.setValue(nil, forKeyPath: keyTalking)
        UserDefaults.standard.setValue(nil, forKeyPath: keyHurray)        
        UserDefaults.standard.synchronize()
        DatabaseManager.sharedInstance.clearDatabaseWithEntityName(DatabaseEntity.AvatarVariation.rawValue)
    }
    
    func updateScreenId(screenid:String) {
        if let user =  self.user {
            var u = user
            u.screen_id = screenid
            self.saveUserInfo(userVO: u)
        }
    }
    
    func updateAvtarGender(gender:String) {
        if let user =  self.user {
            var u = user
            u.avatar_gender = gender
            self.saveUserInfo(userVO: u)
        }
    }
    
    func updateUserProfileInfo(response:UserProfileSubmitResponseVO) {
        if let user =  self.user {
            var u = user
            u.nickname = response.nickname
            u.screen_id = response.screen_id
            self.saveUserInfo(userVO: u)
        }
    }
    
    func updateAvatar(model:ImageModel) {
           if let user =  self.user {
               var u = user
                u.avatar = model.image
               self.saveUserInfo(userVO: u)
           }
    }
    
    func exitAssessment() {
        SpeechManager.shared.stopSpeech()
        FaceDetection.shared.stopFaceDetectionSession()
        AutismTimer.shared.stopTimer()
        if !isActionPerformed {
            isActionPerformed = true
            self.updateScreenId(screenid: ScreenRedirection.dashboard.rawValue)
            let vc = Utility.getViewController(ofType: DashboardViewController.self)
            self.setRootViewController(vc: vc)
        }
    }
    
    func logout() {
        AutismTimer.shared.stopTimer()
        self.clearCurrentUserData()
        let vc = Utility.getViewController(ofType: LanguageViewController.self)
        self.setRootViewController(vc: vc)
    }
    
    func resumeAssessment() {
        DispatchQueue.main.async {
            AutismTimer.shared.stopTimer()
            self.updateScreenId(screenid: ScreenRedirection.assesment.rawValue)
            let vc = Utility.getViewController(ofType: AssessmentViewController.self)
            self.setRootViewController(vc: vc)
        }
    }
    
    func resetAssessment() {
        DispatchQueue.main.async {
           AutismTimer.shared.stopTimer()
           self.updateScreenId(screenid: ScreenRedirection.assesment.rawValue)
           let vc = Utility.getViewController(ofType: AssessmentViewController.self)
           self.setRootViewController(vc: vc)
        }
    }
    
    private func setRootViewController(vc:UIViewController) {
        AutismTimer.shared.stopTimer()
        let navController = UINavigationController(rootViewController: vc)
           navController.navigationBar.isTranslucent = false
        if let appdel = AppDelegate.shared,let window = appdel.window {
           window.rootViewController = navController
            self.isActionPerformed = false
        }
    }
    
    func saveAvatarVariationList(list:[AvatarModel]) {
        if let user =  self.user {
            DatabaseManager.sharedInstance.clearDatabaseWithEntityName(DatabaseEntity.AvatarVariation.rawValue)
            for model in list {
                DatabaseManager.sharedInstance.saveAvatarVariation(model: model, user: user)
            }
        }
    }
    
}
