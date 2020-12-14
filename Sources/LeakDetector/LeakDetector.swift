//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import Foundation
import UIKit

/// The default time values used for leak detection expectations.
public extension TimeInterval {
    /// The object deallocation time.
    static let deallocationExpectation: TimeInterval = 1.0

    /// The view disappear time.
    static let viewDisappearExpectation: TimeInterval = 3.0
}

public enum LeakDetectionStatus {
    case inProgress, didComplete
}

/// An expectation based leak detector, that allows an object's owner to set an expectation that an owned object to be
/// deallocated within a time frame.
///
/// A `Router` that owns an `Interactor` might for example expect its `Interactor` be deallocated when the `Router`
/// itself is deallocated. If the interactor does not deallocate in time, a runtime assert is triggered, along with
/// critical logging.
public class LeakDetector {
    
    /// The singleton instance.
    public static let instance = LeakDetector()
    
    /// The status of leak detection.
    ///
    /// The status changes between InProgress and DidComplete as units register for new detections, cancel existing
    /// detections, and existing detections complete.
    public var status: AnyPublisher<LeakDetectionStatus, Never> {
        $expectationCount
            .map { expectationCount in
                expectationCount > 0 ? LeakDetectionStatus.inProgress : LeakDetectionStatus.didComplete
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Sets up an expectation for the given object to be deallocated within the given time.
    ///
    /// - parameter object: The object to track for deallocation.
    /// - parameter inTime: The time the given object is expected to be deallocated within.
    /// - returns: `AnyPublisher` that can be used to cancel the expectation.
    public func expectDeallocate(object: AnyObject, inTime time: TimeInterval = .deallocationExpectation) -> AnyPublisher<Void, Never> {
        
        let objectDescription = String(describing: object)
        let objectId = String(ObjectIdentifier(object).hashValue) as NSString

        return Timer
            .execute(withDelay: time)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak object] _ in
                    self.expectationCount += 1
                    if let object = object {
                        self.trackingObjects.setObject(object, forKey: objectId)
                    }
                },
                receiveOutput: { _ in
                    let didDeallocate = (self.trackingObjects.object(forKey: objectId) == nil)
                    let message = "<\(objectDescription): \(objectId)> has leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"

                    if LeakDetector.instance.isEnabled {
                        assert(didDeallocate, message)
                    } else if !didDeallocate {
                        print("Leak detection is disabled. This should only be used for debugging purposes.")
                        print("\(message)")
                        LeakDetector.instance.isLeaked.send(message)
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

    /// Sets up an expectation for the given view controller to be deallocated within the given time.
    ///
    /// - parameter viewController: The `UIViewController` expected to disappear.
    /// - parameter inTime: The time the given view controller is expected to disappear.
    /// - returns: `AnyPublisher` that can be used to cancel the expectation.
    @discardableResult
    public func expectViewControllerDellocated(viewController: UIViewController, inTime time: TimeInterval = .viewDisappearExpectation) -> AnyPublisher<Void, Never> {
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
                        let message = "\(viewController) appearance has leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"

                        if LeakDetector.instance.isEnabled {
                            assert(viewDidDisappear, message)
                        } else if !viewDidDisappear {
                            print("Leak detection is disabled. This should only be used for debugging purposes.")
                            print("\(message)")
                            LeakDetector.instance.isLeaked.send(message)
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

    // MARK: - Internal Interface

    /// Enable leak detector. Default is false.
    ///
    /// We should enable leak detector in Debug mode only.
    public var isEnabled: Bool = false

    public var isLeaked = CurrentValueSubject<String?, Never>(nil)

    #if DEBUG
    /// Reset the state of Leak Detector, internal for UI test only.
    func reset() {
        trackingObjects.removeAllObjects()
        expectationCount = 0
        LeakDetector.instance.isLeaked.send(nil)
    }
    #endif

    // MARK: - Private Interface

    private let trackingObjects = NSMapTable<AnyObject, AnyObject>.strongToWeakObjects()
    @Published private var expectationCount: Int = 0

    private init() {}
}
