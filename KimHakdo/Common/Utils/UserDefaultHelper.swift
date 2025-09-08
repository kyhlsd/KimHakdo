//
//  UserDefaultHelper.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation

enum UserDefaultHelper {
    @UserDefault(key: "Token", type: String.self)
    static var token: String?
    
    @UserDefault(key: "ID", type: String.self)
    static var userId: String?
    
    static func clear() {
        UserDefaults.standard.dictionaryRepresentation().keys.forEach {
            UserDefaults.standard.removeObject(forKey: $0.description)
        }
    }
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let type: T.Type
    
    var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
