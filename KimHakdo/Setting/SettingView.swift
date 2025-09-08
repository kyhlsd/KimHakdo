//
//  SettingView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import UIKit
import SnapKit

final class SettingView: BaseView {
    
    // MARK: Views
    let logoutButton = {
        let button = PointButton()
        button.setTitle("로그아웃", for: .normal)
        button.setColor(true)
        return button
    }()
    
    // MARK: Setups
    override func setupView() {
        backgroundColor = .background
    }
    
    override func setupHierarchy() {
        addSubview(logoutButton)
    }
    
    override func setupLayout() {
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppPadding.verticalPadding)
            make.horizontalEdges.equalToSuperview().inset(AppPadding.horizontalPadding)
            make.height.equalTo(44)
        }
    }
}
