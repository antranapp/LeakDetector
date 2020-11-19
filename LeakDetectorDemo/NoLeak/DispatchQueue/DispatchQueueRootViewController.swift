//
// Copyright © 2020 An Tran. All rights reserved.
//

import LeakDetector
import UIKit

class DispatchQueueRootViewController: LeakDetectableTableViewController {

    @IBAction func backFromDispatchQueueViewController(_ segue: UIStoryboardSegue) {
        super.executeLeakDetector(for: segue.source)
    }
}
