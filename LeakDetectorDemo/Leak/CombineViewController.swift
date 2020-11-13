//
//  RXViewController.swift
//  LeakDetectorDemo
//
//  Created by Steve Dao on 23/8/20.
//  Copyright © 2020 Steve Dao. All rights reserved.
//

import UIKit
import Combine
import LeakDetector

class CombineViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    let leakPublisher = CurrentValueSubject<Bool, Never>(false)
    
    var boolValue: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leakPublisher.assign(to: \.boolValue, on: self).store(in: &cancellables)
        
        // Use `sink` and capture `weak self` to avoid memory leak
//        leakPublisher.sink { [weak self] value in
//            self?.boolValue = value
//        }.store(in: &cancellables)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            LeakDetector.instance.expectDeallocate(object: leakPublisher)
        }
    }
    
}
