//
//  SettingViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingViewController: UIViewController, BaseViewController {
    
    let mainView = SettingView()
    let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItem()
        bind()
    }
    
    func bind() {
        let okButtonTap = PublishRelay<Void>()
        let input = SettingViewModel.Input(
            logoutButtonTap: mainView.logoutButton.rx.tap,
            okButtonTap: okButtonTap
        )
        let output = viewModel.transform(input: input)
        
        output.logoutAlert
            .bind(with: self) { owner, alert in
                let (title, message) = alert
                owner.presentLogoutAlert(title: title, message: message, to: okButtonTap)
            }
            .disposed(by: disposeBag)
        
        output.convertToLoginVC
            .bind(with: self) { owner, _ in
                owner.convertToLoginVC()
            }
            .disposed(by: disposeBag)
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "프로필"))
    }
    
    private func presentLogoutAlert(title: String, message: String, to: PublishRelay<Void>) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            to.accept(())
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func convertToLoginVC() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }

        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            window.rootViewController = LoginViewController()
        }
    }
}
