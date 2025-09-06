//
//  SearchClassViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchClassViewController: UIViewController, BaseViewController {
    
    let mainView = SearchClassView()
    let viewModel = SearchClassViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItem()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    func bind() {
        
        Observable.just([ClassResult]())
            .bind(to: mainView.collectionView.rx.items(cellIdentifier: SearchClassCollectionViewCell.identifier, cellType: SearchClassCollectionViewCell.self)) { _, element, cell in
                cell.setData(data: element)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "클래스 검색"))
        navigationItem.backButtonTitle = " "
    }
}
