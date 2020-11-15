//
//  NoLeakDelegateViewController.swift
//  LeakDetectorDemo
//
//  Created by An Tran on 15/11/20.
//

import UIKit
import LeakDetector

class NoLeakDelegateViewController: UIViewController {
        
    weak var delegate: LeakDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
    }
    
    // Expecting NoLeakDelegateViewController & LeakDelegate should be deallocated after poping from Navigation controller
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            LeakDetector.instance.expectDeallocate(object: delegate)
        }
    }
}


extension NoLeakDelegateViewController: LeakDelegate {
    var viewController: UIViewController {
        self
    }
}
