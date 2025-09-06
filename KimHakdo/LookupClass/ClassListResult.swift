//
//  ClassListResult.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation

struct ClassListResult: Decodable {
    let data: [ClassResult]
}

struct ClassResult: Decodable {
    let classId: String
    let category: ClassCategory
    let title: String
    let description: String
    let imageURL: String
    let createdAt: Date
    let isLiked: Bool
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
}

struct Creator: Decodable {
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
}
