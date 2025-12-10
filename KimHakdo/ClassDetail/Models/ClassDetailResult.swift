//
//  ClassDetailResult.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation

struct ClassDetailResult: Decodable {
    let classId: String
    let category: ClassCategory
    let title: String
    let description: String
    let price: Int?
    let salePrice: Int?
    let location: String?
    let date: Date?
    let capacity: Int?
    let imageURLs: [String]
    let createdAt: Date
    let isLiked: Bool
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case classId = "class_id"
        case category
        case title
        case description
        case price
        case salePrice = "sale_price"
        case location
        case date
        case capacity
        case imageURLs = "image_urls"
        case createdAt = "created_at"
        case isLiked = "is_liked"
        case creator
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.classId = try container.decode(String.self, forKey: .classId)
        let categoryNumber = try container.decode(Int.self, forKey: .category)
        self.category = ClassCategory(rawValue: categoryNumber) ?? .other
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decodeIfPresent(Int.self, forKey: .price)
        self.salePrice = try container.decodeIfPresent(Int.self, forKey: .salePrice)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        let date = try container.decodeIfPresent(String.self, forKey: .date)
        if let date {
            self.date = MyFormatter.serverDate.date(from: date) ?? Date()
        } else {
            self.date = nil
        }
        self.capacity = try container.decodeIfPresent(Int.self, forKey: .capacity)
        self.imageURLs = try container.decode([String].self, forKey: .imageURLs)
        let createdAt = try container.decode(String.self, forKey: .createdAt)
        self.createdAt = MyFormatter.serverDate.date(from: createdAt) ?? Date()
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
        self.creator = try container.decode(Creator.self, forKey: .creator)
    }

    init(
        classId: String,
        category: ClassCategory,
        title: String,
        description: String,
        price: Int?,
        salePrice: Int?,
        location: String?,
        date: Date?,
        capacity: Int?,
        imageURLs: [String],
        createdAt: Date,
        isLiked: Bool,
        creator: Creator
    ) {
        self.classId = classId
        self.category = category
        self.title = title
        self.description = description
        self.price = price
        self.salePrice = salePrice
        self.location = location
        self.date = date
        self.capacity = capacity
        self.imageURLs = imageURLs
        self.createdAt = createdAt
        self.isLiked = isLiked
        self.creator = creator
    }

    static let dummySwift = ClassDetailResult(
        classId: "class_001",
        category: .development,
        title: "초보자를 위한 Swift 프로그래밍",
        description: "Swift 언어의 기초부터 실전 앱 개발까지 배우는 종합 과정입니다. iOS 개발에 필요한 핵심 개념과 실습을 통해 실력을 향상시킬 수 있습니다.",
        price: 150000,
        salePrice: 120000,
        location: "서울시 강남구 테헤란로 123",
        date: Date().addingTimeInterval(7 * 24 * 60 * 60),
        capacity: 20,
        imageURLs: [
            "Gardening"
        ],
        createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60),
        isLiked: false,
        creator: Creator(userId: "user_001", nick: "SwiftMaster", profileImage: "noProfileImage")
    )

    static let dummyEnglish = ClassDetailResult(
        classId: "class_002",
        category: .foreignLanguage,
        title: "비즈니스 영어 회화 마스터",
        description: "실무에서 바로 사용 가능한 비즈니스 영어 표현과 회화를 학습합니다. 프레젠테이션, 이메일 작성, 전화 응대 등 다양한 상황별 영어를 익힐 수 있습니다.",
        price: 200000,
        salePrice: 170000,
        location: "서울시 서초구 서초대로 456",
        date: Date().addingTimeInterval(14 * 24 * 60 * 60),
        capacity: 15,
        imageURLs: [
            "Gardening"
        ],
        createdAt: Date().addingTimeInterval(-20 * 24 * 60 * 60),
        isLiked: true,
        creator: Creator(userId: "user_002", nick: "EnglishPro", profileImage: "noProfileImage")
    )

    static let dummyDesign = ClassDetailResult(
        classId: "class_003",
        category: .design,
        title: "UI/UX 디자인 기초부터 실전까지",
        description: "사용자 중심의 디자인 사고방식을 배우고 Figma를 활용한 실습을 진행합니다. 포트폴리오 제작까지 함께 진행됩니다.",
        price: 180000,
        salePrice: nil,
        location: "온라인 (Zoom)",
        date: Date().addingTimeInterval(21 * 24 * 60 * 60),
        capacity: 25,
        imageURLs: [
            "Gardening"
        ],
        createdAt: Date().addingTimeInterval(-10 * 24 * 60 * 60),
        isLiked: false,
        creator: Creator(userId: "user_003", nick: "디자인왕", profileImage: nil)
    )

    static let dummyYoga = ClassDetailResult(
        classId: "class_004",
        category: .life,
        title: "힐링 요가 클래스",
        description: "스트레스 해소와 몸의 균형을 찾는 요가 수업입니다. 초보자도 쉽게 따라할 수 있는 동작으로 구성되어 있습니다.",
        price: 80000,
        salePrice: 60000,
        location: "서울시 마포구 월드컵북로 789",
        date: nil,
        capacity: 12,
        imageURLs: [
            "Yoga"
        ],
        createdAt: Date().addingTimeInterval(-5 * 24 * 60 * 60),
        isLiked: true,
        creator: Creator(userId: "user_004", nick: "요가쌤", profileImage: "noProfileImage")
    )

    static let dummyInvestment = ClassDetailResult(
        classId: "class_005",
        category: .investment,
        title: "주식 투자 입문 강좌",
        description: "주식 투자의 기본 개념부터 차트 분석, 종목 선정 방법까지 배우는 강좌입니다. 실전 투자 전략도 함께 공유됩니다.",
        price: 250000,
        salePrice: 200000,
        location: "서울시 영등포구 여의대로 321",
        date: Date().addingTimeInterval(10 * 24 * 60 * 60),
        capacity: 30,
        imageURLs: [
            "Gardening"        ],
        createdAt: Date().addingTimeInterval(-15 * 24 * 60 * 60),
        isLiked: false,
        creator: Creator(userId: "user_005", nick: "재테크전문가", profileImage: "noProfileImage")
    )

    static let allDummies: [ClassDetailResult] = [
        dummySwift,
        dummyEnglish,
        dummyDesign,
        dummyYoga,
        dummyInvestment
    ]
}
