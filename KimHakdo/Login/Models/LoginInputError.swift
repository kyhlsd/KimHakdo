//
//  LoginInputError.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation

enum LoginInputError: LocalizedError, Equatable {
    case invalidEmail
    case invalidPasswordRange(min: Int, max: Int)
    case empty
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "@와 .com, 사이에 1자 이상의 문자를 포함해주세요."
        case .invalidPasswordRange(let min, let max):
            return "비밀번호는 \(min)글자 이상 \(max)글자 미만으로 설정해주세요."
        case .empty:
            return "이메일과 비밀번호를 입력해주세요."
        case .unknown:
            return "알 수 없는 에러가 발생했습니다."
        }
    }
}
