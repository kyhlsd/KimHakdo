//
//  FavoriteButton.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit
import SnapKit

final class FavoriteButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStatus(isFavorited: Bool) {
        setImage(isFavorited ? .likeButtonFill : .likeButton, for: .normal)
    }
    
    private func setup() {
        snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
}
