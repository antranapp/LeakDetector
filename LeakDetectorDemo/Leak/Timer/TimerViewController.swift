//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import UIKit

class LeakTimerViewController1: ChildViewController {
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimer()
    }
      
    /* This timer will prevent the controller from deallocating because:
     * 1. it repeats
     * 2. timer holds strong reference to self by default
     * If either of those conditions is false, it wouldn't cause issues */
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doSomething), userInfo: nil, repeats: true)
    }

    @objc private func doSomething() {
        print("invoked from timer ....")
    }
    
    deinit {
        print("deinit is called")
    }
}

class LeakTimerViewController2: ChildViewController {
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimer()
    }
          
    /* This timer will prevent the controller from deallocating because:
     * 1. it repeats
     * 2. self is referenced in the closure without using [weak self]
     * If either of those conditions is false, it wouldn't cause issues */
    func setupTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let currentColor = self.view.backgroundColor
            self.view.backgroundColor = currentColor == .red ? .blue : .red
        }
        timer.tolerance = 0.5
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
        
    deinit {
        print("deinit is called")
    }
}

class NoLeakTimerViewController1: ChildViewController {
    
    private var cancellable: AnyCancellable?
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimer()
    }
    
    func setupTimer() {
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

class NoLeakTimerViewController2: ChildViewController {
    
    private var cancellable: AnyCancellable?
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimer()
    }
    
    func setupTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            let currentColor = self?.view.backgroundColor
            self?.view.backgroundColor = currentColor == .red ? .blue : .red
        }
        timer.tolerance = 0.5
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
}
