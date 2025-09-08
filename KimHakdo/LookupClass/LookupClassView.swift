//
//  LookupClassView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit
import SnapKit

final class LookupClassView: BaseView {
    
    // MARK: Views
    private let separatorLine = SeperatorLine()
    
    let categoryCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: AppPadding.horizontalPadding, bottom: 0, right: AppPadding.horizontalPadding)
        layout.estimatedItemSize = CGSize(width: 80, height: 36)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellClass: CategoryCollectionViewCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    let countLabel = UILabel.create(font: AppFont.accent, textColor: .black)
    let sortButton = {
        var config = UIButton.Configuration.plain()
        config.image = .sort
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = .point
        config.contentInsets = .zero
        let button = UIButton()
        button.configuration = config
        return button
    }()
    let classCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: AppPadding.verticalInset, left: AppPadding.horizontalPadding, bottom: AppPadding.verticalInset, right: AppPadding.horizontalPadding)
        layout.itemSize = CGSize(width: Constants.deviceWidth - AppPadding.horizontalPadding * 2, height: 240)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellClass: LookupClassCollectionViewCell.self)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let titleContainer = {
        var container = AttributeContainer()
        container.font = AppFont.accent
        return container
    }()
    
    func setSortButtonTitle(title: String) {
        sortButton.configuration?.attributedTitle = AttributedString(title, attributes: titleContainer)
    }
    
    // MARK: Setups
    override func setupView() {
        backgroundColor = .background
    }
    
    override func setupHierarchy() {
        [categoryCollectionView, countLabel, sortButton, separatorLine, classCollectionView].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppPadding.verticalPadding)
            make.height.equalTo(36)
            make.horizontalEdges.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(AppPadding.verticalPadding)
            make.leading.equalToSuperview().offset(AppPadding.horizontalPadding)
        }
        
        sortButton.snp.makeConstraints { make in
            make.bottom.equalTo(countLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-AppPadding.horizontalPadding)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(AppPadding.verticalPadding)
            make.horizontalEdges.equalToSuperview()
        }
        
        classCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
}
