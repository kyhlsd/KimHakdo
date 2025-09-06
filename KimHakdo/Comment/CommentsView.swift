//
//  CommentsView.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit
import SnapKit

final class CommentsView: BaseView {
    
    let tableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(cellClass: CommentTableViewCell.self)
        tableView.register(cellClass: MyCommentTableViewCell.self)
        return tableView
    }()
    
    override func setupView() {
        backgroundColor = .background
    }
    
    override func setupHierarchy() {
        addSubview(tableView)
    }
    
    override func setupLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
