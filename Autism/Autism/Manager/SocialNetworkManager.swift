//
//  SocialNetworkManager.swift
//  HealthApp
//
//  Created by IMPUTE on 03/12/19.
//  Copyright © 2019 IMPUTE. All rights reserved.
//

import Foundation
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

enum SocialNetwork: String {
case facebook             = "FACEBOOK"
case gmail                = "GMAIL"
case none                 = "NONE"
}

protocol SocialNetworkManagerDelegate: class {
    func socialNetworkLogin(_ isSuccess: Bool, profile: SocialNetworkProfileModel?, error: Error?)
}


class SocialNetworkManager: NSObject {
    private weak var socialNetworkManagerDelegate: SocialNetworkManagerDelegate?
    override init () {}
}

// MARK: Public Methods
extension SocialNetworkManager {
   func handleSocialLogin(of type: SocialNetwork,delegate:SocialNetworkManagerDelegate) {
        self.socialNetworkManagerDelegate = delegate
        switch type {
        case .facebook:     handleFacebookLogin()
        case .gmail:        handleGmailLogin()
        default:break
        }
    }
}

// MARK: Private Methods
extension SocialNetworkManager {
       private  func handleGmailLogin() {
          if let topVC = UIApplication.topViewController() {
               GIDSignIn.sharedInstance()?.presentingViewController = topVC
          }
          GIDSignIn.sharedInstance()?.restorePreviousSignIn()
          GIDSignIn.sharedInstance().delegate = self
          GIDSignIn.sharedInstance().signIn()
       }
       
       private  func handleFacebookLogin() {
           let fbLoginManager: LoginManager = LoginManager()
           fbLoginManager.logOut()
        
           fbLoginManager.logIn(permissions: ["email", "public_profile"], from: nil) { (result, error) -> Void in
               if error == nil {
                   let fbloginresult: LoginManagerLoginResult = result!
                   // if user cancel the login
                   if (result?.isCancelled)! {
                        self.handleSocialNetworkError(error: error)
                       return
                   }
                   if fbloginresult.grantedPermissions.contains("email") {
                       self.getFacebookUserData()
                   } else {
                        self.handleSocialNetworkError(error: error)
                   }
               } else {
                    self.handleSocialNetworkError(error: error)
               }
           }
       }

       private func getFacebookUserData() {
           Utility.showLoader()
           if AccessToken.current != nil {
               GraphRequest(graphPath: "me",
                       parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(
                           completionHandler: { (_, result, error) -> Void in
                  Utility.hideLoader()
                   if error == nil {
                       guard  let info = result as? [String: AnyObject] else { return }
                        if let del = self.socialNetworkManagerDelegate {
                                let profile = SocialNetworkProfileModel.init(email: (info["email"] as? String)!, name: (info["name"] as? String)!, profileType: .facebook)
                                  del.socialNetworkLogin(true, profile: profile, error:nil)
                        }
                   } else {
                        self.handleSocialNetworkError(error: error)
                  }
               })
           }
       }
    
    private func handleSocialNetworkError(error:Error?) {
        if let del = self.socialNetworkManagerDelegate {
            print(error?.localizedDescription)
            print(error.debugDescription)
            
                                                                                 del.socialNetworkLogin(false, profile: nil, error:error)
                                                    }
    }
}

// MARK: Google Sign Delegate Methods
extension SocialNetworkManager: GIDSignInDelegate {

    @available(iOS 9.0, *)
    public func application(_ app: UIApplication, open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let facebookDidHandle = ApplicationDelegate.shared.application(
            app,
            open: (url as URL?)!,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url)
        return googleDidHandle || facebookDidHandle
    }

    public func application(_ application: UIApplication,
                        open url: URL,
                        sourceApplication: String?,
                        annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(
            application,
            open: (url as URL?)!,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }

    func application(application: UIApplication,
                     openURL url: NSURL,
                     sourceApplication: String?,
                     annotation: AnyObject) -> Bool {
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL)

        let facebookDidHandle = ApplicationDelegate.shared.application(
            application,
            open: (url as URL?)!,
            sourceApplication: sourceApplication,
            annotation: annotation)
        return googleDidHandle || facebookDidHandle
    }

     func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        self.handleSocialNetworkError(error: error)
        return
      }
          
        if let del = self.socialNetworkManagerDelegate {
            let profile = SocialNetworkProfileModel.init(email: user.profile.email, name: user.profile.name, profileType: .gmail)
            del.socialNetworkLogin(true, profile: profile, error:nil)
        }

    }
    
    // Start Google OAuth2 Authentication
    func sign(_ signIn: GIDSignIn?, present viewController: UIViewController?) {
    
      // Showing OAuth2 authentication window
        if let topVC = UIApplication.topViewController() {
            if let aController = viewController {
                    topVC.present(aController, animated: true) {() -> Void in }
            }
        }
    }
    // After Google OAuth2 authentication
    func sign(_ signIn: GIDSignIn?, dismiss viewController: UIViewController?) {
        if let topVC = UIApplication.topViewController() {
            topVC.dismiss(animated: true) {() -> Void in }
        }
    }

}



