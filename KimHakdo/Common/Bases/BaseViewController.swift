//
//  BaseViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import Foundation

protocol BaseViewController: AnyObject {
    associatedtype ViewModel: BaseViewModel
    associatedtype View: BaseView
    var mainView: View { get }
    var viewModel: ViewModel { get }
    func bind()
}
