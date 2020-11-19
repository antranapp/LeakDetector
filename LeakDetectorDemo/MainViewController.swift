//
//  MainViewController.swift
//  LeakDetectorDemo
//
//  Created by An Tran on 19/11/20.
//

import UIKit
import LeakDetector
import Combine

class MainViewController: UITableViewController {
    
    weak var weakViewController: UIViewController?
    
    var cancellable: AnyCancellable?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 5:
                let storyboard = UIStoryboard(name: "DispatchQueue", bundle: nil)
                let viewController = storyboard.instantiateInitialViewController()!
                weakViewController = viewController
                navigationController?.present(viewController, animated: true, completion: nil)
            case 6:
                let viewController = TimerViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 3:
                let viewController = NoLeakTimerViewController()
                weakViewController = viewController
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        default:
            fatalError("unknown section")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let weakViewController = weakViewController {
            cancellable = LeakDetector.instance.expectViewControllerDellocated(viewController: weakViewController).sink {}
        }
    }
}
