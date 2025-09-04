//
//  CourseSortOption.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation

enum CourseSortOption: String, CaseIterable {
    case latest = "최신순"
    case highPrice = "금액 높은 순"
    
    var toggled: Self {
        switch self {
        case .latest:
            return .highPrice
        case .highPrice:
            return .latest
        }
    }
}
