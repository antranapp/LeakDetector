//
// Copyright © 2021 An Tran. All rights reserved.
//

import RxSwift
import XCTest
@testable import LeakDetectorRxSwift

final class LeakDetectorRxSwiftTests: XCTestCase {
    
    private let waitingTime: TimeInterval = 1.0
    private var bag: DisposeBag! = DisposeBag()
    private var parent: Parent?
    
    override func setUp() {
        super.setUp()
        LeakDetector.instance.isEnabled = false
        
        parent = Parent()
    }
    
    override func tearDown() {
        super.tearDown()
        LeakDetector.instance.reset()
        bag = nil
    }
    
    func testDetectNoLeak() throws {
        let expectation = self.expectation(description: "No Leak is reported")
        parent?.makeNonLeakingChild()
        
        LeakDetector.instance.status
            .skip(1)
            .subscribe(
                onNext: { status in
                    if status == .didComplete {
                        expectation.fulfill()
                    }
                }
            )
            .disposed(by: bag)
        
        LeakDetector.instance.expectDeallocate(object: parent!)
        
        parent = nil
        
        wait(for: [expectation], timeout: .deallocationExpectation + waitingTime)
        
        XCTAssertNil(LeakDetector.instance.isLeaked.value)
    }
    
    func testDetectLeak() {
        let expectation = self.expectation(description: "Leak is reported")
        parent?.makeLeakingChild()
        
        LeakDetector.instance.status
            .skip(1)
            .subscribe(
                onNext: { status in
                    if status == .didComplete {
                        expectation.fulfill()
                    }
                }
            )
            .disposed(by: bag)
        
        LeakDetector.instance.expectDeallocate(object: parent!)
        parent = nil
        
        wait(for: [expectation], timeout: .deallocationExpectation + waitingTime)
        
        XCTAssertNotNil(LeakDetector.instance.isLeaked.value)
    }
    
    func testExpectDeallocateObject() {
        weak var object: AnyObject?
        autoreleasepool {
            let testObject = TestNSObject()
            object = testObject
            
            LeakDetector.instance.expectDeallocate(object: testObject, inTime: 0.0)
            XCTAssertTrue(LeakDetector.instance.trackingObjects.asArray.first === object)
        }
        
        XCTAssertEqual(LeakDetector.instance.expectationCount.value, 1)
        XCTAssertTrue(LeakDetector.instance.trackingObjects.asArray.isEmpty)
        XCTAssertNil(object)
        
        let e = expectation(description: "Still expectations in leak detector")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(LeakDetector.instance.expectationCount.value, 0)
            e.fulfill()
        }
        
        wait(for: [e], timeout: 1.0)
    }
    
    func testExpectObjectsDealloc() {
        var objects: WeakSequenceOf<AnyObject> = []
        autoreleasepool {
            let testObjects = [TestObject(), TestObject(), TestObject()]
            objects = WeakSequenceOf(testObjects)

            LeakDetector.instance.expectDeallocate(objects: objects, inTime: 0.0)
            XCTAssertEqual(LeakDetector.instance.trackingObjects.asArray.count, 3)
            XCTAssertEqual(objects.asArray.count, 3)
            XCTAssertEqual(testObjects.count, 3)
        }
        
        XCTAssertEqual(LeakDetector.instance.expectationCount.value, 1)
        XCTAssertTrue(LeakDetector.instance.trackingObjects.asArray.isEmpty)
        XCTAssertEqual(objects.asArray.count, 0)

        let e = expectation(description: "Still expectations in leak detector")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(LeakDetector.instance.expectationCount.value, 0)
            e.fulfill()
        }

        wait(for: [e], timeout: waitingTime)
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

final class TestObject {}
final class TestNSObject: NSObject {}
