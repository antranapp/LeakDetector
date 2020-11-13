import XCTest

import LeakDetectorTests

var tests = [XCTestCaseEntry]()
tests += LeakDetectorTests.allTests()
XCTMain(tests)
