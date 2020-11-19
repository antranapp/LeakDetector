//
// Copyright © 2020 An Tran. All rights reserved.
//

import UIKit

class TimerViewController: ChildViewController {
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Timer"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doSomething), userInfo: nil, repeats: true)
    }
            
    @objc private func doSomething() {
        print("invoked from timer ....")
    }
    
    deinit {
        print("deinit is called")
    }
}
