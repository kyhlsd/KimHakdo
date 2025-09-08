//
//  ClassDetailView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit
import SnapKit
import Kingfisher

final class ClassDetailView: BaseView {
    
    // MARK: Views
    private let profileImageView = {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    private let infoStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.layer.cornerRadius = CornerRadius.big
        stackView.layer.borderColor = UIColor.disabled.cgColor
        stackView.layer.borderWidth = 1
        stackView.clipsToBounds = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: AppPadding.verticalPadding, left: AppPadding.horizontalPadding, bottom: AppPadding.verticalPadding, right: AppPadding.horizontalPadding)
        return stackView
    }()
    private let locationGuideLabel = UILabel.create(text: "장소 ", font: AppFont.accent, textColor: .border)
    private let dateGuideLabel = UILabel.create(text: "시간 ", font: AppFont.accent, textColor: .border)
    private let capacityGuideLabel = UILabel.create(text: "인원 ", font: AppFont.accent, textColor: .border)
    private let locationIconImageView = UIImageView(image: .location)
    private let dateIconImageView = UIImageView(image: .time)
    private let capacityIconImageView = UIImageView(image: .people)
    private let descriptionGuideLabel = UILabel.create(text: "클래스 소개", font: AppFont.subtitle, textColor: .black)
    private let separatorLine = SeperatorLine()
    
    let imageCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: Constants.deviceWidth, height: Constants.deviceWidth * 0.6)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellClass: ImageCollectionViewCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    let nicknameLabel = UILabel.create(font: AppFont.accent, textColor: .black)
    let locationLabel = UILabel.create(font: AppFont.accent, textColor: .border)
    let dateLabel = UILabel.create(font: AppFont.accent, textColor: .border)
    let capacityLabel = UILabel.create(font: AppFont.accent, textColor: .border)
    let descriptionTextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        textView.typingAttributes = [
            .paragraphStyle: paragraphStyle,
            .font: AppFont.body,
            .foregroundColor: UIColor.darkGray
        ]
        return textView
    }()
    let favoriteButton = {
        let button = FavoriteButton()
        button.setBorder(true)
        return button
    }()
    let showCommentButton = PointButton()
    
    override func draw(_ rect: CGRect) {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    func setProfileImage(image: String?) {
        guard let image else {
            profileImageView.image = .noProfile
            return
        }
        let url = try? Router.fetchImage(url: image).asURL()
        profileImageView.kf.setImage(with: url, options: ImageDownloadHelper.options)
    }
    
    // MARK: Setups
    override func setupView() {
        backgroundColor = .background
    }

    override func setupHierarchy() {
        [imageCollectionView, profileImageView, nicknameLabel, infoStackView, descriptionGuideLabel, descriptionTextView, separatorLine, favoriteButton, showCommentButton].forEach {
            addSubview($0)
        }
        
        let locationStackView = UIStackView(arrangedSubviews: [locationGuideLabel, locationIconImageView, locationLabel])
        let dateStackView = UIStackView(arrangedSubviews: [dateGuideLabel, dateIconImageView, dateLabel])
        let capacityStackView = UIStackView(arrangedSubviews: [capacityGuideLabel, capacityIconImageView, capacityLabel])
        [locationStackView, dateStackView, capacityStackView].forEach { stackView in
            stackView.axis = .horizontal
            stackView.spacing = 4
            stackView.arrangedSubviews.forEach {
                $0.setContentHuggingPriority(.required, for: .horizontal)
            }
            stackView.arrangedSubviews.last?.setContentHuggingPriority(.defaultLow, for: .horizontal)
            infoStackView.addArrangedSubview(stackView)
        }
    }
    
    override func setupLayout() {
        imageCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(imageCollectionView.snp.width).multipliedBy(0.6)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(AppPadding.verticalPadding)
            make.leading.equalToSuperview().offset(AppPadding.horizontalPadding)
            make.size.equalTo(32)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(AppPadding.horizontalInset)
            make.centerY.equalTo(profileImageView)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(AppPadding.verticalPadding)
            make.height.equalTo(108)
            make.horizontalEdges.equalToSuperview().inset(AppPadding.horizontalPadding)
        }
        
        descriptionGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(AppPadding.verticalPadding)
            make.leading.equalToSuperview().offset(AppPadding.horizontalPadding)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionGuideLabel.snp.bottom).offset(AppPadding.verticalPadding)
            make.horizontalEdges.equalToSuperview().inset(AppPadding.horizontalPadding)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(AppPadding.verticalPadding)
            make.horizontalEdges.equalToSuperview()
        }
        
        showCommentButton.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(AppPadding.verticalPadding)
            make.height.equalTo(44)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-AppPadding.verticalPadding)
            make.trailing.equalToSuperview().offset(-AppPadding.horizontalPadding)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(showCommentButton)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalTo(showCommentButton.snp.leading).offset(-40)
            make.height.equalTo(favoriteButton.snp.width)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-AppPadding.verticalPadding)
        }
    }
}
