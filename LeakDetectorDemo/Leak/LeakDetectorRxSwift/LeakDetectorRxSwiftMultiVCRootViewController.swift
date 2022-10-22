//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import UIKit
import LeakDetectorCore
import LeakDetectorRxSwift

final class LeakDetectorRxSwiftMultiVCRootViewController: UITableViewController {
    
    private var viewControllers = WeakSet<UIViewController>()
    private var leakSubscription: LeakDetectionHandle?

    private enum Scenarios {

        enum Leak: String, CaseIterable {
            case observable1 = "Leak - 1"
        }

        enum NoLeak: String, CaseIterable {
            case observable1 = "No Leak - 1"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LeakDetectorRxSwift Multi VC"
    }
    
    private func executeLeakDetector() {
        leakSubscription?.cancel()
        leakSubscription = nil
        leakSubscription = LeakDetector.instance.expectViewControllerDellocated(viewControllers: viewControllers)
    }

    override func viewDidAppear(_ animated: Bool) {
        if !viewControllers.isEmpty {
            executeLeakDetector()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Leak"
        case 1:
            return "No Leak"
        default:
            fatalError("invalid section")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Scenarios.Leak.allCases.count
        case 1:
            return Scenarios.NoLeak.allCases.count
        default:
            fatalError("invalid section")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = Scenarios.Leak.allCases[indexPath.row].rawValue
        case 1:
            cell.textLabel?.text = Scenarios.NoLeak.allCases[indexPath.row].rawValue
        default:
            fatalError("invalid section")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let scenario = Scenarios.Leak.allCases[indexPath.row]
            switch scenario {
            case .observable1:
                let viewController = LeakDetectorRxSwiftViewController1()
                viewController.title = scenario.rawValue
                viewControllers.insert(viewController)
                navigationController?.pushViewController(viewController, animated: true)
            }
        case 1:
            let scenario = Scenarios.NoLeak.allCases[indexPath.row]
            switch scenario {
            case .observable1:
                let viewController = NoLeakLeakDetectorRxSwiftViewController1()
                viewController.title = scenario.rawValue
                viewControllers.insert(viewController)
                navigationController?.pushViewController(viewController, animated: true)
            }

        default:
            fatalError("invalid section")
        }
    }
}
