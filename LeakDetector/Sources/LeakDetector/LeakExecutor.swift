//
//  Copyright © UBER. All rights reserved.
//  Copyright © 2020 duyquang91. All rights reserved.
//  Copyright © 2020 An Tran. All rights reserved.
//

import Foundation
import Combine

public class LeakExecutor {
    
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
    /// - parameter logic: The closure logic to perform.
    public static func execute(withDelay delay: TimeInterval, maxFrameDuration: Int = 33, logic: @escaping () -> Void) -> AnyPublisher<Void, Never> {
        let period = Double(maxFrameDuration) / 3 / 1_000
        var lastRunLoopTime = Date().timeIntervalSinceReferenceDate
        var properFrameTime = 0.0
        var didExecute = false

        return Timer.TimerPublisher(interval: period, runLoop: .main, mode: .default).autoconnect()
            .filter { _ -> Bool in
                !didExecute
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                let currentTime = Date().timeIntervalSinceReferenceDate
                let trueElapsedTime = currentTime - lastRunLoopTime
                lastRunLoopTime = currentTime

                // If we did drop frame, we under-count the frame duration, which is fine. It
                // just means the logic is performed slightly later.
                let boundedElapsedTime = min(trueElapsedTime, Double(maxFrameDuration) / 1_000)
                properFrameTime += boundedElapsedTime
                if properFrameTime > delay {
                    didExecute = true

                    logic()
                }
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
