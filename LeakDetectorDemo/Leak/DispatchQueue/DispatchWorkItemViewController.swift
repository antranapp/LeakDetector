//
// Copyright © 2020 An Tran. All rights reserved.
//

import Foundation
import UIKit

class DispatchWorkItemViewController: ChildViewController {
    
    var workItem: DispatchWorkItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storing DispatchWorkItem"
        
        let workItem = DispatchWorkItem { self.view.backgroundColor = .red }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        self.workItem = workItem // stored in a property
    }
}
