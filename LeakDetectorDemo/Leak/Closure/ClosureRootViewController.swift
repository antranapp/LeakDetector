//
//  Copyright © 2020 An Tran. All rights reserved.
//

import UIKit
import LeakDetector

class ClosureRootViewController: LeakDetectableTableViewController {
    
    @IBAction func backFromClosureViewController(_ segue: UIStoryboardSegue) {
        super.executeLeakDetector(for: segue.source)
    }
}
