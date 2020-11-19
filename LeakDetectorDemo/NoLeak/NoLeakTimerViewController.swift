//
//  Copyright © 2020 An Tran. All rights reserved.
//

import UIKit
import Combine
import LeakDetector

class NoLeakTimerViewController: ChildViewController {
    
    private var cancellable: AnyCancellable?
    private var timer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doSomething), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func doSomething() {
        print("invoked from timer ....")
    }
    
    deinit {
        print("deinit is called")
    }
}
