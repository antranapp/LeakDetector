//
// Copyright © 2021 An Tran. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 14.0, *)
class BaseUICollectionViewController: UIViewController {
    
    private static let cellReuseID = "product-cell"
    
    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource()
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    typealias Cell = UICollectionViewCell
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, Product>
    
    func makeCellRegistration() -> CellRegistration {
        CellRegistration { cell, indexPath, product in
//            cell.textLabel.text = product.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: Self.cellReuseID
        )
        collectionView.dataSource = dataSource
    }
    
    func makeCollectionView() -> UICollectionView {
        UICollectionView(
            frame: .zero,
            collectionViewLayout: makeCollectionViewLayout()
        )
    }
    
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        fatalError("needs implementation")
    }
    
    func makeListLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(50)
            ),
            subitems: [item]
        )
        
        return NSCollectionLayoutSection(group: group)
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Product> {
        let cellRegistration = makeCellRegistration()
        
        return UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, product in
                collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: product
                )
            }
        )
    }
    
    func productListDidLoad(_ list: ProductList) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems(list.products, toSection: .main)
        
        dataSource.apply(snapshot)
    }
}

@available(iOS 14.0, *)
final class LeakUICollectionViewController: BaseUICollectionViewController {
    
    override func makeCollectionViewLayout() -> UICollectionViewLayout {
        // self is captured strongly here, which causes a retain cycle
        // self -> collectionView -> collectionViewLayout -> self
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch Section(rawValue: sectionIndex) {
            case .main:
                return self.makeListLayoutSection()
            case nil:
                return nil
            }
        }
    }
}

@available(iOS 14.0, *)
final class NoLeakUICollectionViewController: BaseUICollectionViewController {
    override func makeCollectionViewLayout() -> UICollectionViewLayout {
        // Capture self weakly here to avoid retain cycle
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            switch Section(rawValue: sectionIndex) {
            case .main:
                return self?.makeListLayoutSection()
            case nil:
                return nil
            }
        }
    }
}

struct Product: Hashable {
    let name: String
}

struct ProductList: Hashable {
    let products: [Product]
}
