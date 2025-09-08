//
//  BaseTableViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit

class BaseTableViewCell<T>: UITableViewCell, Identifying {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupHierarchy()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(data: T) {}
    
    func setupView() {}
    func setupHierarchy() {}
    func setupLayout() {}
}
