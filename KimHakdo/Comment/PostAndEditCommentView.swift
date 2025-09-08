//
//  PostAndEditCommentView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit
import SnapKit

final class PostAndEditCommentView: BaseView {
    
    // MARK: Views
    private let categoryContainer = {
        let view = UIView()
        view.layer.borderColor = UIColor.point.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = CornerRadius.small
        view.clipsToBounds = true
        return view
    }()
    
    let categoryLabel = UILabel.create(font: AppFont.caption, textColor: .point)
    let titleLabel = UILabel.create(font: AppFont.subtitle, textColor: .black)
    let textView = {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.layer.borderColor = UIColor.border.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = CornerRadius.medium
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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
    let countLabel = UILabel.create(font: AppFont.accent, textColor: .darkGray)
    
    // MARK: Setups
    override func setupView() {
        backgroundColor = .background
    }
    
    override func setupHierarchy() {
        [categoryContainer, titleLabel, textView, countLabel].forEach {
            addSubview($0)
        }
        categoryContainer.addSubview(categoryLabel)
    }
    
    override func setupLayout() {
        categoryContainer.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppPadding.verticalPadding)
            make.leading.equalToSuperview().offset(AppPadding.horizontalPadding)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(2)
            make.horizontalEdges.equalToSuperview().inset(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryContainer.snp.bottom).offset(AppPadding.verticalInset)
            make.leading.equalTo(categoryContainer)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppPadding.verticalPadding)
            make.horizontalEdges.equalToSuperview().inset(AppPadding.horizontalPadding)
            make.height.equalTo(260)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(AppPadding.verticalInset)
            make.trailing.equalTo(textView)
        }
    }
}
