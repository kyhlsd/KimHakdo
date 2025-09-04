//
//  AppFormatter.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation

enum AppFormatter {
    static let date = {
        let formatter = DateFormatter()
        // 2025-08-28T12:28:48.751Z
        formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss.SSSZ"
        return formatter
    }()
    
    static let percent = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    static let number = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
