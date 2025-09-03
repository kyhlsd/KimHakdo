//
//  LoginViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController, BaseViewController {
    
    let mainView = LoginView()
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func bind() {
        let input = LoginViewModel.Input(
            email: mainView.emailTextField.rx.text,
            password: mainView.passwordTextField.rx.text,
            buttonTap: mainView.loginButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.buttonEnabled
            .bind(to: mainView.loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.buttonEnabled
            .map { PointButton.getColor($0) }
            .bind(to: mainView.loginButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        output.firstResponder
            .bind(with: self) { owner, _ in
                owner.mainView.emailTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
        
        output.warningText
            .distinctUntilChanged()
            .bind(to: mainView.warningLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
