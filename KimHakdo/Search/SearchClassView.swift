//
//  SearchClassView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import UIKit
import SnapKit

final class SearchClassView: BaseView {
    
    let searchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.font = AppFont.body
        searchBar.searchTextField.textColor = .black
        searchBar.layer.borderWidth = 1.5
        searchBar.layer.borderColor = UIColor.border.cgColor
        searchBar.placeholder = "검색어를 입력해주세요."
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.subviews.first?.isHidden = true
        searchBar.returnKeyType = .search
        return searchBar
    }()
    
    let collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: AppPadding.verticalInset, left: AppPadding.horizontalPadding, bottom: AppPadding.verticalInset, right: AppPadding.horizontalPadding)
        layout.itemSize = CGSize(width: Constants.deviceWidth - AppPadding.horizontalPadding * 2, height: 120)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellClass: SearchClassCollectionViewCell.self)
        collectionView.backgroundColor = .clear
        // TODO: 키보드 내리기
        return collectionView
    }()
    
    let guideLabel = UILabel.create(font: AppFont.body, textColor: .black)
    
    override func draw(_ rect: CGRect) {
        searchBar.layer.cornerRadius = searchBar.frame.height / 2
    }
    
    override func setupView() {
        backgroundColor = .background
        guideLabel.text = "원하는 클래스가 있으신가요?"
    }
    
    override func setupHierarchy() {
        [searchBar, collectionView, guideLabel].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppPadding.verticalPadding)
            make.horizontalEdges.equalToSuperview().inset(AppPadding.horizontalPadding)
            make.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppPadding.verticalInset)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
        }
    }
}
