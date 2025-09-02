//
//  BaseViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import Foundation

private protocol BaseViewController: AnyObject {
    typealias ViewModel = any BaseViewModel
    
    var viewModel: ViewModel { get }
    func bind(viewModel: ViewModel)
}
