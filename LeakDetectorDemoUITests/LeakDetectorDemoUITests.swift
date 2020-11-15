//
//  Copyright © 2020 An Tran. All rights reserved.
//

import XCTest

class LeakDetectorDemoUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

    }
    
    func testLeakViewControllerUsingExpectObjectDellocated() throws {
        app.tables.staticTexts["Leak by delegate"].tap()
        app.navigationBars["Delegate"].buttons["Leak Detector Demo"].tap()
        
        let alert = app.alerts["LEAK"]
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLeakViewControlelrUsingExpectViewControllerDellocated() {
        app.tables.staticTexts["Assert Leak by ViewController"].tap()
        app.tables.staticTexts["Leak View Controller"].tap()
        app.buttons["Go Back"].tap()

        let alert = app.alerts["LEAK"]
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

    }
}
