//
//  UICollectionView+Extension.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit

extension UICollectionView {
    
    func register<T: Identifying>(cellClass: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.identifier)
    }
    
}
