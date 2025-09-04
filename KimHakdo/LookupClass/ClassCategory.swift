//
//  ClassCategory.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation

enum ClassCategory: Int, CaseIterable, Decodable {
    case total = 0
    case development = 101
    case design = 102
    case foreignLanguage = 201
    case life = 202
    case beauty = 203
    case investment = 301
    case other = 900
    
    var description: String {
        switch self {
        case .total:
            return "전체"
        case .development:
            return "개발"
        case .design:
            return "디자인"
        case .foreignLanguage:
            return "외국어"
        case .life:
            return "라이프"
        case .beauty:
            return "뷰티"
        case .investment:
            return "제테크"
        case .other:
            return "기타"
        }
    }
}
