//
//  Copyright © 2020 Steve Dao. All rights reserved.
//  Copyright © 2020 An Tran. All rights reserved.
//

import UIKit
import LeakDetector

protocol LeakDelegate: class {
    var viewController: UIViewController { get }
}

class DelegateViewController: UIViewController {
        
//    weak var delegate: LeakDelegate!
    var delegate: LeakDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
    }
    
    // Expecting DelegateViewController & LeakDelegate should be deallocated after poping from Navigation controller
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            LeakDetector.instance.expectDeallocate(object: delegate)
        }
    }
}

extension DelegateViewController: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}
