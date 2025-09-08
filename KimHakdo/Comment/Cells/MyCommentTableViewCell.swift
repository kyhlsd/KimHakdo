//
//  MyCommentTableViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyCommentTableViewCell: CommentTableViewCell {
    
    private var disposeBag = DisposeBag()
    
    // MARK: Views
    private let moreButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setData(data: Comment, to: PublishRelay<Comment>) {
        super.setData(data: data)
        
        moreButton.rx.tap
            .map { _ in data }
            .bind(to: to)
            .disposed(by: disposeBag)
    }
    
    // MARK: Setups
    override func setupHierarchy() {
        super.setupHierarchy()
        contentView.addSubview(moreButton)
    }
    
    override func setupLayout() {
        super.setupLayout()
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.trailing.equalToSuperview().offset(-AppPadding.horizontalPadding)
        }
    }
}
