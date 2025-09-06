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
        setup()
    }
    
    private func setup() {
        let lookupNav = MyNavigationController(rootViewController: LookupClassViewController())
        lookupNav.setTabBarItem(title: "카테고리", image: UIImage(systemName: "house.fill"), tag: 0)
        
        let searchNav = MyNavigationController(rootViewController: SearchClassViewController())
        searchNav.setTabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let settingNav = MyNavigationController(rootViewController: SettingViewController())
        settingNav.setTabBarItem(title: "설정", image: UIImage(systemName: "person.fill"), tag: 2)
        
        viewControllers = [lookupNav, searchNav, settingNav]
    }
}
