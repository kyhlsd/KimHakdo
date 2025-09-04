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
        setNavItem()
        bind()
    }

    func bind() {
        let input = LookupClassViewModel.Input(
            viewDidLoad: Observable.just(()),
            selectCategory: mainView.categoryCollectionView.rx.modelSelected((ClassCategory, Bool).self),
            sortButtonTap: mainView.sortButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.categories
            .bind(to: mainView.categoryCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.identifier, cellType: CategoryCollectionViewCell.self)) { _, element, cell in
                cell.setData(data: element)
            }
            .disposed(by: disposeBag)
        
        output.courses
            .bind(to: mainView.classCollectionView.rx.items(cellIdentifier: LookupClassCollectionViewCell.identifier, cellType: LookupClassCollectionViewCell.self)) { _, element, cell in
                cell.setData(data: element)
            }
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .bind(with: self) { owner, _ in
                if owner.mainView.classCollectionView.visibleCells.isEmpty { return }
                owner.mainView.classCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
            .disposed(by: disposeBag)
        
        output.sortOption
            .map { $0.rawValue }
            .bind(with: self) { owner, text in
                owner.mainView.setSortButtonTitle(title: text)
            }
            .disposed(by: disposeBag)
    }
    
    private func setNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "클래스 조회"))
    }
}
