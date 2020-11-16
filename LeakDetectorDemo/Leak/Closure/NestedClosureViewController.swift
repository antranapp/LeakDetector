//
//  Copyright © 2020 An Tran. All rights reserved.
//

import UIKit

class NestedClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        handler = {
            self.execute { [weak self] in
                self?.view.tag = 111
            }
        }
    }
    
    func execute(_ closure: () -> Void) {
        closure()
    }
}

class NoLeakNestedClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        // Capture `self` weakly to avoid retain cycle.
        handler = { [weak self] in
            self?.execute { [weak self] in
                self?.view.tag = 111
            }
        }
    }
    
    func execute(_ closure: () -> Void) {
        closure()
    }
}
