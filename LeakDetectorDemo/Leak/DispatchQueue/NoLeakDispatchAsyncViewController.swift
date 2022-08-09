//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import UIKit

final class NoLeakDispatchAsyncViewController1: UIViewController {

    private let queue = DispatchQueue.main

    override func viewDidLoad() {
        super.viewDidLoad()

        queue.async {
            self.view.tag = 111
        }
    }
}

final class NoLeakDispatchAsyncViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.view.tag = 111
        }
    }
}
