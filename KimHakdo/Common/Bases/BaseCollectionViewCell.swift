//
//  BaseCollectionViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit

class BaseCollectionViewCell<T>: UICollectionViewCell, Identifying {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
