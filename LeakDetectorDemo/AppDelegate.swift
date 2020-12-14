//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var cancellables = Set<AnyCancellable>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if ProcessInfo().arguments.contains("testMode") {
            print("The app is running in TestMode")
            // set to `false` so that the app doesn't crash.
            LeakDetector.instance.isEnabled = false
        } else {
            // set to `true` so that the app should crash when leaks occur.
            LeakDetector.instance.isEnabled = false
        }
        
        LeakDetector.instance.status
            .sink(
                receiveValue: { status in
                    print(status)
                }
            )
            .store(in: &cancellables)
        
        LeakDetector.instance.isLeaked
            .sink { message in
                if let message = message {
                    self.showLeakAlert(message)
                }
            }
            .store(in: &cancellables)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func showLeakAlert(_ message: String) {
        let alertController = UIAlertController(title: "LEAK", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(action)
        UIApplication.shared.topMostViewController()?.present(alertController, animated: true, completion: nil)
    }
}
