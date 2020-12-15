//
// Copyright © 2020 Standard Chartered. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

open class BaseCoordinator<T>: UINavigationController, Coordinator {

    public let dependency: T
    private var cancellables = Set<AnyCancellable>()

    private var trackingViewControllers = WeakSet<UIViewController>()

    public init(with dependency: T) {
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func start() {}

    open func navigate(to destination: Destination, presentInModal: Bool = false, animated: Bool) {
        guard let viewController = makeViewController(for: destination) else {
            return
        }

        trackingViewControllers.insert(viewController)

        if presentInModal {
            present(viewController, animated: animated, completion: nil)
            return
        }

        if viewControllers.isEmpty {
            viewControllers = [
                viewController,
            ]
        } else {
            pushViewController(viewController, animated: animated)
        }
    }

    open func makeViewController(for destination: Destination) -> UIViewController? {
        nil
    }

    deinit {
        guard let topViewController = topViewController else {
            return
        }
        LeakDetector.instance.expectDeallocate(objects: trackingViewControllers).sink {}.store(in: &cancellables)
    }
}
