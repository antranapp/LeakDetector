//
// Copyright © 2021 An Tran. All rights reserved.
//

import XCTest
@testable import LeakDetectorRxSwift
import RxSwift

final class LeakDetectorRxSwiftTests: XCTestCase {

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

        wait(for: [expectation], timeout: .deallocationExpectation + 0.1)

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

        wait(for: [expectation], timeout: .deallocationExpectation + 0.1)

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
