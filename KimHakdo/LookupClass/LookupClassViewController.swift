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
            .bind(to: mainView.classCollectionView.rx.diffableItems(section: 0, cellType: LookupClassCollectionViewCell.self) { [weak self] _, element, cell in
                cell.setData(data: element)
                cell.favoriteButton.delegate = self?.viewModel
            })
            .disposed(by: disposeBag)
        
        output.countText
            .distinctUntilChanged()
            .bind(to: mainView.countLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .bind(with: self) { owner, indexPath in
                DispatchQueue.main.async { // diffable animation 이후로 미뤄야 동작
                    owner.mainView.classCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                }
            }
            .disposed(by: disposeBag)
        
        output.sortOption
            .map { $0.rawValue }
            .bind(with: self) { owner, text in
                owner.mainView.setSortButtonTitle(title: text)
            }
            .disposed(by: disposeBag)
        
        output.pushDetailVC
            .bind(with: self) { owner, id in
                owner.navigationController?.pushViewController(ClassDetailViewController(id: id), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.toastMessage
            .bind(with: self) { owner, message in
                owner.showDefaultToast(message: message)
            }
            .disposed(by: disposeBag)
        
        output.errorAlert
            .bind(with: self) { owner, data in
                let (title, message) = data
                owner.presentDefaultAlert(title: title, message: message)
            }
            .disposed(by: disposeBag)
        
        callRequest.accept(())
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "클래스 조회"))
        navigationItem.backButtonTitle = " "
    }
}
