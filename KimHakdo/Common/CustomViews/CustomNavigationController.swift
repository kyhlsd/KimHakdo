//
//  CustomNavigationController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit

final class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.shadowColor = .gray
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.myAccent,
            .font: AppFont.navTitle
        ]
        
        navigationBar.standardAppearance = navAppearance
        navigationBar.scrollEdgeAppearance = navAppearance
        navigationBar.tintColor = .black
        
        view.backgroundColor = .background
    }

    func setTabBarItem(title: String, image: UIImage?, tag: Int) {
        tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
    }
}
