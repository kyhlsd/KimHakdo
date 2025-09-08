//
//  CommentsViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol ReloadedCommentsDelegate: AnyObject {
    var comments: PublishRelay<[Comment]> { get }
}

final class CommentsViewModel: BaseViewModel, PostAndEditDelegate {
    
    private let comments: [Comment]
    private let classCoreInfo: ClassCoreInfo
    let reloadComments = PublishRelay<Void>()
    var shouldScrollToTop = false
    let toastMessage = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    weak var delegate: ReloadedCommentsDelegate?
    
    init(comments: [Comment], classCoreInfo: ClassCoreInfo) {
        self.comments = comments
        self.classCoreInfo = classCoreInfo
    }
    
    struct Input {
        let moreButtonTap: PublishRelay<Comment>
        let editTap: PublishRelay<Comment>
        let deleteTap: PublishRelay<String>
        let navItemTap: ControlEvent<Void>?
        let willDisplayCell: ControlEvent<WillDisplayCellEvent>
    }
    
    struct Output {
        let commentDataList: BehaviorRelay<[(Comment, Bool)]>
        let scrollToTop: PublishRelay<IndexPath>
        let navTitle: Observable<String>
        let presentEditActionSheet: PublishRelay<Comment>
        let pushPostCommentVC: PublishRelay<(ClassCoreInfo, Comment?)>
        let toastMessage: PublishRelay<String>
        let errorAlert: PublishRelay<(String, String)>
    }
    
    func transform(input: Input) -> Output {
        let commentData = self.comments
            .map { [weak self] comment in
                guard let self else { return (comment, false) }
                return (comment, isMine(id: comment.creator.userId))
            }
        let commentDataList = BehaviorRelay(value: commentData)
        let scrollToTop = PublishRelay<IndexPath>()
        let navTitle = Observable.just(self.classCoreInfo.title)
        let presentEditActionSheet = PublishRelay<Comment>()
        let pushPostCommentVC = PublishRelay<(ClassCoreInfo, Comment?)>()
        let toastMessage = self.toastMessage
        let errorAlert = PublishRelay<(String, String)>()
        
        let reloadComments = self.reloadComments
        
        input.moreButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: presentEditActionSheet)
            .disposed(by: disposeBag)
        
        input.editTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .compactMap { [weak self] comment in
                guard let self else { return nil }
                return (self.classCoreInfo, comment)
            }
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
                    reloadComments.accept(())
                case .failure(let error):
                    errorAlert.accept(("댓글 삭제 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        input.navItemTap?
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .compactMap { [weak self] _ in
                guard let self else { return nil }
                return (self.classCoreInfo, nil)
            }
            .bind(to: pushPostCommentVC)
            .disposed(by: disposeBag)
        
        reloadComments
            .flatMap { [weak self] in
                guard let self else {
                    return Single<Result<CommentsResult, APIError>>.just(.failure(.unknown))
                }
                return NetworkManager.shared.callRequest(url: .lookupComment(id: classCoreInfo.classId), type: CommentsResult.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    let commentData = value.data
                        .map { comment in
                            (comment, owner.isMine(id: comment.creator.userId))
                        }
                    commentDataList.accept(commentData)
                    owner.delegate?.comments.accept(value.data)
                case .failure(let error):
                    errorAlert.accept(("댓글 새로고침 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        input.willDisplayCell
            .filter { [weak self] _ in self?.shouldScrollToTop == true }
            .bind(with: self) { owner, _ in
                owner.shouldScrollToTop = false
                scrollToTop.accept(IndexPath(row: 0, section: 0))
            }
            .disposed(by: disposeBag)
        
        return Output(
            commentDataList: commentDataList,
            scrollToTop: scrollToTop,
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
