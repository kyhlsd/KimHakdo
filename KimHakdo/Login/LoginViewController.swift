//
//  LoginViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit

final class LoginViewController: UIViewController, BaseViewController {
    
    let mainView = LoginView()
    let viewModel = LoginViewModel()
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func bind() {
        
    }
}
