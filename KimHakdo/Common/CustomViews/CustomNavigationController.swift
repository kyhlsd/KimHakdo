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

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .gray
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.myAccent,
            .font: AppFont.navTitle
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = .black
        
        view.backgroundColor = .background
    }

    func setTabBarItem(title: String, image: UIImage?, tag: Int) {
        tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
    }
}
