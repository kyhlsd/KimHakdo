//
//  CommentsViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CommentsViewController: UIViewController, BaseViewController {
    
    let mainView = CommentsView()
    let viewModel: CommentsViewModel
    private let disposeBag = DisposeBag()
    
    init(comments: [Comment], classCoreInfo: ClassCoreInfo) {
        self.viewModel = CommentsViewModel(comments: comments, classCoreInfo: classCoreInfo)
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

    func bind() {
        let moreButtonTap = PublishRelay<Comment>()
        let editTap = PublishRelay<Comment>()
        let deleteTap = PublishRelay<String>()
        
        let input = CommentsViewModel.Input(
            moreButtonTap: moreButtonTap,
            editTap: editTap,
            deleteTap: deleteTap,
            navItemTap: navigationItem.rightBarButtonItem?.rx.tap,
            willDisplayCell: mainView.tableView.rx.willDisplayCell
        )
        let output = viewModel.transform(input: input)
        
        output.commentDataList
            .bind(to: mainView.tableView.rx.items) { tableView, row, element in
                let (comment, isMine) = element
                if isMine {
                    let cell = tableView.dequeueReusableCell(for: IndexPath(row: row, section: 0), cellClass: MyCommentTableViewCell.self)
                    cell.setData(data: comment, to: moreButtonTap)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(for: IndexPath(row: row, section: 0), cellClass: CommentTableViewCell.self)
                    cell.setData(data: comment)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .bind(with: self) { owner, indexPath in
                owner.mainView.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
            .disposed(by: disposeBag)
        
        output.navTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
           
        output.presentEditActionSheet
            .bind(with: self) { owner, comment in
                owner.presentEditActionSheet(comment: comment, editRelay: editTap, deleteRelay: deleteTap)
            }
            .disposed(by: disposeBag)
        
        output.pushPostCommentVC
            .bind(with: self) { owner, data in
                let (info, prevComment) = data
                let vc = PostAndEditCommentViewController(classInfo: info, prevComment: prevComment)
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
    }
    
    private func setupNavItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .comment, style: .done, target: self, action: nil)
    }
    
    private func presentEditActionSheet(comment: Comment, editRelay: PublishRelay<Comment>, deleteRelay: PublishRelay<String>) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "댓글 수정", style: .default, handler: { _ in
            editRelay.accept(comment)
        }))
        actionSheet.addAction(UIAlertAction(title: "댓글 삭제", style: .destructive, handler: { _ in
            deleteRelay.accept(comment.commentId)
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(actionSheet, animated: true)
    }

}
