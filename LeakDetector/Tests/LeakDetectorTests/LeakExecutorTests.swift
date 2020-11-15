//
//  Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import XCTest
@testable import LeakDetector

final class LeakExecutorTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    @Published private var value: Bool = false
    
    func testLoginIsCalledOnTime() {
        
        let expectation = self.expectation(description: "Login is called")
        let delay = 0.1
        
        $value
            .dropFirst()
            .sink { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        LeakExecutor.execute(withDelay: delay) {
            self.value = true
        }
        .sink {}
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: delay + 0.1)
    }
}
