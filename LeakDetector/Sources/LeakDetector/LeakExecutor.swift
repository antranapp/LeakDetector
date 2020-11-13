//
//  LeakExecutor.swift
//  LeakDetector-iOS
//
//  Created by Steve Dao on 23/8/20.
//  Copyright © 2020 duyquang91. All rights reserved.
//

import Foundation
import Combine

public class LeakExecutor {
    
    var timerCancellable: Cancellable?
    var cancellable: AnyCancellable?
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
    public static func execute(withDelay delay: TimeInterval, maxFrameDuration: Int = 33, logic: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: logic)
//        let period = Double(maxFrameDuration) / 3 / 1000
//        var lastRunLoopTime = Date().timeIntervalSinceReferenceDate
//        var properFrameTime = 0.0
//        var didExecute = false
//
//        let innerTimer = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)
//
//        timerCancellable = innerTimer.connect()
//        cancellable = innerTimer
////            .filter { _ -> Bool in
////                !didExecute
////            }
//            .print("timer", to: nil)
//            .flatMap { _ -> AnyPublisher<Void, Never> in
////                let currentTime = Date().timeIntervalSinceReferenceDate
////                let trueElapsedTime = currentTime - lastRunLoopTime
////                lastRunLoopTime = currentTime
////
////                // If we did drop frame, we under-count the frame duration, which is fine. It
////                // just means the logic is performed slightly later.
////                let boundedElapsedTime = min(trueElapsedTime, Double(maxFrameDuration) / 1_000)
////                properFrameTime += boundedElapsedTime
////                if properFrameTime > delay {
////                    didExecute = true
////
////                    logic()
////                }
//                return Just(()).eraseToAnyPublisher()
//            }
//            .sink(receiveValue: { _ in })
    }
    
    deinit {
        timerCancellable?.cancel()
        cancellable?.cancel()
    }
}
