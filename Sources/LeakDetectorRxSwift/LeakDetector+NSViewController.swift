//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import RxSwift
#if canImport(Cocoa)
import Cocoa

public extension LeakDetector {

    /// Sets up an expectation for the given view controller to disappear within the given time.
    ///
    /// - parameter viewController: The `UIViewController` expected to disappear.
    /// - parameter inTime: The time the given view controller is expected to disappear.
    /// - returns: The handle that can be used to cancel the expectation.
    @discardableResult
    func expectViewControllerDellocated(
        viewController: NSViewController,
        inTime time: TimeInterval = .viewDisappearExpectation
    ) -> LeakDetectionHandle {
        expectationCount.accept(expectationCount.value + 1)

        let handle = LeakDetectionHandleImpl {
            self.expectationCount.accept(self.expectationCount.value - 1)
        }

        Timer.execute(withDelay: time) { [weak viewController] in
            // Retain the handle so we can check for the cancelled status. Also cannot use the cancellable
            // concurrency API since the returned handle must be retained to ensure closure is executed.
            if let viewController = viewController, !handle.cancelled {
                // Test if view has been dissapeared, but not deallocated -> indicating the view controller
                // has been leaked
                let viewDissapearedButNotDeallocated = viewController.isViewLoaded && viewController.view.window == nil
                let message = "\(viewController) apparently has leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"

                if self.isEnabled {
                    assert(!viewDissapearedButNotDeallocated, message)
                } else if viewDissapearedButNotDeallocated {
                    print("Leak detection is disabled. This should only be used for debugging purposes.")
                    print("\(message)")
                    self.isLeaked.accept(message)
                }
            }

            self.expectationCount.accept(self.expectationCount.value - 1)
        }

        return handle
    }

}
#endif
