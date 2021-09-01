//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import Foundation
#if canImport(UIKit)
import UIKit

public extension LeakDetector {

    /// Sets up an expectation for the given view controller to be deallocated within the given time.
    ///
    /// - parameter viewController: The `UIViewController` expected to disappear.
    /// - parameter inTime: The time the given view controller is expected to disappear.
    /// - returns: `AnyPublisher` that can be used to cancel the expectation.
    @discardableResult
    func expectViewControllerDellocated(viewController: UIViewController, inTime time: TimeInterval = .viewDisappearExpectation) -> AnyPublisher<Void, Never> {
        Timer
            .execute(withDelay: time)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { _ in
                    self.expectationCount += 1
                },
                receiveOutput: { [weak viewController] in
                    if let viewController = viewController {
                        let viewDidDisappear = (!viewController.isViewLoaded && viewController.view.window == nil)
                        let message = "\(viewController) apparently has leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"

                        if self.isEnabled {
                            assert(viewDidDisappear, message)
                        } else if !viewDidDisappear {
                            print("Leak detection is disabled. This should only be used for debugging purposes.")
                            print("\(message)")
                            self.isLeaked.send(message)
                        }
                    }
                },
                receiveCompletion: { _ in
                    self.expectationCount -= 1
                },
                receiveCancel: {
                    self.expectationCount -= 1
                }
            )
            .subscribe(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
#endif
