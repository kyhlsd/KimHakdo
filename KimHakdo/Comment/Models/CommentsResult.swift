//
//  CommentsResult.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation

struct CommentsResult: Decodable {
    let data: [Comment]

    init(data: [Comment]) {
        self.data = data
    }

    static let dummy = CommentsResult(data: Comment.allDummies)
}

struct Comment: Decodable {
    let commentId: String
    let content: String
    let createdAt: Date
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content
        case createdAt = "created_at"
        case creator
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.content = try container.decode(String.self, forKey: .content)
        let createdAt = try container.decode(String.self, forKey: .createdAt)
        self.createdAt = MyFormatter.serverDate.date(from: createdAt) ?? Date()
        self.creator = try container.decode(Creator.self, forKey: .creator)
    }

    init(commentId: String, content: String, createdAt: Date, creator: Creator) {
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.creator = creator
    }

    static let dummy1 = Comment(
        commentId: "comment_001",
        content: "강의 정말 유익했습니다! 초보자도 이해하기 쉽게 설명해주셔서 좋았어요.",
        createdAt: Date().addingTimeInterval(-3600 * 24 * 2),
        creator: Creator(userId: "user_101", nick: "초보가드너", profileImage: "https://picsum.photos/100/100?random=20")
    )

    static let dummy2 = Comment(
        commentId: "comment_002",
        content: "수업 시간이 어떻게 되나요? 평일 저녁 시간에도 수강 가능한가요?",
        createdAt: Date().addingTimeInterval(-3600 * 24 * 1),
        creator: Creator(userId: "user_102", nick: "직장인김", profileImage: "https://picsum.photos/100/100?random=21")
    )

    static let dummy3 = Comment(
        commentId: "comment_003",
        content: "과제가 많은 편인가요? 수강 신청 고민 중입니다.",
        createdAt: Date().addingTimeInterval(-3600 * 20),
        creator: Creator(userId: "user_103", nick: "꿈꾸는학생", profileImage: nil)
    )

    static let dummy4 = Comment(
        commentId: "comment_004",
        content: "선생님 정말 친절하시고 질문에도 성심성의껏 답변해주셨어요. 추천합니다!",
        createdAt: Date().addingTimeInterval(-3600 * 18),
        creator: Creator(userId: "user_104", nick: "프로수강생", profileImage: "https://picsum.photos/100/100?random=22")
    )

    static let dummy5 = Comment(
        commentId: "comment_005",
        content: "커리큘럼이 체계적이어서 단계별로 학습하기 좋았습니다.",
        createdAt: Date().addingTimeInterval(-3600 * 15),
        creator: Creator(userId: "user_105", nick: "지망생", profileImage: "https://picsum.photos/100/100?random=23")
    )

    static let dummy6 = Comment(
        commentId: "comment_006",
        content: "완전 초보인데 따라갈 수 있을까요? 사전 지식이 필요한가요?",
        createdAt: Date().addingTimeInterval(-3600 * 12),
        creator: Creator(userId: "user_106", nick: "비전공자", profileImage: "https://picsum.photos/100/100?random=24")
    )

    static let dummy7 = Comment(
        commentId: "comment_007",
        content: "실습 위주로 진행되어서 실력 향상에 많은 도움이 되었습니다. 감사합니다!",
        createdAt: Date().addingTimeInterval(-3600 * 10),
        creator: Creator(userId: "user_107", nick: "실습러버", profileImage: nil)
    )

    static let dummy8 = Comment(
        commentId: "comment_008",
        content: "환불 정책이 어떻게 되나요? 궁금합니다.",
        createdAt: Date().addingTimeInterval(-3600 * 8),
        creator: Creator(userId: "user_108", nick: "신중한선택", profileImage: "https://picsum.photos/100/100?random=25")
    )

    static let dummy9 = Comment(
        commentId: "comment_009",
        content: "이 강의 듣고 나서 실제 프로젝트에 바로 적용할 수 있었어요. 강력 추천!",
        createdAt: Date().addingTimeInterval(-3600 * 6),
        creator: Creator(userId: "user_109", nick: "실전파", profileImage: "https://picsum.photos/100/100?random=26")
    )

    static let dummy10 = Comment(
        commentId: "comment_010",
        content: "강의 자료는 별도로 제공되나요? PDF나 슬라이드 같은 거요.",
        createdAt: Date().addingTimeInterval(-3600 * 5),
        creator: Creator(userId: "user_110", nick: "자료수집가", profileImage: nil)
    )

    static let dummy11 = Comment(
        commentId: "comment_011",
        content: "다음 기수는 언제 모집하시나요? 이번 기수는 놓쳤네요 ㅠㅠ",
        createdAt: Date().addingTimeInterval(-3600 * 3),
        creator: Creator(userId: "user_111", nick: "늦은새", profileImage: "https://picsum.photos/100/100?random=27")
    )

    static let dummy12 = Comment(
        commentId: "comment_012",
        content: "온라인으로도 수강 가능한가요? 지방에 살고 있어서요.",
        createdAt: Date().addingTimeInterval(-3600 * 2),
        creator: Creator(userId: "user_112", nick: "부산촌놈", profileImage: "https://picsum.photos/100/100?random=28")
    )

    static let dummy13 = Comment(
        commentId: "comment_013",
        content: "완강했습니다! 정말 알찬 강의였어요. 다음 심화 과정도 기대됩니다.",
        createdAt: Date().addingTimeInterval(-3600),
        creator: Creator(userId: "user_113", nick: "완강왕", profileImage: "https://picsum.photos/100/100?random=29")
    )

    static let dummy14 = Comment(
        commentId: "comment_014",
        content: "강의 속도가 적당해서 좋았어요. 복습 시간도 충분히 주시고요.",
        createdAt: Date().addingTimeInterval(-1800),
        creator: Creator(userId: "user_114", nick: "꼼꼼이", profileImage: nil)
    )

    static let dummy15 = Comment(
        commentId: "comment_015",
        content: "수강료 대비 퀄리티 최고입니다. 돈이 아깝지 않네요!",
        createdAt: Date().addingTimeInterval(-900),
        creator: Creator(userId: "user_115", nick: "가성비킹", profileImage: "https://picsum.photos/100/100?random=30")
    )

    static let allDummies: [Comment] = [
        dummy1, dummy2, dummy3, dummy4, dummy5,
        dummy6, dummy7, dummy8, dummy9, dummy10,
        dummy11, dummy12, dummy13, dummy14, dummy15
    ]
}
