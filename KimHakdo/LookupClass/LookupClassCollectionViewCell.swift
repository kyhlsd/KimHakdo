//
//  LookupClassCollectionViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit
import SnapKit
import Kingfisher

final class LookupClassCollectionViewCell: BaseCollectionViewCell<ClassResult> {
    
    private let imageView = {
        let imageView = UIImageView()
        imageView.image = .splash
        imageView.contentMode = .scaleToFill
        imageView.kf.indicatorType = .activity
        imageView.layer.cornerRadius = CornerRadius.medium
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let favoriteButton = FavoriteButton()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = AppFont.subtitle
        label.textColor = .black
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
        return label
    }()
    
    private let descriptionLabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textColor = .border
        return label
    }()
    
    private let priceStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = AppPadding.horizontalInset
        return stackView
    }()
    
    private let attributes: [NSAttributedString.Key: Any] = [
        .font: AppFont.body,
        .foregroundColor: UIColor.disabled,
        .strikethroughStyle:  NSUnderlineStyle.single.rawValue
    ]
    
    private let priceLabel = UILabel()
    
    private let salePriceLabel = {
        let label = UILabel()
        label.font = AppFont.accent
        label.textColor = .black
        return label
    }()
    
    private let salePercentageLabel = {
        let label = UILabel()
        label.font = AppFont.accent
        label.textColor = .point
        return label
    }()
    
    private let separatorLine = SeperatorLine()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        priceLabel.isHidden = true
        salePriceLabel.isHidden = true
        salePercentageLabel.text = nil
    }
    
    override func setData(data: ClassResult) {
        let url = try? Router.fetchImage(url: data.imageURL).asURL()
        imageView.kf.setImage(with: url, options: ImageDownloadHelper.options)
        
        titleLabel.text = data.title
        categoryLabel.text = data.category.description
        descriptionLabel.text = data.description
        
        if let price = data.price, let priceString = MyFormatter.number.string(from: NSNumber(value: price)) {
            priceLabel.attributedText = NSAttributedString(string: priceString, attributes: attributes)
            priceLabel.isHidden = false
        } else {
            priceLabel.isHidden = true
        }
        if let salePrice = data.salePrice, let salePriceString = MyFormatter.number.string(from: NSNumber(value: salePrice)) {
            salePriceLabel.text = salePriceString
            salePriceLabel.isHidden = false
        } else {
            salePriceLabel.isHidden = true
        }
        salePercentageLabel.text = data.salePercentage
        
        favoriteButton.setStatus(isFavorited: data.isLiked)
    }
    
    override func setupHierarchy() {
        [imageView, favoriteButton, titleLabel, descriptionLabel, categoryContainer, priceStackView, separatorLine].forEach {
            contentView.addSubview($0)
        }
        categoryContainer.addSubview(categoryLabel)
        [priceLabel, salePriceLabel,salePercentageLabel].forEach {
            priceStackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppPadding.verticalInset)
            make.horizontalEdges.equalToSuperview()
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(8)
            make.trailing.equalTo(imageView).offset(-8)
            make.size.equalTo(24)
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
        
        priceStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(AppPadding.verticalInset)
            make.leading.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(priceStackView.snp.bottom).offset(AppPadding.verticalInset)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
