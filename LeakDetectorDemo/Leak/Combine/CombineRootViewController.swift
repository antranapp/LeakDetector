//
// Copyright © 2020 An Tran. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class CombineRootViewController: LeakDetectableTableViewController {
    
    private enum Scenarios {
        
        enum Leak: String, CaseIterable {
            case combine1 = "Leak - Combine assign"
            case combine2 = "Leak - Combine sink"
        }
        
        enum NoLeak: String, CaseIterable {
            case combine1 = "No Leak - Combine assign"
            case combine2 = "No Leak - Combine map"
            case combine3 = "No Leak - Combine sink"
            case combineService1 = "No Leak - Combine Service"
            case future1 = "No Leak - Combine Future 1"
            case future2 = "No Leak - Combine Future 2"
            case swiftui = "No Leak - Combine SwiftUI"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Combine"
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
            case .combine1:
                let viewController = LeakCombineViewController1()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
                
            case .combine2:
                let viewController = LeakCombineViewController2()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
                
            }
        case 1:
            let scenario = Scenarios.NoLeak.allCases[indexPath.row]
            switch scenario {
            case .combine1:
                let viewController = NoLeakCombineViewController1()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .combine2:
                let viewController = NoLeakCombineViewController2()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .combine3:
                let viewController = NoLeakCombineViewController2()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .combineService1:
                let viewController = NoLeakCombineServiceViewController1()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .future1:
                let viewController = NoLeakFutureViewController1()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case .future2:
                let viewController = NoLeakFutureViewController2()
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)

            case .swiftui:
                let viewController = UIHostingController(rootView: CombineSwiftUIView(store: Store()))
                viewController.title = scenario.rawValue
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)

            }

        default:
            fatalError("invalid section")
        }
    }
}
