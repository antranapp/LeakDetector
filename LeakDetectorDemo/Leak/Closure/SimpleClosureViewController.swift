//
// Copyright © 2021 An Tran. All rights reserved.
//

import UIKit

final class SimpleClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        handler = {
            self.view.tag = 111
        }
    }
}

final class NoLeakSimpleClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        // Capture `self` weakly to avoid retain cycle.
        handler = { [weak self] in
            self?.view.tag = 111
        }
    }
}
