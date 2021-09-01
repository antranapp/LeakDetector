//
//  LeakDetectableRxSwiftTableViewController.swift
//  LeakDetectorDemo
//
//  Created by Binh An Tran on 1/9/21.
//

import Foundation
import LeakDetectorRxSwift
import UIKit
import RxSwift

class LeakDetectableRxSwiftTableViewController: UITableViewController {

    // Assign this weakViewController to a child view controller
    // When we navigate to this TableViewController, we will
    // use this weak reference to check if the child view controller
    // is deallocated correctly.
    weak var weakViewController: UIViewController?
    var leakSubscription: LeakDetectionHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func executeLeakDetector(for object: AnyObject) {
        leakSubscription = LeakDetector.instance.expectDeallocate(object: object)
    }

    func executeLeakDetector(for viewController: UIViewController) {
        leakSubscription = LeakDetector.instance.expectViewControllerDellocated(viewController: viewController)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let weakViewController = weakViewController {
            executeLeakDetector(for: weakViewController)
            self.weakViewController = nil
        }
    }
}

