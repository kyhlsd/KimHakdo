//
//  PointButton.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit

final class PointButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        titleLabel?.font = AppFont.button
        layer.cornerRadius = CornerRadius.small
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func getColor(_ isEnabled: Bool) -> UIColor {
        isEnabled ? .point : .disabled
    }
}
