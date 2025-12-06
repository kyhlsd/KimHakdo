//
//  Creator.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/8/25.
//

import Foundation

struct Creator: Decodable, Hashable {
    let userId: String
    let nick: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick
        case profileImage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
    }
    
    init(userId: String, nick: String, profileImage: String?) {
        self.userId = userId
        self.nick = nick
        self.profileImage = profileImage
    }
    
    static let dummy = Creator(userId: "dummy Creator Id", nick: "dummy Creator nick", profileImage: nil)
}
