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
    
    // MARK: Views
    private let imageView = {
        let imageView = UIImageView()
        imageView.image = .splash
        imageView.contentMode = .scaleToFill
        imageView.kf.indicatorType = .activity
        imageView.layer.cornerRadius = CornerRadius.medium
        imageView.clipsToBounds = true
        return imageView
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
    private let descriptionLabel = UILabel.create(font: AppFont.body, textColor: .border)
    private let priceStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = AppPadding.horizontalInset
        return stackView
    }()
    private let strikeThroughPriceLabel = UILabel()
    private let defaultPriceLabel = UILabel.create(font: AppFont.accent, textColor: .black)
    private let pointPriceLabel = UILabel.create(font: AppFont.accent, textColor: .point)
    private let separatorLine = SeperatorLine()
    
    let favoriteButton = FavoriteButton()
    
    private let attributes: [NSAttributedString.Key: Any] = [
        .font: AppFont.body,
        .foregroundColor: UIColor.disabled,
        .strikethroughStyle:  NSUnderlineStyle.single.rawValue
    ]
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        strikeThroughPriceLabel.isHidden = true
        defaultPriceLabel.isHidden = true
        pointPriceLabel.text = nil
        favoriteButton.reset()
    }
    
    override func setData(data: ClassResult) {
        switch AppConfig.current {
        case .dev:
            let url = try? Router.fetchImage(url: data.imageURL).asURL()
            imageView.kf.setImage(with: url, options: ImageDownloadHelper.options)
        case .dummy:
            let url = URL(string: data.imageURL)
            let processor = DownsamplingImageProcessor(
                size: CGSize(width: Constants.deviceWidth, height: Constants.deviceWidth * 0.6)
            )
            imageView.kf.setImage(with: url, options: [
                .processor(processor),
                .scaleFactor(Constants.deviceScale)
            ])
        }
        
        titleLabel.text = data.title
        categoryLabel.text = data.category.description
        descriptionLabel.text = data.description
        
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
    
    // MARK: Setups
    override func setupHierarchy() {
        [imageView, favoriteButton, titleLabel, descriptionLabel, categoryContainer, priceStackView, separatorLine].forEach {
            contentView.addSubview($0)
        }
        categoryContainer.addSubview(categoryLabel)
        [strikeThroughPriceLabel, defaultPriceLabel,pointPriceLabel].forEach {
            priceStackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
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
