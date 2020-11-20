//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

class ClosureRootViewController: LeakDetectableTableViewController {
    
    @IBAction func backFromClosureViewController(_ segue: UIStoryboardSegue) {
        executeLeakDetector(for: segue.source)
        weakViewController = nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 2:
                let viewController = NoLeakNonEscapingViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        default:
            break
        }
    }
}
