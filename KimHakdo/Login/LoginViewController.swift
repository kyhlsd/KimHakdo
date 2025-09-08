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
    private let disposeBag = DisposeBag()
    
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
            .bind(with: self, onNext: { owner, isEnabled in
                owner.mainView.loginButton.isEnabled = isEnabled
                owner.mainView.loginButton.setColor(isEnabled)
            })
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
        
        output.convertToLookupVC
            .bind(with: self) { owner, _ in
                owner.convertToLookupVC()
            }
            .disposed(by: disposeBag)
        
        output.errorAlert
            .bind(with: self) { owner, message in
                owner.presentDefaultAlert(title: "로그인 실패", message: message)
            }
            .disposed(by: disposeBag)
    }
    
    private func convertToLookupVC() {
        guard let _ = UserDefaultHelper.token else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            window.rootViewController = MyTabBarController()
        }
    }
}
