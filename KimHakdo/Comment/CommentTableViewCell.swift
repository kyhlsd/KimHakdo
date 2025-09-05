//
//  CommentTableViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit
import SnapKit
import Kingfisher

class CommentTableViewCell: BaseTableViewCell<Comment> {

    private let profileImageView = {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let nicknameLabel = UILabel.create(font: AppFont.accent, textColor: .black)
    private let timeLabel = UILabel.create(font: AppFont.caption, textColor: .gray)
    private let contentLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let attributes: [NSAttributedString.Key: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        return [
            .paragraphStyle: paragraphStyle,
            .font: AppFont.body,
            .foregroundColor: UIColor.darkGray
        ]
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    override func setData(data: Comment) {
        setProfileImage(image: data.creator.profileImage)
        nicknameLabel.text = data.creator.nick
        setTimeLabel(date: data.createdAt)
        contentLabel.attributedText = NSAttributedString(string: data.content, attributes: attributes)
    }
    
    private func setProfileImage(image: String?) {
        guard let image else {
            profileImageView.image = .noProfile
            return
        }
        let url = try? Router.fetchImage(url: image).asURL()
        profileImageView.kf.setImage(with: url, options: ImageDownloadHelper.options)
    }
    
    private func setTimeLabel(date: Date) {
        timeLabel.text = "45분 전"
    }
    
    override func setupView() {
        contentView.backgroundColor = .clear
    }
    
    override func setupHierarchy() {
        [profileImageView, nicknameLabel, timeLabel, contentLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppPadding.verticalPadding)
            make.leading.equalToSuperview().offset(AppPadding.horizontalPadding)
            make.size.equalTo(40)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(AppPadding.horizontalInset)
            make.bottom.equalTo(profileImageView.snp.centerY)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(nicknameLabel)
            make.top.equalTo(profileImageView.snp.centerY)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(nicknameLabel)
            make.trailing.equalToSuperview().offset(-AppPadding.horizontalPadding)
            make.top.equalTo(profileImageView.snp.bottom).offset(AppPadding.verticalInset)
            make.bottom.equalToSuperview().offset(-AppPadding.verticalPadding)
        }
    }
}
