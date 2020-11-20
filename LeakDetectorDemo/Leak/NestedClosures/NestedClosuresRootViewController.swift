//
// Copyright © 2020 An Tran. All rights reserved.
//

import Foundation
import UIKit

class NestedClosuresRootViewController: LeakDetectableTableViewController {
    
    private enum Scenarios {
        
        enum Leak: String, CaseIterable {
            case nested1 = "Leak - Nested Closure 1"
            case nested2 = "Leak - Nested Closure 2"
            case nested3 = "Leak - Nested Closure 3"
        }
        
        enum NoLeak: String, CaseIterable {
            case nested1 = "No Leak - Nested Closure 1"
            case nested2 = "No Leak - Nested Closure 2"
            case nested3 = "No Leak - Nested Closure 3"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Animate"
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
            case .nested1:
                let viewController = LeakNestedClosureViewController1()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .nested2:
                let viewController = LeakNestedClosureViewController2()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .nested3:
                let viewController = LeakNestedClosureViewController3()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            }
        case 1:
            let scenario = Scenarios.NoLeak.allCases[indexPath.row]
            switch scenario {
            case .nested1:
                let viewController = NoLeakNestedClosureViewController1()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .nested2:
                let viewController = NoLeakNestedClosureViewController2()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .nested3:
                let viewController = NoLeakNestedClosureViewController3()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            }

        default:
            fatalError("invalid section")
        }
    }
}
