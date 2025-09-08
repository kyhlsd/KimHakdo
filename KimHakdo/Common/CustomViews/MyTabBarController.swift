//
//  MyTabBarController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/7/25.
//

import UIKit

final class MyTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupAppearance()
    }
    
    private func setupVC() {
        let lookupNav = MyNavigationController(rootViewController: LookupClassViewController())
        lookupNav.setTabBarItem(title: "카테고리", image: UIImage(systemName: "house.fill"), tag: 0)
        
        let searchNav = MyNavigationController(rootViewController: SearchClassViewController())
        searchNav.setTabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let settingNav = MyNavigationController(rootViewController: SettingViewController())
        settingNav.setTabBarItem(title: "설정", image: UIImage(systemName: "person.fill"), tag: 2)
        
        viewControllers = [lookupNav, searchNav, settingNav]
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        
        appearance.stackedLayoutAppearance.selected.iconColor = .myAccent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.myAccent]
        appearance.stackedLayoutAppearance.normal.iconColor = .disabled
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.disabled]
        appearance.backgroundColor = .background
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
