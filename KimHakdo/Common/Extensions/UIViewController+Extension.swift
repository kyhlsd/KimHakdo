//
//  UIViewController+Extension.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit
import Toast

extension UIViewController {
    func presentDefaultAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    func showDefaultToast(message: String) {
        view.makeToast(message, duration: 1, position: .bottom)
    }
}
