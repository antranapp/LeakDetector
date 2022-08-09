//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import XCTest
@testable import LeakDetectorCore

@available(iOS 13, *)
final class TimerTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func testTimerEmittedOnTime() {
        let expectation = self.expectation(description: "Timer is emitted")
        let delay = 0.1
                
        Timer
            .execute(withDelay: delay)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: delay + 0.1)
    }
}
