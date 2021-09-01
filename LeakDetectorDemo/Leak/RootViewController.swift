//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import LeakDetectorCombine
import UIKit

private protocol LeakDelegate: AnyObject {
    var viewController: UIViewController { get }
}

class RootViewController: LeakDetectableTableViewController {
    
    @IBAction func backFromLeakingViewController(_ segue: UIStoryboardSegue) {
        executeLeakDetector(for: segue.source)
    }
}

class NotLeakingChildViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapGoBack(_ sender: Any) {
        performSegue(withIdentifier: "goBack", sender: self)
    }
}

class LeakingChildViewController: UIViewController {
        
    //    weak private var delegate: LeakDelegate!
    private var delegate: LeakDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    @IBAction func didTapGoBack(_ sender: Any) {
        performSegue(withIdentifier: "goBack", sender: self)
    }

}

extension LeakingChildViewController: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}
