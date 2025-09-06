//
//  MyFormatter.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation

enum MyFormatter {
    static let serverDate = {
        let formatter = DateFormatter()
        // 2025-08-28T12:28:48.751Z
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    static let userDate = {
        let formatter = DateFormatter()
        // 2025년 9월 4일 오후 5시
        formatter.dateFormat = "yyyy년 M월 d일 a h시 m분"
        formatter.locale = Locale(identifier: "ko_KR")
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
