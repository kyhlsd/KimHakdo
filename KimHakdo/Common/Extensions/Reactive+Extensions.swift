//
//  Reactive+Extensions.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/17/25.
//

import UIKit
import RxSwift

extension Reactive where Base: UICollectionView {
    
    func diffableItems<Section: Hashable, Items: Sequence, Cell: UICollectionViewCell>
    (section: Section, cellType: Cell.Type = Cell.self, configureCell: @escaping (Int, Items.Element, Cell) -> Void)
    -> Binder<Items> where Items.Element: Hashable {
        return Binder(base) { collectionView, elements in
            
            let registration = UICollectionView.CellRegistration<Cell, Items.Element> { cell, indexPath, item in
                configureCell(indexPath.item, item, cell)
            }
            
            if objc_getAssociatedObject(collectionView, &AssociatedKeys.dataSource) == nil {
                let dataSource = UICollectionViewDiffableDataSource<Section, Items.Element>(collectionView: collectionView) { collectionView, indexPath, item in
                    return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
                }
                objc_setAssociatedObject(collectionView, &AssociatedKeys.dataSource, dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            if let dataSource = objc_getAssociatedObject(collectionView, &AssociatedKeys.dataSource) as? UICollectionViewDiffableDataSource<Section, Items.Element> {
                var snapshot = NSDiffableDataSourceSnapshot<Section, Items.Element>()
                snapshot.appendSections([section])
                snapshot.appendItems(Array(elements), toSection: section)
                dataSource.apply(snapshot)
            }
        }
    }
}

private enum AssociatedKeys {
    static var dataSource: UInt8 = 0
}
