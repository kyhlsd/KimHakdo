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
    
    init(comments: [Comment], navTitle: String) {
        self.viewModel = CommentsViewModel(comments: comments, navTitle: navTitle)
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
        let moreButtonTap = PublishRelay<String>()
        
        let input = CommentsViewModel.Input(
            moreButtonTap: moreButtonTap
        )
        let output = viewModel.transform(input: input)
        
        output.commentDataList
            .bind(to: mainView.tableView.rx.items) { tableView, row, element in
                let (comment, isMine) = element
                if isMine {
                    let cell = tableView.dequeueReusableCell(for: IndexPath(row: row, section: 0), cellClass: MyCommentTableViewCell.self)
                    cell.setData(data: comment)
                    return cell
                } else {
                    // TODO: Test하고나서 돌려놓기
                    let cell = tableView.dequeueReusableCell(for: IndexPath(row: row, section: 0), cellClass: MyCommentTableViewCell.self)
                    cell.setData(data: comment, to: moreButtonTap)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.navTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
           
        output.presentEditActionSheet
            .bind(with: self) { owner, commentId in
                owner.presentEditActionSheet(commentId: commentId)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupNavItem() {
        
    }
    
    private func presentEditActionSheet(commentId: String) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "댓글 수정", style: .default, handler: { _ in
            print("댓글 수정")
        }))
        actionSheet.addAction(UIAlertAction(title: "댓글 삭제", style: .destructive, handler: { _ in
            print("댓글 삭제")
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(actionSheet, animated: true)
    }
}
