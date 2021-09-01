//
// Copyright © 2021 An Tran. All rights reserved.
//

import Combine
import LeakDetectorCombine
import UIKit

class LeakCombineViewController1: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let leakPublisher = CurrentValueSubject<Bool, Never>(false)
    
    private var boolValue: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leakPublisher.assign(to: \.boolValue, on: self).store(in: &cancellables)
        
    }
}

class LeakCombineViewController2: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let leakPublisher = CurrentValueSubject<Bool, Never>(false)
    private var boolValue: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leakPublisher
            .sink { value in
                self.boolValue = value
            }
            .store(in: &cancellables)
        
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

class NoLeakCombineViewController2: ChildViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Just(true)
            .map(transform)
            .sink {
                print($0)
            }
            .store(in: &cancellables)
    }
    
    private func transform(_ value: Bool) -> Bool {
        !value
    }
}

class NoLeakCombineViewController3: ChildViewController {
    
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancellable = Just(true)
            .map(transform)
            .sink(receiveValue: display)
    }
    
    private func transform(_ value: Bool) -> Bool {
        !value
    }
    
    private func display(_ value: Bool) {
        print(value)
    }
}
