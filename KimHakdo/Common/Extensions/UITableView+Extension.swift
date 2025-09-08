//
//  UITableView+Extension.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit

extension UITableView {
    
    func register<T: Identifying>(cellClass: T.Type) {
        register(cellClass.self, forCellReuseIdentifier: cellClass.identifier)
    }
    
    func dequeueReusableCell<T: Identifying>(for indexPath: IndexPath, cellClass: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellClass.identifier) matching type \(cellClass.self)")
        }
        return cell
    }
    
}
