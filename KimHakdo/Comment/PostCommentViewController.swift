//
//  PostCommentViewController.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import UIKit

final class PostCommentViewController: UIViewController {

    let mainView = PostCommentView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItem()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupNavItem() {
        navigationItem.title = "댓글 작성"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "확인", style: .done, target: self, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: nil)
    }
}
