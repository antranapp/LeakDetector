//
//  UICollectionViewRootViewController.swift
//  LeakDetectorDemo
//
//  Created by An Tran on 2/11/22.
//

import Foundation
import UIKit
import Combine
import LeakDetectorCombine

final class UICollectionViewRootViewController: LeakDetectableTableViewController {
    private enum Scenarios {
        
        enum Leak: String, CaseIterable {
            case lazy1 = "Leak - 1"
        }
        
        enum NoLeak: String, CaseIterable {
            case lazy1 = "No Leak - 1"
        }
    }
    
    private var statusLabel: UILabel?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UICollectionView"
        
        LeakDetectorCombine.LeakDetector.instance.status
            .sink(
                receiveValue: { [weak self] status in
                    self?.statusLabel?.text = "\(status)"
                }
            )
            .store(in: &cancellables)

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Status"
        case 1:
            return "Leak"
        case 2:
            return "No Leak"
        default:
            fatalError("invalid section")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return Scenarios.Leak.allCases.count
        case 2:
            return Scenarios.NoLeak.allCases.count
        default:
            fatalError("invalid section")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        switch indexPath.section {
        case 0:
            statusLabel = cell.textLabel
        case 1:
            cell.textLabel?.text = Scenarios.Leak.allCases[indexPath.row].rawValue
        case 2:
            cell.textLabel?.text = Scenarios.NoLeak.allCases[indexPath.row].rawValue
        default:
            fatalError("invalid section")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let scenario = Scenarios.Leak.allCases[indexPath.row]
            switch scenario {
            case .lazy1:
                if #available(iOS 14.0, *) {
                    let viewController = LeakUICollectionViewController()
                    viewController.title = scenario.rawValue
                    weakViewController = viewController
                    navigationController?.pushViewController(viewController, animated: true)
                } else {
                    showAlert("Required iOS >= 14")
                }
            }
        case 2:
            let scenario = Scenarios.NoLeak.allCases[indexPath.row]
            switch scenario {
            case .lazy1:
                if #available(iOS 14.0, *) {
                    let viewController = NoLeakUICollectionViewController()
                    viewController.title = scenario.rawValue
                    weakViewController = viewController
                    navigationController?.pushViewController(viewController, animated: true)
                } else {
                    showAlert("Required iOS >= 14")
                }
            }

        default:
            break
        }
    }
}
