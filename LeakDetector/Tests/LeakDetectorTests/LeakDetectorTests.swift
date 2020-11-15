//
//  Copyright © 2020 An Tran. All rights reserved.
//


import Combine
import XCTest
@testable import LeakDetector

final class LeakDetectorTests: XCTestCase {
    
    private var cancellable: AnyCancellable?
    private var parent: Parent?
    
    override func setUp() {
        super.setUp()
        LeakDetector.isEnabled = false
        
        parent = Parent()
    }
    
    override func tearDown() {
        super.tearDown()
        
        LeakDetector.instance.reset()
        cancellable?.cancel()
        cancellable = nil
    }
    
    func testDetectNoLeak() {
        let expectation = self.expectation(description: "No Leak is reported")
        parent?.makeNonLeakingChild()
        
        cancellable = LeakDetector.instance.status
            .dropFirst()
            .sink { status in
                if status == .didComplete {
                    expectation.fulfill()
                }
            }
        
        LeakDetector.instance.expectDeallocate(object: parent!)
        parent = nil
        
        wait(for: [expectation], timeout: LeakDefaultExpectationTime.deallocation + 0.1)
        
        XCTAssertFalse(LeakDetector.isLeaked.value)
    }
    
    func testDetectLeak() {
        let expectation = self.expectation(description: "Leak is reported")
        parent?.makeLeakingChild()
                
        cancellable = LeakDetector.instance.status
            .dropFirst()
            .sink { status in
                if status == .didComplete {
                    expectation.fulfill()
                }
            }
        
        LeakDetector.instance.expectDeallocate(object: parent!)
        parent = nil

        wait(for: [expectation], timeout: LeakDefaultExpectationTime.deallocation + 0.1)
        
        XCTAssertTrue(LeakDetector.isLeaked.value)
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
