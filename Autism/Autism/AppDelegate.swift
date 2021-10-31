//
//  AppDelegate.swift
//  Autism
//
//  Created by IMPUTE on 20/09/19.
//  Copyright © 2019 IMPUTE. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import CoreMotion
import GoogleSignIn
import FBSDKCoreKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import ARKit




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    public static let shared = UIApplication.shared.delegate as? AppDelegate

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.landscape
    
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.initializeAnalyticsAndCrashlytics()
        self.initializeSocialNetwork(application, didFinishLaunchingWithOptions: launchOptions)
        self.customSettings()
        self.checkExistingUser()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if SpeechManager.shared.isSpeaking() {
            SpeechManager.shared.pauseSpeech()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Utility.sharedInstance.stopMonitoring()
        if SpeechManager.shared.isPaused() {
            SpeechManager.shared.continueSpeech()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Utility.sharedInstance.startNetworkNotifier()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.orientationLock
    }

}


extension AppDelegate {
    private func initializeSocialNetwork(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        GIDSignIn.sharedInstance().clientID = AppConstant.gmailClientID.rawValue
          ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initializeAnalyticsAndCrashlytics() {
        MSAppCenter.start(AppConstant.analyticsKey.rawValue, withServices:[
                 MSAnalytics.self,
                 MSCrashes.self
               ])
    }
    
    private func customSettings() {
               // Override point for customization after application launch.
               UIApplication.shared.statusBarStyle = .lightContent
               let _ = CMMotionManager()
               let audioSession = AVAudioSession.sharedInstance()
               do {
                   try audioSession.setCategory(AVAudioSession.Category.record)
                   try audioSession.setMode(AVAudioSession.Mode.measurement)
                   try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
               
               } catch {
                   print("audioSession properties weren't set because of an error.")
               }
               SpeechManager.shared.requestAuthorizationPermissions()
    }
    
    private func checkExistingUser() {
         if let user = DatabaseManager.sharedInstance.getLoginUserData() {
            print("user print = ", user)
            self.orientationLock = .landscape
                   UserManager.shared.saveUserInfo(userVO: user)
                   let languageModel = LanguageModel.init(name: user.languageName, code: user.languageCode, image: user.languageImage, status: user.languageStatus)
                   selectedLanguageModel = languageModel
                   if  let type = ScreenRedirection.init(rawValue: user.screen_id) {
                let vc = type.getViewController()
              // let vc = Utility.getViewController(ofType: UserProfileViewController.self)
                       let navController = UINavigationController(rootViewController: vc)
                       navController.navigationBar.isTranslucent = false
                       self.window!.rootViewController = navController
                       self.window!.makeKeyAndVisible()
                   }
               }
    }
    
}
