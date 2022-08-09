//
// Copyright © 2021 An Tran. All rights reserved.
//

import LeakDetectorCombine
import UIKit

final class DispatchQueueRootViewController: LeakDetectableTableViewController {
    
    @IBAction func backFromDispatchQueueViewController(_ segue: UIStoryboardSegue) {
        executeLeakDetector(for: segue.source)
        weakViewController = nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let viewController = DispatchWorkItemViewController()
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
