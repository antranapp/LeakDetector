//
// Copyright © 2021 An Tran. All rights reserved.
//

import UIKit

final class NestedClosureViewController: UIViewController {
    
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

final class NoLeakNestedClosureViewController: UIViewController {
    
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
