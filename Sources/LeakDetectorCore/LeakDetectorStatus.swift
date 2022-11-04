//
// Copyright © 2021 An Tran. All rights reserved.
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
