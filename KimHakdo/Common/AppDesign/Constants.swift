//
//  Constants.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit

enum Constants {
    static let deviceWidth: CGFloat = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return 0 }
        return window.screen.bounds.width
    }()
    
    static let deviceScale: CGFloat = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return 0 }
        return window.screen.scale
    }()
}
