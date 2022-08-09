//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import LeakDetectorCombine
import UIKit

final class CoordinatorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let button = UIButton()
        button.setTitle("Present Root Coordinator", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(presentRootCoordinator), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc func presentRootCoordinator() {
        present(ParentCoordinator(with: ()), animated: true, completion: nil)
    }
}

// MARK: RootCoordinator

private class ParentCoordinator: BaseCoordinator<Void> {

    private var cancellables = Set<AnyCancellable>()

    enum Dest: Destination {
        case root
        case leakyChild
        case nonLeakyChild
    }

    override init(with dependency: Void) {
        super.init(with: ())

        start()
    }

    override func start() {
        LeakDetector.instance.isLeaked
            .sink { [weak self] message in
                if let message = message {
                    self?.showLeakAlert(message)
                }
            }
            .store(in: &cancellables)

        navigate(to: Dest.root, animated: true)
    }

    override func makeViewController(for destination: Destination) -> UIViewController? {
        switch destination {
        case Dest.root:
            return ParentViewController(with: self)
        case Dest.leakyChild:
            return LeakyDelegateViewController()
        case Dest.nonLeakyChild:
            return NonLeakyDelegateViewController()
        default:
            fatalError("invalid destination")
        }
    }

    private func showLeakAlert(_ message: String) {
        let alertController = UIAlertController(title: "LEAK", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

}

private class ParentViewController: UIViewController {

    weak var weakViewController: UIViewController?
    weak var coordinator: ParentCoordinator!

    init(with coordinator: ParentCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let leakButton = UIButton()
        leakButton.setTitle("Push a leaky view", for: .normal)
        leakButton.setTitleColor(.blue, for: .normal)
        leakButton.addTarget(self, action: #selector(pushLeakyViewController), for: .touchUpInside)

        let noLeakButton = UIButton()
        noLeakButton.setTitle("Push a non-leaky view", for: .normal)
        noLeakButton.setTitleColor(.blue, for: .normal)
        noLeakButton.addTarget(self, action: #selector(pushNonLeakyViewController), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [leakButton, noLeakButton])
        stackView.axis = .vertical

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc func pushLeakyViewController() {
        coordinator.navigate(to: ParentCoordinator.Dest.leakyChild, animated: true)
    }

    @objc func pushNonLeakyViewController() {
        coordinator.navigate(to: ParentCoordinator.Dest.nonLeakyChild, animated: true)

    }

    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: ChildCoordinator

private protocol LeakDelegate: AnyObject {
    var viewController: UIViewController { get }
}

private class LeakyDelegateViewController: UIViewController {

    private var cancellable: AnyCancellable?

    // VC holds strongly on delegate, delegate holds strongly on VC -> Retain cycle
    private var delegate: LeakDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        delegate = self

    }
}

extension LeakyDelegateViewController: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}

// MARK: No Leak VC

private final class NonLeakyDelegateViewController: UIViewController {

    private var cancellable: AnyCancellable?

    // Use `weak` here to avoid retain cycle
    private weak var delegate: LeakDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        delegate = self
    }
}

extension NonLeakyDelegateViewController: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}
