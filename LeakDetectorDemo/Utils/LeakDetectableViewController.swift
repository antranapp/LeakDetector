//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

class LeakDetectableViewController: UIViewController {
    
    var leakSubscription: AnyCancellable?
    
    func executeLeakDetector(for object: AnyObject) {
        leakSubscription = LeakDetector.instance.expectDeallocate(object: object).sink {}
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscription = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController).sink {}
    }
}

class LeakDetectableTableViewController: UITableViewController {
    
    weak var weakViewController: UIViewController?
    var leakSubscription: AnyCancellable?

    func executeLeakDetector(for object: AnyObject) {
        leakSubscription = LeakDetector.instance.expectDeallocate(object: object).sink {}
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscription = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController).sink {}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let weakViewController = weakViewController {
            executeLeakDetector(for: weakViewController)
            self.weakViewController = nil
        }
    }
}
