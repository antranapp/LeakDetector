//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import LeakDetectorCombine
import UIKit

class LeakDetectableViewController: UIViewController {
    
    var leakSubscription: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func executeLeakDetector(for object: AnyObject) {
        leakSubscription?.cancel()
        leakSubscription = nil
        leakSubscription = LeakDetector.instance.expectDeallocate(object: object).sink {}
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscription?.cancel()
        leakSubscription = nil
        leakSubscription = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController).sink {}
    }
}

class LeakDetectableTableViewController: UITableViewController {
    
    weak var weakViewController: UIViewController?
    var leakSubscription: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func executeLeakDetector(for object: AnyObject) {
        leakSubscription?.cancel()
        leakSubscription = nil
        leakSubscription = LeakDetector.instance.expectDeallocate(object: object).sink {}
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscription?.cancel()
        leakSubscription = nil
        leakSubscription = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController).sink {}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let weakViewController = weakViewController {
            executeLeakDetector(for: weakViewController)
            self.weakViewController = nil
        }
    }
}
