//
//  CategoryCollectionViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit
import SnapKit

final class CategoryCollectionViewCell: BaseCollectionViewCell<(ClassCategory, Bool)> {
    
    // MARK: Views
    private let containerView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }()
    private let label = UILabel.create(font: AppFont.accent, textColor: .black)
    
    override func draw(_ rect: CGRect) {
        containerView.layer.cornerRadius = containerView.frame.height / 2
    }
        
    override func setData(data: (ClassCategory, Bool)) {
        let (category, isSelected) = data
        label.text = category.description
        
        let color: UIColor = isSelected ? .point : .disabled
        label.textColor = color
        containerView.layer.borderColor = color.cgColor
    }
    
    // MARK: Setups
    override func setupHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(label)
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(12)
            make.verticalEdges.equalToSuperview().inset(8)
        }
    }
}
