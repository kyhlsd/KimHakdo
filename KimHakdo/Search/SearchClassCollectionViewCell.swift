//
//  SearchClassCollectionViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import UIKit
import SnapKit
import Kingfisher

final class SearchClassCollectionViewCell: BaseCollectionViewCell<ClassResult> {
    
    private let imageView = {
        let imageView = UIImageView()
        imageView.image = .splash
        imageView.contentMode = .scaleToFill
        imageView.kf.indicatorType = .activity
        imageView.layer.cornerRadius = CornerRadius.medium
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let favoriteButton = {
        let button = FavoriteButton()
        button.setBorder(true)
        return button
    }()
    
    private let titleLabel = UILabel.create(font: AppFont.subtitle, textColor: .black)
    
    private let categoryContainer = {
        let view = UIView()
        view.layer.borderColor = UIColor.point.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = CornerRadius.small
        view.clipsToBounds = true
        return view
    }()
    
    private let categoryLabel = UILabel.create(font: AppFont.caption, textColor: .point)
    
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
    
    private let strikeThroughPriceLabel = UILabel()
    
    private let defaultPriceLabel = UILabel.create(font: AppFont.accent, textColor: .black)
    
    private let pointPriceLabel = UILabel.create(font: AppFont.accent, textColor: .point)
    
    private let separatorLine = SeperatorLine()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        strikeThroughPriceLabel.isHidden = true
        defaultPriceLabel.isHidden = true
        pointPriceLabel.text = nil
    }
    
    override func setData(data: ClassResult) {
        let url = try? Router.fetchImage(url: data.imageURL).asURL()
        imageView.kf.setImage(with: url, options: ImageDownloadHelper.options)
        
        titleLabel.text = data.title
        categoryLabel.text = data.category.description
        
        setPriceLabels(price: data.price, salePrice: data.salePrice, salePercentage: data.salePercentage)
        
        favoriteButton.setData(classId: data.classId, classTitle: data.title, isLiked: data.isLiked)
    }
    
    private func setPriceLabels(price: Int?, salePrice: Int?, salePercentage: String?) {
        // 원가 nil, 세일가 nil -> 무료만 표기
        guard let price, let priceString = MyFormatter.number.string(from: NSNumber(value: price)) else {
            strikeThroughPriceLabel.isHidden = true
            defaultPriceLabel.isHidden = true
            pointPriceLabel.text = salePercentage
            return
        }
        
        // 원가 있음, 세일가 nil -> 원가만 표기
        guard let salePrice, let salePriceString = MyFormatter.number.string(from: NSNumber(value: salePrice)) else {
            strikeThroughPriceLabel.isHidden = true
            defaultPriceLabel.text = priceString
            defaultPriceLabel.isHidden = false
            pointPriceLabel.text = salePercentage
            return
        }
        
        // 원가 있음, 세일가 있음 -> 전부 표기
        strikeThroughPriceLabel.attributedText = NSAttributedString(string: priceString, attributes: attributes)
        strikeThroughPriceLabel.isHidden = false
        defaultPriceLabel.text = salePriceString
        defaultPriceLabel.isHidden = false
        pointPriceLabel.text = salePercentage
    }
    
    override func setupHierarchy() {
        [imageView, favoriteButton, titleLabel, categoryContainer, strikeThroughPriceLabel, priceStackView, separatorLine].forEach {
            contentView.addSubview($0)
        }
        
        categoryContainer.addSubview(categoryLabel)
        
        defaultPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        pointPriceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        [defaultPriceLabel, pointPriceLabel].forEach {
            priceStackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppPadding.verticalInset)
            make.leading.equalToSuperview()
            make.width.equalTo(imageView.snp.height).multipliedBy(1.25)
        }
        
        categoryContainer.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(AppPadding.horizontalInset)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(2)
            make.horizontalEdges.equalToSuperview().inset(4)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryContainer.snp.bottom).offset(4)
            make.leading.equalTo(categoryContainer)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-AppPadding.horizontalInset)
        }
        
        priceStackView.snp.makeConstraints { make in
            make.leading.equalTo(categoryContainer)
            make.trailing.equalTo(titleLabel)
            make.bottom.equalTo(imageView).offset(-4)
        }
        
        strikeThroughPriceLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryContainer)
            make.trailing.equalTo(titleLabel)
            make.bottom.equalTo(priceStackView.snp.top)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(priceStackView.snp.bottom).offset(AppPadding.verticalInset)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
