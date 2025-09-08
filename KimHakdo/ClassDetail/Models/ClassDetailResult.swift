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
}
