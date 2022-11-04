//
// Copyright © 2021 An Tran. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

@available(iOS 13.0, *)

public extension Timer {
    /// Execute the given logic after the given delay assuming the given maximum frame duration.
    ///
    /// This allows excluding the time elapsed due to breakpoint pauses.
    ///
    /// - note: The logic closure is not guaranteed to be performed exactly after the given delay. It may be performed
    ///   later if the actual frame duration exceeds the given maximum frame duration.
    ///
    /// - parameter delay: The delay to perform the logic, excluding any potential elapsed time due to breakpoint
    ///   pauses.
    /// - parameter maxFrameDuration: The maximum duration a single frame should take. Defaults to 33ms.
    /// - returns: `Publishers.First` that outputs after delay.
    static func execute(
        withDelay delay: TimeInterval,
        maxFrameDuration: Int = 33,
        runloop: RunLoop = RunLoop.main
    ) -> Publishers.First<AnyPublisher<Void, Never>> {
        let period: TimeInterval = .milliseconds(maxFrameDuration / 3)
        var lastRunLoopTime = Date().timeIntervalSinceReferenceDate
        var properFrameTime = 0.0
        return publish(every: period, on: runloop, in: .common)
            .autoconnect()
            .filter { _ in
                let currentTime = Date().timeIntervalSinceReferenceDate
                let trueElapsedTime = currentTime - lastRunLoopTime
                lastRunLoopTime = currentTime

                // If we did drop frame, we under-count the frame duration, which is fine. It
                // just means the logic is performed slightly later.
                let boundedElapsedTime = min(trueElapsedTime, Double(maxFrameDuration) / 1000)
                properFrameTime += boundedElapsedTime
                return properFrameTime > delay
            }
            .map { _ in () }
            .eraseToAnyPublisher()
            .first()
    }
}

extension TimeInterval {
    static func milliseconds(_ milliseconds: Int) -> TimeInterval {
        TimeInterval(milliseconds) / 1000
    }
}
