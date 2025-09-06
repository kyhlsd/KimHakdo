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
        let editTap: PublishRelay<String>
        let deleteTap: PublishRelay<String>
        let navItemTap: ControlEvent<Void>?
    }
    
    struct Output {
        let commentDataList: BehaviorRelay<[(Comment, Bool)]>
        let navTitle: Observable<String>
        let presentEditActionSheet: PublishRelay<String>
        let pushPostCommentVC: PublishRelay<ClassCoreInfo>
        let toastMessage: PublishRelay<String>
        let errorAlert: PublishRelay<String>
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
        let toastMessage = PublishRelay<String>()
        let errorAlert = PublishRelay<String>()
        
        input.moreButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: presentEditActionSheet)
            .disposed(by: disposeBag)
        
        // editMode
        input.editTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .compactMap { [weak self] _ in self?.classCoreInfo }
            .bind(to: pushPostCommentVC)
            .disposed(by: disposeBag)
        
        input.deleteTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .flatMap { [weak self] commentId in
                guard let self else {
                    return Single<Result<Void, APIError>>.just(.failure(.unknown))
                }
                return NetworkManager.shared.callRequestWithNoResponse(url: .deleteComment(classId: classCoreInfo.classId, commentId: commentId))
            }
            .bind { result in
                switch result {
                case .success:
                    toastMessage.accept("댓글을 삭제했습니다.")
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
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
            pushPostCommentVC: pushPostCommentVC,
            toastMessage: toastMessage,
            errorAlert: errorAlert
        )
    }
    
    private func isMine(id: String) -> Bool {
        return id == UserDefaultHelper.userId
    }
}
