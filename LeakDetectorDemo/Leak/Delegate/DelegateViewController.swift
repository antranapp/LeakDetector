//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import LeakDetectorCombine
import UIKit

private protocol LeakDelegate: AnyObject {
    var viewController: UIViewController { get }
}

final class DelegateViewController1: ChildViewController {
        
    private var cancellable: AnyCancellable?
    
//    weak private var delegate: LeakDelegate!
    private var delegate: LeakDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
    }
}

extension DelegateViewController1: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}

// MARK: - No Leak Case 1

final class NoLeakDelegateViewController1: ChildViewController {
            
    private weak var delegate: LeakDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
    }

}

extension NoLeakDelegateViewController1: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}

// MARK: - No Leake Case 2

final class NoLeakDelegateViewController2: ChildViewController, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
