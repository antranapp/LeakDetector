//
// Copyright © 2020 An Tran. All rights reserved.
//

import Foundation
import LeakDetector
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
            exitAction: {
                self.app.navigationBars["Delegate"].buttons["Leak Detector Demo"].tap()
            }
        )
    }

    func testLeakByObservables() throws {
        assert(
            testCase: "Leak by observables",
            exitAction: {
                self.app.navigationBars["Observables"].buttons["Leak Detector Demo"].tap()
            }
        )
    }
    
    func testLeakByCombine() throws {
        assert(
            testCase: "Leak by assign in Combine",
            exitAction: {
                self.app.navigationBars["Combine Assign"].buttons["Leak Detector Demo"].tap()
            }
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
    
    func testLeakByNestedClosures() throws {
        assert(
            testCase: "Leak by Closure",
            subcase: "Leak by Nested Closures",
            exitAction: {
                app.buttons["Go Back"].tap()
            },
            timeout: .viewDisappearExpectation + 0.5
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
