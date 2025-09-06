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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func bind() {
        let input = SearchClassViewModel.Input(
            searchText: mainView.searchBar.rx.text,
            searchButtonClicked: mainView.searchBar.rx.searchButtonClicked,
            willDisplayCell: mainView.collectionView.rx.willDisplayCell.map { _ in () },
            classSelected: mainView.collectionView.rx.modelSelected(ClassResult.self)
        )
        let output = viewModel.transform(input: input)
        
        output.guideText
            .bind(to: mainView.guideLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.searchedClassList
            .bind(to: mainView.collectionView.rx.items(cellIdentifier: SearchClassCollectionViewCell.identifier, cellType: SearchClassCollectionViewCell.self)) { _, element, cell in
                cell.setData(data: element)
            }
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .bind(with: self) { owner, indexPath in
                owner.mainView.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
            .disposed(by: disposeBag)
        
        output.pushDetailVC
            .bind(with: self) { owner, id in
                owner.navigationController?.pushViewController(ClassDetailViewController(id: id), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.errorAlert
            .bind(with: self) { owner, message in
                owner.presentDefaultAlert(title: "검색 실패", message: message)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "클래스 검색"))
        navigationItem.backButtonTitle = " "
    }
}
