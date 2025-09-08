//
//  PostAndEditCommentViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class PostAndEditCommentViewController: UIViewController, BaseViewController {

    let mainView = PostAndEditCommentView()
    let viewModel: PostAndEditCommentViewModel
    private let disposeBag = DisposeBag()
    
    init(classInfo: ClassCoreInfo, prevComment: Comment?) {
        self.viewModel = PostAndEditCommentViewModel(classInfo: classInfo, prevComment: prevComment)
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
        setupNavItem()
        bind()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func bind() {
        let input = PostAndEditCommentViewModel.Input(
            contentText: mainView.textView.rx.text,
            didBeginEditing: mainView.textView.rx.didBeginEditing,
            didEndEditing: mainView.textView.rx.didEndEditing,
            saveButtonTap: navigationItem.rightBarButtonItem?.rx.tap,
            dismissButtonTap: navigationItem.leftBarButtonItem?.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.navTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.category
            .bind(to: mainView.categoryLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.classTitle
            .bind(to: mainView.titleLabel.rx.text)
            .disposed(by: disposeBag)
            
        output.countDescription
            .bind(to: mainView.countLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.isPlaceholder
            .map { $0 ? UIColor.disabled : UIColor.darkGray }
            .bind(to: mainView.textView.rx.textColor)
            .disposed(by: disposeBag)
        
        output.contentText
            .bind(to: mainView.textView.rx.text)
            .disposed(by: disposeBag)
        
        output.countWarning
            .map { $0 ? UIColor.point : UIColor.black }
            .bind(to: mainView.countLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        output.saveEnabled
            .bind(with: self) { owner, isEnabled in
                owner.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
            }
            .disposed(by: disposeBag)
        
        output.popVC
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.errorAlert
            .bind(with: self) { owner, message in
                owner.presentDefaultAlert(title: "댓글 저장 실패", message: message)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupNavItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "확인", style: .done, target: self, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: nil)
    }
}
