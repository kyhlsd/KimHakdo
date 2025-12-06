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
        ClassResult(classId: "1", category: .beauty, title: "beauty Title", description: "beauty Description", imageURL: "", createdAt: Date(), isLiked: true, creator: .dummy, price: nil, salePrice: nil),
        ClassResult(classId: "2", category: .design, title: "design Title", description: "design Description", imageURL: "", createdAt: Date(), isLiked: true, creator: .dummy, price: nil, salePrice: nil),
        ClassResult(classId: "3", category: .development, title: "development Title", description: "development Description", imageURL: "", createdAt: Date(), isLiked: true, creator: .dummy, price: nil, salePrice: nil),
        ClassResult(classId: "4", category: .foreignLanguage, title: "foreignLanguage Title", description: "foreignLanguage Description", imageURL: "", createdAt: Date(), isLiked: true, creator: .dummy, price: nil, salePrice: nil),
        ClassResult(classId: "5", category: .beauty, title: "beauty2 Title", description: "beauty2 Description", imageURL: "", createdAt: Date(), isLiked: true, creator: .dummy, price: nil, salePrice: nil),
        ClassResult(classId: "6", category: .beauty, title: "beauty3 Title", description: "beauty3 Description", imageURL: "", createdAt: Date(), isLiked: true, creator: .dummy, price: nil, salePrice: nil),
        ClassResult(classId: "7", category: .investment, title: "investment Title", description: "investment Description", imageURL: "", createdAt: Date(), isLiked: true, creator: .dummy, price: nil, salePrice: nil),
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
