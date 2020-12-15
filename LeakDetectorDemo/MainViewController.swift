//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

class MainViewController: LeakDetectableTableViewController {
                
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let viewController = RxSwiftRootViewController()
                let navController = UINavigationController(rootViewController: viewController)
                weakViewController = navController
                navigationController?.present(navController, animated: true, completion: nil)
            case 1:
                let viewController = DelegateRootViewController()
                let navController = UINavigationController(rootViewController: viewController)
                weakViewController = navController
                navigationController?.present(navController, animated: true, completion: nil)
            case 2:
                let viewController = CombineRootViewController()
                let navController = UINavigationController(rootViewController: viewController)
                weakViewController = navController
                navigationController?.present(navController, animated: true, completion: nil)
            case 4:
                let storyboard = UIStoryboard(name: "Closure", bundle: nil)
                let viewController = storyboard.instantiateInitialViewController()!
                weakViewController = viewController
                navigationController?.present(viewController, animated: true, completion: nil)
            case 5:
                let storyboard = UIStoryboard(name: "DispatchQueue", bundle: nil)
                let viewController = storyboard.instantiateInitialViewController()!
                weakViewController = viewController
                navigationController?.present(viewController, animated: true, completion: nil)
            case 6:
                let viewController = TimerRootViewController()
                let navController = UINavigationController(rootViewController: viewController)
                weakViewController = navController
                navigationController?.present(navController, animated: true, completion: nil)
            case 7:
                let viewController = AnimateRootViewController()
                let navController = UINavigationController(rootViewController: viewController)
                weakViewController = navController
                navigationController?.present(navController, animated: true, completion: nil)
            case 8:
                let viewController = NestedClosuresRootViewController()
                let navController = UINavigationController(rootViewController: viewController)
                weakViewController = navController
                navigationController?.present(navController, animated: true, completion: nil)
            case 9:
                let viewController = URLSessionRootViewController()
                let navController = UINavigationController(rootViewController: viewController)
                weakViewController = navController
                navigationController?.present(navController, animated: true, completion: nil)
            case 10:
                let viewController = NotificationCenterViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case 11:
                let viewController = LazyVarRootViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case 12:
                let viewController = SimpleCasesRootViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            case 13:
                let viewController = CoordinatorRootViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                let viewController = NoLeakHighOrderFunctionViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        default:
            fatalError("unknown section")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let weakViewController = weakViewController {
            executeLeakDetector(for: weakViewController)
        }
    }
}
