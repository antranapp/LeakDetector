//
//  Copyright © 2020 An Tran. All rights reserved.
//

import UIKit

class SimpleClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        handler = {
            self.view.tag = 111
        }
    }
}

class NoLeakSimpleClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        // Capture `self` weakly to avoid retain cycle.
        handler = { [weak self] in
            self?.view.tag = 111
        }
    }
}
