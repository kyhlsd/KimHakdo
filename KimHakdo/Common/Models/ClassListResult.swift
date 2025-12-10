//
//  ClassListResult.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation

struct ClassListResult: Decodable {
    let data: [ClassResult]

    static let dummy = [
        ClassResult(
            classId: "class_001",
            category: .development,
            title: "초보자를 위한 Swift 프로그래밍",
            description: "Swift 언어의 기초부터 실전 앱 개발까지 배우는 종합 과정입니다.",
            imageURL: "https://picsum.photos/400/300?random=1",
            createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_001", nick: "SwiftMaster", profileImage: "https://picsum.photos/100/100?random=10"),
            price: 150000,
            salePrice: 120000
        ),
        ClassResult(
            classId: "class_002",
            category: .foreignLanguage,
            title: "비즈니스 영어 회화 마스터",
            description: "실무에서 바로 사용 가능한 비즈니스 영어 표현과 회화를 학습합니다.",
            imageURL: "https://picsum.photos/400/300?random=2",
            createdAt: Date().addingTimeInterval(-20 * 24 * 60 * 60),
            isLiked: true,
            creator: Creator(userId: "user_002", nick: "EnglishPro", profileImage: "https://picsum.photos/100/100?random=11"),
            price: 200000,
            salePrice: 170000
        ),
        ClassResult(
            classId: "class_003",
            category: .design,
            title: "UI/UX 디자인 기초부터 실전까지",
            description: "사용자 중심의 디자인 사고방식을 배우고 Figma를 활용한 실습을 진행합니다.",
            imageURL: "https://picsum.photos/400/300?random=3",
            createdAt: Date().addingTimeInterval(-10 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_003", nick: "디자인왕", profileImage: nil),
            price: 180000,
            salePrice: nil
        ),
        ClassResult(
            classId: "class_004",
            category: .life,
            title: "힐링 요가 클래스",
            description: "스트레스 해소와 몸의 균형을 찾는 요가 수업입니다.",
            imageURL: "https://picsum.photos/400/300?random=4",
            createdAt: Date().addingTimeInterval(-5 * 24 * 60 * 60),
            isLiked: true,
            creator: Creator(userId: "user_004", nick: "요가쌤", profileImage: "https://picsum.photos/100/100?random=12"),
            price: 80000,
            salePrice: 60000
        ),
        ClassResult(
            classId: "class_005",
            category: .investment,
            title: "주식 투자 입문 강좌",
            description: "주식 투자의 기본 개념부터 차트 분석, 종목 선정 방법까지 배우는 강좌입니다.",
            imageURL: "https://picsum.photos/400/300?random=5",
            createdAt: Date().addingTimeInterval(-15 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_005", nick: "재테크전문가", profileImage: "https://picsum.photos/100/100?random=13"),
            price: 250000,
            salePrice: 200000
        ),
        ClassResult(
            classId: "class_006",
            category: .beauty,
            title: "메이크업 아티스트 양성 과정",
            description: "기초 메이크업부터 특수 분장까지, 전문 메이크업 아티스트가 되기 위한 완벽한 커리큘럼입니다.",
            imageURL: "https://picsum.photos/400/300?random=6",
            createdAt: Date().addingTimeInterval(-25 * 24 * 60 * 60),
            isLiked: true,
            creator: Creator(userId: "user_006", nick: "뷰티전문가", profileImage: "https://picsum.photos/100/100?random=14"),
            price: 300000,
            salePrice: 270000
        ),
        ClassResult(
            classId: "class_007",
            category: .development,
            title: "React 웹 개발 마스터클래스",
            description: "React를 활용한 현대적인 웹 애플리케이션 개발을 배웁니다.",
            imageURL: "https://picsum.photos/400/300?random=7",
            createdAt: Date().addingTimeInterval(-12 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_007", nick: "웹개발자", profileImage: "https://picsum.photos/100/100?random=15"),
            price: 180000,
            salePrice: 150000
        ),
        ClassResult(
            classId: "class_008",
            category: .foreignLanguage,
            title: "중국어 회화 기초반",
            description: "중국어를 처음 시작하는 분들을 위한 발음부터 기본 회화까지 학습합니다.",
            imageURL: "https://picsum.photos/400/300?random=8",
            createdAt: Date().addingTimeInterval(-8 * 24 * 60 * 60),
            isLiked: true,
            creator: Creator(userId: "user_008", nick: "차이나마스터", profileImage: nil),
            price: 120000,
            salePrice: 100000
        ),
        ClassResult(
            classId: "class_009",
            category: .design,
            title: "포토샵 실무 마스터",
            description: "포토샵의 모든 기능을 활용한 실무 프로젝트 중심 수업입니다.",
            imageURL: "https://picsum.photos/400/300?random=9",
            createdAt: Date().addingTimeInterval(-18 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_009", nick: "포토샵고수", profileImage: "https://picsum.photos/100/100?random=16"),
            price: 150000,
            salePrice: nil
        ),
        ClassResult(
            classId: "class_010",
            category: .life,
            title: "홈베이킹 클래스",
            description: "집에서 쉽게 만들 수 있는 베이킹 레시피를 배웁니다.",
            imageURL: "https://picsum.photos/400/300?random=10",
            createdAt: Date().addingTimeInterval(-3 * 24 * 60 * 60),
            isLiked: true,
            creator: Creator(userId: "user_010", nick: "베이킹마스터", profileImage: "https://picsum.photos/100/100?random=17"),
            price: nil,
            salePrice: nil
        ),
        ClassResult(
            classId: "class_011",
            category: .beauty,
            title: "네일아트 기초 과정",
            description: "셀프 네일아트의 기초부터 젤네일까지 배우는 과정입니다.",
            imageURL: "https://picsum.photos/400/300?random=11",
            createdAt: Date().addingTimeInterval(-22 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_011", nick: "네일아티스트", profileImage: "https://picsum.photos/100/100?random=18"),
            price: 90000,
            salePrice: 75000
        ),
        ClassResult(
            classId: "class_012",
            category: .investment,
            title: "부동산 투자 전략",
            description: "부동산 시장 분석부터 수익형 부동산 투자 전략까지 배웁니다.",
            imageURL: "https://picsum.photos/400/300?random=12",
            createdAt: Date().addingTimeInterval(-6 * 24 * 60 * 60),
            isLiked: true,
            creator: Creator(userId: "user_012", nick: "부동산전문가", profileImage: nil),
            price: 350000,
            salePrice: 300000
        ),
        ClassResult(
            classId: "class_013",
            category: .development,
            title: "Python 데이터 분석",
            description: "Python을 활용한 데이터 분석 및 시각화 기법을 학습합니다.",
            imageURL: "https://picsum.photos/400/300?random=13",
            createdAt: Date().addingTimeInterval(-14 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_013", nick: "데이터과학자", profileImage: "https://picsum.photos/100/100?random=19"),
            price: 200000,
            salePrice: 180000
        ),
        ClassResult(
            classId: "class_014",
            category: .foreignLanguage,
            title: "일본어 JLPT N2 준비반",
            description: "JLPT N2 시험 합격을 위한 체계적인 학습 프로그램입니다.",
            imageURL: "https://picsum.photos/400/300?random=14",
            createdAt: Date().addingTimeInterval(-28 * 24 * 60 * 60),
            isLiked: true,
            creator: Creator(userId: "user_014", nick: "일본어선생님", profileImage: "https://picsum.photos/100/100?random=20"),
            price: 160000,
            salePrice: 140000
        ),
        ClassResult(
            classId: "class_015",
            category: .life,
            title: "가드닝 입문 클래스",
            description: "실내 식물부터 베란다 정원 가꾸기까지 배우는 가드닝 수업입니다.",
            imageURL: "https://picsum.photos/400/300?random=15",
            createdAt: Date().addingTimeInterval(-1 * 24 * 60 * 60),
            isLiked: false,
            creator: Creator(userId: "user_015", nick: "식물집사", profileImage: nil),
            price: 70000,
            salePrice: 60000
        ),
    ]
}

struct ClassResult: Decodable, Hashable {
    let classId: String
    let category: ClassCategory
    let title: String
    let description: String
    let imageURL: String
    let createdAt: Date
    var isLiked: Bool
    let creator: Creator
    let price: Int?
    let salePrice: Int?
    
    var salePercentage: String? {
        guard let price, price != 0 else {
            return "무료"
        }
        guard let salePrice else {
            return nil
        }
        
        let ratio = NSNumber(value: 1 - (Float(salePrice) / Float(price)))
        return MyFormatter.percent.string(from: ratio)
    }
    
    enum CodingKeys: String, CodingKey {
        case classId = "class_id"
        case category
        case title
        case description
        case imageURL = "image_url"
        case createdAt = "created_at"
        case isLiked = "is_liked"
        case creator
        case price
        case salePrice = "sale_price"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.classId = try container.decode(String.self, forKey: .classId)
        let categoryNumber = try container.decode(Int.self, forKey: .category)
        self.category = ClassCategory(rawValue: categoryNumber) ?? .other
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        let createdAt = try container.decode(String.self, forKey: .createdAt)
        self.createdAt = MyFormatter.serverDate.date(from: createdAt) ?? Date()
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
        self.creator = try container.decode(Creator.self, forKey: .creator)
        self.price = try container.decodeIfPresent(Int.self, forKey: .price)
        self.salePrice = try container.decodeIfPresent(Int.self, forKey: .salePrice)
    }
    
    init(classId: String, category: ClassCategory, title: String, description: String, imageURL: String, createdAt: Date, isLiked: Bool, creator: Creator, price: Int?, salePrice: Int?) {
        self.classId = classId
        self.category = category
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.isLiked = isLiked
        self.creator = creator
        self.price = price
        self.salePrice = salePrice
    }
}
