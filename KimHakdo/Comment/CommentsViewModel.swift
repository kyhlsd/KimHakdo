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
    private let navTitle: String
    private let disposeBag = DisposeBag()
    
    init(comments: [Comment], navTitle: String) {
        self.comments = comments
        self.navTitle = navTitle
    }
    
    struct Input {
        let moreButtonTap: PublishRelay<String>
    }
    
    struct Output {
        let commentDataList: BehaviorRelay<[(Comment, Bool)]>
        let navTitle: Observable<String>
        let presentEditActionSheet: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let commentData = self.comments
            .map { [weak self] comment in
                guard let self else { return (comment, false) }
                return (comment, isMine(id: comment.creator.userId))
            }
        let commentDataList = BehaviorRelay(value: commentData)
        let navTitle = Observable.just(self.navTitle)
        let presentEditActionSheet = PublishRelay<String>()
        
        input.moreButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: presentEditActionSheet)
            .disposed(by: disposeBag)
        
        return Output(
            commentDataList: commentDataList,
            navTitle: navTitle,
            presentEditActionSheet: presentEditActionSheet
        )
    }
    
    private func isMine(id: String) -> Bool {
        return id == UserDefaultHelper.userId
    }
}
