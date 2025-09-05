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
        setNavItem()
        bind()
    }

    func bind() {
        let input = CommentsViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.comments
            .bind(to: mainView.tableView.rx.items) { tableView, row, element in
                let cell = tableView.dequeueReusableCell(for: IndexPath(row: row, section: 0), cellClass: CommentTableViewCell.self)
                cell.setData(data: element)
                return cell
            }
            .disposed(by: disposeBag)
        
        output.navTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
           
    }
    
    private func setNavItem() {
        
    }
}
