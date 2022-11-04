//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import XCTest
@testable import LeakDetectorCore

// These unit tests are taken from https://gist.github.com/preble/13ab713ac044876c89b5
final class WeakSequenceTests: XCTestCase {
    func testConstructor() {
        let a: NSString? = NSString(string: "A")
        let b: NSString? = NSString(string: "B")
        
        let weakSet = WeakSequenceOf([a, b])
        XCTAssertTrue(weakSet.contains(a))
        XCTAssertTrue(weakSet.contains(b))
    }

    func testBasicAddRemove() {
        let a = NSString(string: "A")
        var weakSet = WeakSequence<Weak<NSString>>()

        weakSet.add(a)
        XCTAssertEqual(weakSet.asArray, [a])

        weakSet.remove(a)
        XCTAssertEqual(weakSet.asArray, [])
        XCTAssertFalse(weakSet.contains(a))
    }

    func testIntermediateAddRemove() {
        let a = NSString(string: "A")
        let b = NSString(string: "B")
        var weakSet = WeakSequenceOf([a, b])

        weakSet.remove(a)
        XCTAssertEqual(weakSet.asArray, [b])
        XCTAssertFalse(weakSet.contains(a))

        weakSet.remove(b)
        XCTAssertEqual(weakSet.asArray, [])
        XCTAssertFalse(weakSet.contains(b))
    }

    func testInitialiseThenNil() {
        var c1: C? = C(1), c2: C? = C(2), c3: C? = C(3), c4: C? = C(4)
        
        let weakSet = WeakSequenceOf([c1, c2, c3, c4])
        XCTAssertEqual(weakSet.asArray, [c1, c2, c3, c4])
        
        (c1, c3) = (nil, nil)
        XCTAssertEqual(weakSet.asArray, [c2, c4])
    }
    
    func testAddThenNilFoundationClass() {
        // Use NSMutableString here instead of NSString with this recommendation: https://developer.apple.com/forums/thread/106405
        var c1: NSMutableString? = NSMutableString(string: "1"), c2: NSMutableString? = NSMutableString(string: "2"), c3: NSMutableString? = NSMutableString(string: "3"), c4: NSMutableString? = NSMutableString(string: "4")
        
        let weakSet = WeakSequenceOf([c1, c2, c3, c4])
        XCTAssertEqual(weakSet.asArray, [c1, c2, c3, c4])
        
        (c1, c3) = (nil, nil)
        XCTAssertEqual(weakSet.asArray, [c2, c4])
    }

    func testAddThenNilCustomClass() {
        var c1: S? = S(string: "1"), c2: S? = S(string: "2"), c3: S? = S(string: "3"), c4: S? = S(string: "4")
        
        let weakSet = WeakSequenceOf([c1, c2, c3, c4])
        XCTAssertEqual(weakSet.asArray, [c1, c2, c3, c4])
        
        (c1, c3) = (nil, nil)
        XCTAssertEqual(weakSet.asArray, [c2, c4])
    }
}

class C: CustomStringConvertible, Equatable {
    static func == (lhs: C, rhs: C) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    var description: String { "C\(id)" }
    init(_ id: Int) { self.id = id }
    deinit { print("\(self) is gone.") }
}

class S: CustomStringConvertible, Equatable {
    static func == (lhs: S, rhs: S) -> Bool {
        lhs.value == rhs.value
    }
    
    let value: String
    var description: String { "S\(value)" }
    init(string value: String) { self.value = value }
    deinit { print("\(self) is gone.") }
}
