//
//  File.swift
//  JioMusic
//
//  Created by Atinderpal Singh on 03/04/18.
//  Copyright © 2018 Reliance Jio Infocomm Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func topViewController(controller: UIViewController? =
        UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            navigationController.visibleViewController?.navigationItem.backBarButtonItem =
                UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController.navigationBar.isTranslucent = false
            return topViewController(controller: navigationController.visibleViewController)
        }

        if let tabController = controller as? UITabBarController {
            if let selected = tabController.viewControllers?[tabController.selectedIndex] {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
