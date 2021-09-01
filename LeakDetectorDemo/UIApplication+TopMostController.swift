//
// Copyright © 2021 An Tran. All rights reserved.
//

import UIKit

// https://gist.github.com/db0company/369bfa43cb84b145dfd8

extension UIViewController {
    func topMostViewController() -> UIViewController? {
        if presentedViewController == nil {
            return self
        }
        if let navigation = presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController()
        }
        if let tab = presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        UIApplication.shared.windows.filter(\.isKeyWindow).first?.rootViewController?.topMostViewController()
    }
}
