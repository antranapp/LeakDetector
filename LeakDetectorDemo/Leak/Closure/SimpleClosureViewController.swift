//
//  Copyright © 2020 An Tran. All rights reserved.
//

import UIKit

class SimpleClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        handler = {
            self.doSomething()
        }
    }
    
    func doSomething() {}
}

class NoLeakSimpleClosureViewController: UIViewController {
    
    private var handler: (() -> Void)!
      
    override func viewDidLoad() {
        super.viewDidLoad()

        // Capture `self` weakly to avoid retain cycle.
        handler = { [weak self] in
            self?.doSomething()
        }
    }
    
    func doSomething() {}
}
