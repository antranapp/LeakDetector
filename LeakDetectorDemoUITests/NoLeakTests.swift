//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import LeakDetectorCombine
import LeakDetectorRxSwift
import XCTest

final class NoLeakTests: XCTestCase {

    var app: XCUIApplication!

    static let bufferInternal: TimeInterval = 4
    
    override func setUp() {
        super.setUp()
        
        app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

    }
    
    func testNoLeakByDelegate() throws {
        assert(
            testCase: "Leak by delegate",
            subcase: "No Leak - 1",
            exitAction: {
                app.buttons["Go Back"].tap()
            }
        )
    }

    private func assert(testCase: String, subcase: String? = nil, exitAction: () -> Void, timeout: TimeInterval = .viewDisappearExpectation + LeakTests.bufferInternal) {
        app.tables.staticTexts[testCase].tap()
        
        if let subcase = subcase {
            app.tables.staticTexts[subcase].tap()
        }
        exitAction()
        
        sleep(UInt32(LeakTests.bufferInternal))
        
        let alert = app.alerts["LEAK"]
        let exists = NSPredicate(format: "exists == 0")

        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)

    }
}
