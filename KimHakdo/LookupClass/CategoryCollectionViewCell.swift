//
//  CategoryCollectionViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit
import SnapKit

final class CategoryCollectionViewCell: UICollectionViewCell, Identifying {
    
    private let containerView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }()
    
    private let label = {
        let label = UILabel()
        label.font = AppFont.accent
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        containerView.layer.cornerRadius = containerView.frame.height / 2
    }
    
    func setData(data: (ClassCategory, Bool)) {
        let (category, isSelected) = data
        label.text = category.description
        
        let color: UIColor = isSelected ? .point : .disabled
        label.textColor = color
        containerView.layer.borderColor = color.cgColor
    }
    
    private func setup() {
        contentView.addSubview(containerView)
        containerView.addSubview(label)
        
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
