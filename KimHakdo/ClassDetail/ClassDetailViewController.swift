//
//  ClassDetailViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ClassDetailViewController: UIViewController, BaseViewController {
    
    let mainView = ClassDetailView()
    let viewModel: ClassDetailViewModel
    private let disposeBag = DisposeBag()
    
    init(id: String) {
        self.viewModel = ClassDetailViewModel(id: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        let callRequeset = PublishRelay<Void>()
        let input = ClassDetailViewModel.Input(callRequest: callRequeset)
        let output = viewModel.transform(input: input)
        
        output.navTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.imageURLs
            .bind(to: mainView.imageCollectionView.rx.items(cellIdentifier: ImageCollectionViewCell.identifier, cellType: ImageCollectionViewCell.self)) { _, element, cell in
                cell.setData(data: element)
            }
            .disposed(by: disposeBag)
        
        output.profileImage
            .bind(with: self) { owner, image in
                owner.mainView.setProfileImage(image: image)
            }
            .disposed(by: disposeBag)
        
        output.nickname
            .bind(to: mainView.nicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.location
            .bind(to: mainView.locationLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.date
            .bind(to: mainView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.capacity
            .bind(to: mainView.capacityLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.description
            .bind(with: self) { owner, text in
                owner.mainView.setDescriptionText(text: text)
            }
            .disposed(by: disposeBag)
        
        output.isFavorited
            .bind(with: self) { owner, isFavorited in
                owner.mainView.favoriteButton.setStatusWithBorder(isFavorited: isFavorited)
            }
            .disposed(by: disposeBag)
        
        output.errorAlert
            .bind(with: self) { owner, message in
                owner.presentDefaultAlert(title: "데이터 불러오기 실패", message: message)
            }
            .disposed(by: disposeBag)
        
        callRequeset.accept(())
    }
    
    
}
