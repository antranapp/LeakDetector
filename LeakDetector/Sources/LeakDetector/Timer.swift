//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import Foundation

public extension Timer {

    /// Emite a Void signal after the given delay assuming the given maximum frame duration.
    ///
    /// This allows excluding the time elapsed due to breakpoint pauses.
    ///
    /// - note: The Publisher is not guaranteed to be emitted exactly after the given delay. It may be emitted
    ///   later if the actual frame duration exceeds the given maximum frame duration.
    ///
    /// - parameter delay: The delay to perform the logic, excluding any potential elapsed time due to breakpoint
    ///   pauses.
    /// - parameter maxFrameDuration: The maximum duration a single frame should take. Defaults to 33ms.
    /// - returns: `AnyPublisher` that outputs after delay.
    static func execute(withDelay delay: TimeInterval, maxFrameDuration: Int = 33, runloop: RunLoop = RunLoop.main) -> AnyPublisher<Void, Never> {
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
            .first()
            .eraseToAnyPublisher()
    }
}

extension TimeInterval {
    static func milliseconds(_ milliseconds: Int) -> TimeInterval {
        TimeInterval(milliseconds) / 1000
    }
}
