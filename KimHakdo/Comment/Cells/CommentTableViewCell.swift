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

    // MARK: Views
    let profileImageView = {
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
        timeLabel.text = getTimeDifference(date: data.createdAt)
        contentLabel.attributedText = NSAttributedString(string: data.content, attributes: attributes)
    }
    
    private func setProfileImage(image: String?) {
        guard let image else {
            profileImageView.image = .noProfile
            return
        }
        switch AppConfig.current {
        case .dev:
            let url = try? Router.fetchImage(url: image).asURL()
            profileImageView.kf.setImage(with: url, options: ImageDownloadHelper.options)
        case .dummy:
            let url = URL(string: image)
            profileImageView.kf.setImage(with: url)
        }
    }
    
    private func getTimeDifference(date: Date) -> String {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: Date())
        
        // 일주일 이상 차이 난다면 날짜 표기
        var result = MyFormatter.userDate.string(from: date)
        guard let dayDiff = components.day, dayDiff < 7 else {
            return result
        }
        
        // 하루 이상 차이 난다면 며칠 전인지 표기
        result = "\(dayDiff)일 전"
        guard let hourDiff = components.hour, dayDiff < 1 else {
            return result
        }
        
        // 한 시간 이상 차이 난다면 몇 시간 전인지 표기
        result = "\(hourDiff)시간 전"
        guard let minDiff = components.minute, hourDiff < 1 else {
            return result
        }
        
        // 한 시간 이내라면 몇 분 전인지 표기
        return "\(minDiff)분 전"
    }
    
    // MARK: Setups
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
            make.height.lessThanOrEqualTo(500)
        }
    }
}
