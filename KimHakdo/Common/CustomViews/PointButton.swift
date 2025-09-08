//
//  PointButton.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit
import RxSwift
import RxCocoa

final class PointButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_ isEnabled: Bool) {
        backgroundColor = isEnabled ? .point : .disabled
    }
    
    private func setup() {
        titleLabel?.font = AppFont.button
        layer.cornerRadius = CornerRadius.small
        clipsToBounds = true
    }
}
