//
//  SeperatorLine.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit
import SnapKit

final class SeperatorLine: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .opaqueSeparator
        snp.makeConstraints { make in
            make.height.equalTo(0.5)
        }
    }
}
