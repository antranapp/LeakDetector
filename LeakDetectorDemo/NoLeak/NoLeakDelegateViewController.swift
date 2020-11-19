//
//  NoLeakDelegateViewController.swift
//  LeakDetectorDemo
//
//  Created by An Tran on 15/11/20.
//

import UIKit
import LeakDetector
import Combine

class NoLeakDelegateViewController: LeakDetectableViewController {
        
    private weak var delegate: LeakDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
    }
    
    // Expecting NoLeakDelegateViewController & LeakDelegate should be deallocated after poping from Navigation controller
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            super.executeLeakDetector(for: delegate)
        }
    }
}


extension NoLeakDelegateViewController: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}