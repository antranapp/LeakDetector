//
// Copyright © 2021 An Tran. All rights reserved.
//

// Copied from: https://gist.github.com/almaleh/7e918ee284e67b2a8297b558f22a68ba

import Foundation
import UIKit

final class LeakNestedClosureViewController1: ChildViewController {
    
    var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let workItem = DispatchWorkItem {
            UIView.animate(withDuration: 1.0) {
                self.view.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }
}

final class LeakNestedClosureViewController2: ChildViewController {
    
    var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let workItem = DispatchWorkItem {
            UIView.animate(withDuration: 1.0) { [weak self] in
                self?.view.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }
}

final class LeakNestedClosureViewController3: ChildViewController {
    
    var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view
        let workItem = DispatchWorkItem {
            UIView.animate(withDuration: 1.0) {
                view?.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }
}

final class NoLeakNestedClosureViewController1: ChildViewController {
    
    var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let workItem = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 1.0) { [weak self] in
                self?.view.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }
}

final class NoLeakNestedClosureViewController2: ChildViewController {
    
    var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let workItem = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 1.0) {
                self?.view.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }
}

final class NoLeakNestedClosureViewController3: ChildViewController {
    
    var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view
        let workItem = DispatchWorkItem {
            UIView.animate(withDuration: 1.0) {
                view?.backgroundColor = .red
            }
        }
        self.workItem = workItem
    }
}
