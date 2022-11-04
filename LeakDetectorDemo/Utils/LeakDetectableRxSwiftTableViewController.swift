//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import LeakDetectorRxSwift
import RxSwift
import UIKit

class LeakDetectableRxSwiftTableViewController: UITableViewController {

    // Assign this weakViewController to a child view controller
    // When we navigate to this TableViewController, we will
    // use this weak reference to check if the child view controller
    // is deallocated correctly.
    weak var weakViewController: UIViewController?
    private var leakSubscription: LeakDetectionHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func executeLeakDetector(for object: AnyObject) {
        leakSubscription?.cancel()
        leakSubscription = nil
        leakSubscription = LeakDetector.instance.expectDeallocate(object: object)
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscription?.cancel()
        leakSubscription = nil
        leakSubscription = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let weakViewController = weakViewController {
            executeLeakDetector(for: weakViewController)
            self.weakViewController = nil
        }
    }
}
