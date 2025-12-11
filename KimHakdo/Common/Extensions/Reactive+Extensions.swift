//
//  Reactive+Extensions.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/17/25.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UICollectionView {

    func diffableItems<Section: Hashable, Items: Sequence, Cell: UICollectionViewCell>
    (section: Section, cellType: Cell.Type = Cell.self, configureCell: @escaping (Int, Items.Element, Cell) -> Void)
    -> Binder<Items> where Items.Element: Hashable {
        return Binder(base) { collectionView, elements in

            var registration = objc_getAssociatedObject(collectionView, &AssociatedKeys.registration) as? UICollectionView.CellRegistration<Cell, Items.Element>
            if registration == nil {
                registration = UICollectionView.CellRegistration<Cell, Items.Element> { cell, indexPath, item in
                    configureCell(indexPath.item, item, cell)
                }
                objc_setAssociatedObject(collectionView, &AssociatedKeys.registration, registration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            if objc_getAssociatedObject(collectionView, &AssociatedKeys.dataSource) == nil {
                let dataSource = UICollectionViewDiffableDataSource<Section, Items.Element>(collectionView: collectionView) { collectionView, indexPath, item in
                    guard let registration else {
                        fatalError("registration not found")
                    }
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

    func diffableModelSelected<Section: Hashable, Item: Hashable>(section: Section.Type = Section.self, _ modelType: Item.Type) -> ControlEvent<Item> {
        let source = itemSelected.compactMap { [weak base] indexPath -> Item? in
            guard let collectionView = base else { return nil }
            guard let dataSource = objc_getAssociatedObject(collectionView, &AssociatedKeys.dataSource) as? UICollectionViewDiffableDataSource<Section, Item> else {
                return nil
            }
            return dataSource.itemIdentifier(for: indexPath)
        }
        return ControlEvent(events: source)
    }
}

private enum AssociatedKeys {
    static var registration: UInt8 = 0
    static var dataSource: UInt8 = 1
}
