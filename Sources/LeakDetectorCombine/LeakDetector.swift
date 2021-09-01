//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import Foundation
@_exported import LeakDetectorCore

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

    // MARK: - Private Interface

    private(set) var trackingObjects = WeakSet<AnyObject>()
    @Published var expectationCount: Int = 0 {
        didSet {
            if expectationCount == 0 {
                // Clear strong key references.
                trackingObjects.removeAll()
            }
        }
    }

    private init() {}

    /// Sets up an expectation for the given objects to be deallocated within the given time.
    ///
    /// - parameter objects: The weak set of objects to track for deallocation.
    /// - parameter inTime: The time the given object is expected to be deallocated within.
    /// - returns: `Publishers.First` that outputs after delay.
    public func expectDeallocate<Element>(objects: WeakSet<Element>, inTime time: TimeInterval = .deallocationExpectation) -> AnyPublisher<Void, Never> {
        guard !objects.isEmpty else { return Empty().eraseToAnyPublisher() }
        return Timer
            .execute(withDelay: time)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { _ in
                self.trackingObjects.formUnion(objects)
                self.expectationCount += 1
            }, receiveOutput: {
                if !objects.isEmpty {
                    let message = "\(objects) have leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"
                    if self.isEnabled {
                        assertionFailure(message)
                    } else {
                        print("Leak detection is disabled. This should only be used for debugging purposes.")
                        print(message)
                        self.isLeaked.send(message)
                    }
                }
            }, receiveCompletion: { _ in
                self.expectationCount -= 1
            }, receiveCancel: {
                self.expectationCount -= 1
            })
            .subscribe(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Sets up an expectation for the given object to be deallocated within the given time.
    ///
    /// - parameter object: The object to track for deallocation.
    /// - parameter inTime: The time the given object is expected to be deallocated within.
    /// - returns: `AnyPublisher` that can be used to cancel the expectation.
    public func expectDeallocate(object: AnyObject, inTime time: TimeInterval = .deallocationExpectation) -> AnyPublisher<Void, Never> {
        Timer
            .execute(withDelay: time)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak object] _ in
                    self.expectationCount += 1
                    if let object = object {
                        self.trackingObjects.insert(object)
                    }
                },
                receiveOutput: { [weak object] in
                    if let object = object {
                        let message = "<\(memoryAddressDescription(for: object))> has leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"

                        if self.isEnabled {
                            assertionFailure(message)
                        } else {
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

    // MARK: - Internal Interface

    /// Enable leak detector. Default is false.
    ///
    /// We should enable leak detector in Debug mode only.
    public var isEnabled: Bool = false

    public var isLeaked = CurrentValueSubject<String?, Never>(nil)

    #if DEBUG
    /// Reset the state of Leak Detector, internal for UI test only.
    func reset() {
        trackingObjects.removeAll()
        expectationCount = 0
        isLeaked.send(nil)
    }
    #endif
}
