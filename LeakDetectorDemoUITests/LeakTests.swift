//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import LeakDetectorCombine
import LeakDetectorRxSwift
import XCTest

class LeakTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

    }
    
    func testLeakByDelegate() throws {
        assert(
            testCase: "Leak by delegate",
            subcase: "Leak - 1",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 0.5
        )
    }

    func testLeakByObservables() throws {
        assert(
            testCase: "Leak by RxSwift Observables",
            subcase: "Leak - 1",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 0.5
        )
    }
    
    func testLeakByCombine() throws {
        assert(
            testCase: "Leak by Combine",
            subcase: "Leak - Combine assign",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 0.5
        )
    }
    
    func testLeakViewControllerUsingExpectViewControllerDellocated() {
        assert(
            testCase: "Assert Leak by ViewController",
            subcase: "Leak View Controller",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 0.5
        )
    }
    
    func testLeakBySimpleClosure() throws {
        assert(
            testCase: "Leak by Closure",
            subcase: "Leak by Simple Closure",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 0.5
        )
    }
    
    func testLeakBySimplelosures() throws {
        assert(
            testCase: "Leak by Closure",
            subcase: "Leak by Simple Closure",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 0.5
        )
    }

    func testLeakByRxSwiftDetectedByRxSwift() throws {
        assert(
            testCase: "LeakDetectorRxSwift",
            subcase: "Leak - 1",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 1
        )
    }

    private func assert(testCase: String, subcase: String? = nil, exitAction: () -> Void, timeout: TimeInterval = .deallocationExpectation + 0.5) {
        app.tables.staticTexts[testCase].tap()
        
        if let subcase = subcase {
            app.tables.staticTexts[subcase].tap()
        }
        exitAction()
        
        let alert = app.alerts["LEAK"]
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)

    }
}
