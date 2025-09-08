//
//  CommentsResult.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation

struct CommentsResult: Decodable {
    let data: [Comment]
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
}
