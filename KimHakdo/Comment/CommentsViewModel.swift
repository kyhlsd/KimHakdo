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
        
    }
    
    struct Output {
        let comments: BehaviorRelay<[Comment]>
        let navTitle: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let comments = BehaviorRelay(value: self.comments)
        let navTitle = Observable.just(self.navTitle)
        
        return Output(
            comments: comments,
            navTitle: navTitle
        )
    }
}
