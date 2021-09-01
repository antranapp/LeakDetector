//
// Copyright © 2021 An Tran. All rights reserved.
//

import UIKit

class NoLeakHighOrderFunctionViewController: ChildViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        higherOrderFunctions()
    }
    
    func higherOrderFunctions() {
        let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        numbers.forEach { self.view.tag = $0 }
        _ = numbers.filter { $0 == self.view.tag }
    }
}
