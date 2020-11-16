//
//  Copyright © 2020 An Tran. All rights reserved.
//

import UIKit
import LeakDetector

class ClosureRootViewController: UITableViewController {
    
    @IBAction func backFromClosureViewController(_ segue: UIStoryboardSegue) {
        LeakDetector.instance.expectViewControllerDellocated(viewController: segue.source)
    }
}
