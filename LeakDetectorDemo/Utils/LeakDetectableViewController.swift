//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

class LeakDetectableViewController: UIViewController {
    
    var leakSubscribtion: AnyCancellable?
    
    func executeLeakDetector(for object: AnyObject) {
        leakSubscribtion = LeakDetector.instance.expectDeallocate(object: object).sink {}
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscribtion = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController).sink {}
    }
}

class LeakDetectableTableViewController: UITableViewController {
    
    var leakSubscribtion: AnyCancellable?
    
    func executeLeakDetector(for object: AnyObject) {
        leakSubscribtion = LeakDetector.instance.expectDeallocate(object: object).sink {}
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscribtion = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController).sink {}
    }
}
