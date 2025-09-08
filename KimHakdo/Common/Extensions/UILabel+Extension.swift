//
//  UILabel+Extension.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit

extension UILabel {
    
    static func create(text: String? = nil, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
    }
    
}
