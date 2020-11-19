//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

protocol LeakDelegate: AnyObject {
    var viewController: UIViewController { get }
}

class DelegateViewController: LeakDetectableViewController {
        
    private var cancellable: AnyCancellable?
    
//    weak private var delegate: LeakDelegate!
    private var delegate: LeakDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
    }
    
    // Expecting DelegateViewController & LeakDelegate should be deallocated after poping from Navigation controller
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            super.executeLeakDetector(for: delegate)
        }
    }
}

extension DelegateViewController: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}
