//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import LeakDetector
import UIKit

class NoLeakCombineViewController: LeakDetectableViewController {
    
    var cancellables = Set<AnyCancellable>()
    let leakPublisher = CurrentValueSubject<Bool, Never>(false)
    
    var boolValue: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        leakPublisher.assign(to: \.boolValue, on: self).store(in: &cancellables)
        
        leakPublisher.sink { [weak self] value in
            self?.boolValue = value
        }.store(in: &cancellables)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            executeLeakDetector(for: leakPublisher)
        }
    }
    
}
