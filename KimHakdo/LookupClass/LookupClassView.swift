//
//  LookupClassView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit
import SnapKit

final class LookupClassView: BaseView {
    
    let categoryCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: AppPadding.horizontalPadding, bottom: 0, right: AppPadding.horizontalPadding)
        layout.estimatedItemSize = CGSize(width: 80, height: 36)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellClass: CategoryCollectionViewCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func setupView() {
        backgroundColor = .background
    }
    
    override func setupHierarchy() {
        [categoryCollectionView].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppPadding.verticalPadding)
            make.height.equalTo(36)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
}
