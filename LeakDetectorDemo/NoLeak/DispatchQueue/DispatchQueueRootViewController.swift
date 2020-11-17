//
//  DispatchQueueRootViewController.swift
//  LeakDetectorDemo
//
//  Created by Tran, Binh An on 17/11/20.
//

import UIKit
import LeakDetector

class DispatchQueueRootViewController: LeakDetectableTableViewController {

    @IBAction func backFromDispatchQueueViewController(_ segue: UIStoryboardSegue) {
        super.executeLeakDetector(for: segue.source)
    }
}
