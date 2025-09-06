//
//  LookupClassViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LookupClassViewController: UIViewController, BaseViewController {
    
    let mainView = LookupClassView()
    let viewModel = LookupClassViewModel()
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

    func bind() {
        let callRequest = PublishRelay<Void>()
        let input = LookupClassViewModel.Input(
            callRequest: callRequest,
            selectCategory: mainView.categoryCollectionView.rx.modelSelected((ClassCategory, Bool).self),
            sortButtonTap: mainView.sortButton.rx.tap,
            willDisplayCell: mainView.classCollectionView.rx.willDisplayCell.map { _ in () },
            classSelected: mainView.classCollectionView.rx.modelSelected(ClassResult.self)
        )
        let output = viewModel.transform(input: input)
        output.categories
            .bind(to: mainView.categoryCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.identifier, cellType: CategoryCollectionViewCell.self)) { _, element, cell in
                cell.setData(data: element)
            }
            .disposed(by: disposeBag)
        
        output.classList
            .bind(to: mainView.classCollectionView.rx.items(cellIdentifier: LookupClassCollectionViewCell.identifier, cellType: LookupClassCollectionViewCell.self)) { _, element, cell in
                cell.setData(data: element)
            }
            .disposed(by: disposeBag)
        
        output.countText
            .distinctUntilChanged()
            .bind(to: mainView.countLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .bind(with: self) { owner, indexPath in
                owner.mainView.classCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
            .disposed(by: disposeBag)
        
        output.sortOption
            .map { $0.rawValue }
            .bind(with: self) { owner, text in
                owner.mainView.setSortButtonTitle(title: text)
            }
            .disposed(by: disposeBag)
        
        output.errorAlert
            .bind(with: self) { owner, message in
                owner.presentDefaultAlert(title: "데이터 불러오기 실패", message: message)
            }
            .disposed(by: disposeBag)
        
        output.pushDetailVC
            .bind(with: self) { owner, id in
                owner.navigationController?.pushViewController(ClassDetailViewController(id: id), animated: true)
            }
            .disposed(by: disposeBag)
        
        callRequest.accept(())
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "클래스 조회"))
        navigationItem.backButtonTitle = " "
    }
}
