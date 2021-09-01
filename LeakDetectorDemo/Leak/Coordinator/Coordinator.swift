//
// Copyright © 2021 An Tran. All rights reserved.
//

import UIKit

public protocol Destination {}

public protocol Coordinator: UINavigationController {
    associatedtype CoordinatorDependency
    var dependency: CoordinatorDependency { get }

    func start()
    func navigate(to destination: Destination, presentInModal: Bool, animated: Bool)
}
