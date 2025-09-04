//
//  ClassDetailViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit

final class ClassDetailViewController: UIViewController, BaseViewController {
    
    let mainView = ClassDetailView()
    let viewModel = ClassDetailViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        
    }
    
    
}
