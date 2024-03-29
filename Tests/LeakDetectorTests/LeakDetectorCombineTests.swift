//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import XCTest
@testable import LeakDetectorCombine

@available(iOS 13, *)
final class LeakDetectorCombineTests: XCTestCase {
    
    private let waitingTime: TimeInterval = 1.0
    private var cancellables = Set<AnyCancellable>()
    private var parent: Parent?
    
    override func setUp() {
        super.setUp()
        LeakDetector.instance.isEnabled = false
        
        parent = Parent()
    }
    
    override func tearDown() {
        super.tearDown()
        
        LeakDetector.instance.reset()
        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables.removeAll()
        parent = nil
    }
    
    func testDetectNoLeak() {
        let expectation = self.expectation(description: "No Leak is reported")
        parent?.makeNonLeakingChild()
        
        LeakDetector.instance.status
            .dropFirst()
            .sink { status in
                if status == .didComplete {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        LeakDetector.instance.expectDeallocate(object: parent!)
            .sink {}
            .store(in: &cancellables)
        parent = nil
        
        wait(for: [expectation], timeout: .deallocationExpectation + waitingTime)
        
        XCTAssertNil(LeakDetector.instance.isLeaked.value)
    }
    
    func testDetectLeak() {
        let expectation = self.expectation(description: "Leak is reported")
        parent?.makeLeakingChild()
                
        LeakDetector.instance.status
            .dropFirst()
            .sink { status in
                if status == .didComplete {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        LeakDetector.instance.expectDeallocate(object: parent!)
            .sink {}
            .store(in: &cancellables)
        parent = nil

        wait(for: [expectation], timeout: .deallocationExpectation + waitingTime)
        
        XCTAssertNotNil(LeakDetector.instance.isLeaked.value)
    }
}

private class Parent {
    
    var child: Child?
    
    init() {}

    func makeNonLeakingChild() {
        child = NonLeakingChild(parent: self)
    }

    func makeLeakingChild() {
        child = LeakingChild(parent: self)
    }
}

private class Child {}

private class NonLeakingChild: Child {
    weak var parent: Parent?
    
    init(parent: Parent) {
        self.parent = parent
    }
}

private class LeakingChild: Child {
    var parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
}
