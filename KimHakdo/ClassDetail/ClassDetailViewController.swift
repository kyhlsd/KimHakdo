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
        mainView.favoriteButton.delegate = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItem()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    func bind() {
        let callRequestForDetail = PublishRelay<Void>()
        let callRequestForComments = PublishRelay<Void>()
        
        let input = ClassDetailViewModel.Input(
            callRequestForDetail: callRequestForDetail,
            callRequestForComments: callRequestForComments,
            commentsButtonTap: mainView.showCommentButton.rx.tap
        )
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
            .bind(to: mainView.descriptionTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.isLikedData
            .bind(with: self) { owner, data in
                let (id, title, isLiked) = data
                owner.mainView.favoriteButton.setData(classId: id, classTitle: title, isLiked: isLiked)
            }
            .disposed(by: disposeBag)
        
        output.commentsButtonTitle
            .bind(with: self) { owner, title in
                owner.mainView.showCommentButton.setTitle(title, for: .normal)
            }
            .disposed(by: disposeBag)
        
        output.commentsButtonEnabled
            .bind(with: self, onNext: { owner, isEnabled in
                owner.mainView.showCommentButton.isEnabled = isEnabled
                owner.mainView.showCommentButton.setColor(isEnabled)
            })
            .disposed(by: disposeBag)
        
        output.pushCommentVC
            .bind(with: self) { owner, data in
                let (comments, classCoreInfo) = data
                let vc = CommentsViewController(comments: comments, classCoreInfo: classCoreInfo)
                vc.viewModel.delegate = owner.viewModel
                owner.navigationController?.pushViewController(vc, animated: true)
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
        
        callRequestForDetail.accept(())
        callRequestForComments.accept(())
    }
    
    private func setupNavItem() {
        navigationItem.backButtonTitle = " "
    }
}
