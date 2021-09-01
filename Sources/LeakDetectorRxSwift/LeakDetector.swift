//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
@_exported import LeakDetectorCore
import RxSwift
import RxCocoa

public enum LeakDefaultExpectationTime {
    public static let deallocation: TimeInterval = 1
    public static let viewDisappear: TimeInterval = 5
}

public enum LeakDetectionStatus {
    case inProgress, didComplete
}

public protocol LeakDetectionHandle {
    func cancel()
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
    public var status: Observable<LeakDetectionStatus> {
        expectationCount
            .asObservable()
            .map { expectationCount in
                expectationCount > 0 ? LeakDetectionStatus.inProgress : LeakDetectionStatus.didComplete
            }
            .distinctUntilChanged()
    }

    /// Sets up an expectation for the given object to be deallocated within the given time.
    ///
    /// - parameter object: The object to track for deallocation.
    /// - parameter inTime: The time the given object is expected to be deallocated within.
    /// - returns: The handle that can be used to cancel the expectation.
    @discardableResult
    public func expectDeallocate(
        object: AnyObject,
        inTime time: TimeInterval = LeakDefaultExpectationTime.deallocation
    ) -> LeakDetectionHandle {
        expectationCount.accept(expectationCount.value + 1)

        let objectDescription = String(describing: object)
        let objectId = String(ObjectIdentifier(object).hashValue) as NSString
        trackingObjects.setObject(object, forKey: objectId)

        let handle = LeakDetectionHandleImpl {
            self.expectationCount.accept(self.expectationCount.value - 1)
        }

        Timer.execute(withDelay: time) {
            // Retain the handle so we can check for the cancelled status. Also cannot use the cancellable
            // concurrency API since the returned handle must be retained to ensure closure is executed.
            if !handle.cancelled {
                let didDeallocate = (self.trackingObjects.object(forKey: objectId) == nil)
                let message = "<\(objectDescription): \(objectId)> has leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"

                if self.isEnabled {
                    assert(didDeallocate, message)
                } else if !didDeallocate {
                    print("Leak detection is disabled. This should only be used for debugging purposes.")
                    print("\(message)")
                    self.isLeaked.on(.next(message))
                }
            }

            self.expectationCount.accept(self.expectationCount.value - 1)
        }

        return handle
    }

    // MARK: - Internal Interface

    /// Enable leak detector. Default is false.
    ///
    /// We should enable leak detector in Debug mode only.
    public var isEnabled: Bool = false

    public let isLeaked = BehaviorSubject<String?>(value: nil)

    /// Enable leak detector for core components such as RadixViewController, ServiceBasedViewModel, ... Default is false.
    ///
    /// We should enable in Debug mode only.
    public static var isCoreComponentsEnabled = false

    #if DEBUG
    /// Reset the state of Leak Detector, internal for UI test only.
    func reset() {
        trackingObjects.removeAllObjects()
        expectationCount.accept(0)
    }
    #endif

    // MARK: - Private Interface

    let trackingObjects = NSMapTable<AnyObject, AnyObject>.strongToWeakObjects()
    let expectationCount = BehaviorRelay<Int>(value: 0)

    private init() {}
}

final class LeakDetectionHandleImpl: LeakDetectionHandle {
    var cancelled: Bool {
        cancelledRelay.value
    }

    let cancelledRelay = BehaviorRelay<Bool>(value: false)
    let cancelClosure: (() -> Void)?

    init(cancelClosure: (() -> Void)? = nil) {
        self.cancelClosure = cancelClosure
    }

    func cancel() {
        cancelledRelay.accept(true)
        cancelClosure?()
    }
}
