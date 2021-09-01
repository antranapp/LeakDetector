//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import LeakDetectorCombine
import LeakDetectorRxSwift
import RxSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var cancellables = Set<AnyCancellable>()
    var bag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if ProcessInfo().arguments.contains("testMode") {
            print("The app is running in TestMode")
            // set to `false` so that the app doesn't crash.
            LeakDetectorCombine.LeakDetector.instance.isEnabled = false
            LeakDetectorRxSwift.LeakDetector.instance.isEnabled = false
        } else {
            // set to `true` so that the app should crash when leaks occur.
            LeakDetectorCombine.LeakDetector.instance.isEnabled = false
            LeakDetectorRxSwift.LeakDetector.instance.isEnabled = false
        }

        // Combine
        
        LeakDetectorCombine.LeakDetector.instance.status
            .sink(
                receiveValue: { status in
                    print("LeakDetectorCombine \(status)")
                }
            )
            .store(in: &cancellables)
        
        LeakDetectorCombine.LeakDetector.instance.isLeaked
            .sink { [weak self] message in
                if let message = message {
                    self?.showLeakAlert(message)
                }
            }
            .store(in: &cancellables)

        // RxSwift

        LeakDetectorRxSwift.LeakDetector.instance.status
            .subscribe(
                onNext: { status in
                    print("LeakDetectorRxSwift \(status)")
                }
            )
            .disposed(by: bag)

        LeakDetectorRxSwift.LeakDetector.instance.isLeaked
            .subscribe(
                onNext: { [weak self] message in
                    if let message = message {
                        self?.showLeakAlert(message)
                    }
                }
            )
            .disposed(by: bag)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    private func showLeakAlert(_ message: String) {
        let alertController = UIAlertController(title: "LEAK", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(action)
        UIApplication.shared.topMostViewController()?.present(alertController, animated: true, completion: nil)
    }
}
