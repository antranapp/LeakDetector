//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

class LeakCombineViewController1: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let leakPublisher = CurrentValueSubject<Bool, Never>(false)
    
    private var boolValue: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leakPublisher.assign(to: \.boolValue, on: self).store(in: &cancellables)
        
        // Use `sink` and capture `weak self` to avoid memory leak
//        leakPublisher.sink { [weak self] value in
//            self?.boolValue = value
//        }.store(in: &cancellables)
        
    }
        
}

class NoLeakCombineViewController1: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let leakPublisher = CurrentValueSubject<Bool, Never>(false)
    
    private var boolValue: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leakPublisher.sink { [weak self] value in
            self?.boolValue = value
        }.store(in: &cancellables)
        
    }

}
