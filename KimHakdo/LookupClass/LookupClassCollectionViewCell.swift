//
//  LookupClassCollectionViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit
import SnapKit
import Kingfisher

final class LookupClassCollectionViewCell: BaseCollectionViewCell<String> {
    
    private let imageView = {
        let imageView = UIImageView()
        imageView.image = .splash
        imageView.contentMode = .scaleToFill
        imageView.kf.indicatorType = .activity
        imageView.layer.cornerRadius = CornerRadius.medium
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = AppFont.subtitle
        label.textColor = .black
        label.text = "잭잭의 사투리교실"
        return label
    }()
    
    private let categoryContainer = {
        let view = UIView()
        view.layer.borderColor = UIColor.point.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = CornerRadius.small
        view.clipsToBounds = true
        return view
    }()
    
    private let categoryLabel = {
        let label = UILabel()
        label.font = AppFont.caption
        label.textColor = .point
        label.text = "외국어"
        return label
    }()
    
    private let descriptionLabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textColor = .border
        label.text = "표준어는 잠시 접어두고, 잭님이 들려주던 그 정겨운 사투리로 얘기를"
        return label
    }()
    
    private let priceLabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "1,000,000원", attributes: [
            .font: AppFont.body,
            .foregroundColor: UIColor.disabled,
            .strikethroughStyle:  NSUnderlineStyle.single.rawValue
        ])
        return label
    }()
    
    private let salePriceLabel = {
        let label = UILabel()
        label.font = AppFont.accent
        label.textColor = .black
        label.text = "100,000원"
        return label
    }()
    
    private let saleRatioLabel = {
        let label = UILabel()
        label.font = AppFont.accent
        label.textColor = .point
        label.text = "90%"
        return label
    }()
    
    private let separatorLine = SeperatorLine()
    
    override func setupHierarchy() {
        [imageView, titleLabel, descriptionLabel, categoryContainer, priceLabel, salePriceLabel, saleRatioLabel, separatorLine].forEach {
            contentView.addSubview($0)
        }
        categoryContainer.addSubview(categoryLabel)
    }
    
    override func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppPadding.verticalPadding / 2)
            make.horizontalEdges.equalToSuperview()
        }
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(AppPadding.verticalInset)
            make.leading.equalToSuperview()
        }
        
        categoryContainer.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        categoryContainer.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(2)
            make.horizontalEdges.equalToSuperview().inset(4)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppPadding.verticalInset)
            make.horizontalEdges.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(AppPadding.verticalInset)
            make.leading.equalToSuperview()
        }
        
        salePriceLabel.snp.makeConstraints { make in
            make.verticalEdges.equalTo(priceLabel)
            make.leading.equalTo(priceLabel.snp.trailing).offset(AppPadding.horizontalInset)
        }
        
        saleRatioLabel.snp.makeConstraints { make in
            make.verticalEdges.equalTo(priceLabel)
            make.leading.equalTo(salePriceLabel.snp.trailing).offset(AppPadding.horizontalInset)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(AppPadding.verticalPadding / 2)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
