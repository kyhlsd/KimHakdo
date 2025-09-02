//
//  PointTextField.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit

final class PointTextField: UITextField {

    private let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        font = AppFont.body
        layer.borderColor = UIColor.secondaryPoint.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = CornerRadius.small
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
