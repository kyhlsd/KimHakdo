//
//  NotificationManager.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/8/25.
//

import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    private let isLikedChangedName = Notification.Name("isLikedChanged")
    
    func postIsLikedChanged(classId: String, isLiked: Bool) {
        NotificationCenter.default.post(name: isLikedChangedName, object: nil, userInfo: [
            "classId": classId,
            "isLiked": isLiked
        ])
    }
    
    func receiveIsLikcedChanged(receiveHandler: @escaping (String, Bool) -> ()) {
        NotificationCenter.default.addObserver(forName: isLikedChangedName, object: nil, queue: .main) { notification in
            if let userInfo = notification.userInfo,
               let classId = userInfo["classId"] as? String,
               let isLiked = userInfo["isLiked"] as? Bool {
                receiveHandler(classId, isLiked)
            }
        }
    }
}
