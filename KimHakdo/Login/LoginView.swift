//
//  LoginView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit
import SnapKit

final class LoginView: BaseView {
    
    let splashImageView = {
        let imageView = UIImageView()
        imageView.image = .splash
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let emailLabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = AppFont.subtitle
        return label
    }()
    
    let passwordLabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = AppFont.subtitle
        return label
    }()
    
    let emailTextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력하세요"
        textField.keyboardType = .emailAddress
        textField.font = AppFont.body
        textField.layer.borderColor = UIColor.primary.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = CornerRadius.small
        textField.clipsToBounds = true
        return textField
    }()
    
    let passwordTextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요"
        textField.isSecureTextEntry = true
        textField.font = AppFont.body
        textField.layer.borderColor = UIColor.primary.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = CornerRadius.small
        textField.clipsToBounds = true
        return textField
    }()
    
    let loginButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.backgroundColor = .primary
        button.titleLabel?.font = AppFont.button
        button.layer.cornerRadius = CornerRadius.small
        button.clipsToBounds = true
        return button
    }()
    
    let warningLabel = {
        let label = UILabel()
        // TODO: Binding 후 삭제
        label.text = "이메일 또는 비밀번호를 입력해주세요."
        label.font = AppFont.warning
        label.textColor = .primary
        label.textAlignment = .center
        return label
    }()
    
    override func setupView() {
        backgroundColor = .background
    }
    
    override func setupHierarchy() {
        [splashImageView, emailLabel, passwordLabel, emailTextField, passwordTextField, loginButton, warningLabel].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        splashImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(120)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(splashImageView.snp.bottom).offset(AppPadding.verticalPadding)
            make.leading.equalToSuperview().offset(AppPadding.horizontalPadding)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(AppPadding.verticalInset)
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview().inset(AppPadding.horizontalPadding)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(AppPadding.verticalPadding)
            make.leading.equalTo(emailLabel)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(AppPadding.verticalInset)
            make.height.horizontalEdges.equalTo(emailTextField)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(AppPadding.verticalPadding)
            make.height.horizontalEdges.equalTo(emailTextField)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(AppPadding.verticalInset)
            make.horizontalEdges.equalTo(loginButton)
        }
    }
}
