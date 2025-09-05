//
//  CommentsViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentsViewModel: BaseViewModel {
    
    private let comments: [Comment]
    private let classCoreInfo: ClassCoreInfo
    private let disposeBag = DisposeBag()
    
    init(comments: [Comment], classCoreInfo: ClassCoreInfo) {
        self.comments = comments
        self.classCoreInfo = classCoreInfo
    }
    
    struct Input {
        let moreButtonTap: PublishRelay<String>
        let navItemTap: ControlEvent<Void>?
    }
    
    struct Output {
        let commentDataList: BehaviorRelay<[(Comment, Bool)]>
        let navTitle: Observable<String>
        let presentEditActionSheet: PublishRelay<String>
        let pushPostCommentVC: PublishRelay<ClassCoreInfo>
    }
    
    func transform(input: Input) -> Output {
        let commentData = self.comments
            .map { [weak self] comment in
                guard let self else { return (comment, false) }
                return (comment, isMine(id: comment.creator.userId))
            }
        let commentDataList = BehaviorRelay(value: commentData)
        let navTitle = Observable.just(self.classCoreInfo.title)
        let presentEditActionSheet = PublishRelay<String>()
        let pushPostCommentVC = PublishRelay<ClassCoreInfo>()
        
        input.moreButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: presentEditActionSheet)
            .disposed(by: disposeBag)
        
        input.navItemTap?
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .compactMap { [weak self] _ in self?.classCoreInfo }
            .bind(to: pushPostCommentVC)
            .disposed(by: disposeBag)
        
        return Output(
            commentDataList: commentDataList,
            navTitle: navTitle,
            presentEditActionSheet: presentEditActionSheet,
            pushPostCommentVC: pushPostCommentVC
        )
    }
    
    private func isMine(id: String) -> Bool {
        return id == UserDefaultHelper.userId
    }
}
