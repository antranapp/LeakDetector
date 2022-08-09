//
// Copyright © 2021 An Tran. All rights reserved.
//

import UIKit

// Taken from: https://github.com/chauvincent/LeakyApp-iOS
final class NotificationCenterViewController: ChildViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Leak - Notification Center"
        
        addObservers()
    }

    // MARK: - Add Observers

    private func addObservers() {
        // There is a memory leak here because passing in a function as a closure holds a strong reference to `self` by default!!
        // This will cause the __NSObserver object to hold a strong reference to the closure and as a result hold a strong reference to this controller. `deinit` will never be called and we will leak an instance of this controller everytime this view controller is loaded.
        NotificationCenter.default.addObserver(forName: .SomethingToObserveNotification, object: nil, queue: .main, using: handleNotification)

        // To Fix: add [weak self] or [unowned self] in the capture list. Do not pass in the function as a closure.
        // NotificationCenter.default.addObserver(forName: .SomethingToObserveNotification, object: nil, queue: .main) { [weak self] notification in
        //     self?.handleNotification(notification)
        // }
    }

    private func handleNotification(_ notification: Notification) {
        print(notification)
    }

}

private extension Notification.Name {
    static let SomethingToObserveNotification = Notification.Name(rawValue: "SomethingToObserverNotification")
}
