//
//  File.swift
//  
//
//  Created by Binh An Tran on 1/9/21.
//

import Foundation

/// The default time values used for leak detection expectations.
public extension TimeInterval {
    /// The object deallocation time.
    static let deallocationExpectation: TimeInterval = 1.0

    /// The view disappear time.
    static let viewDisappearExpectation: TimeInterval = 3.0
}

public enum LeakDetectionStatus {
    case inProgress, didComplete
}
