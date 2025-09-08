//
//  CommentsViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation
import RxSwift
import RxCocoa

// comments 변경 시 이전 화면에 데이터 넘김
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
    
    // MARK: Transform
    func transform(input: Input) -> Output {
        // 초기값: 전화면에서 fetch한 댓글
        // 내 댓글인지 Bool 값 함께 Mapping
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
        
        // 더보기 버튼
        input.moreButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: presentEditActionSheet)
            .disposed(by: disposeBag)
        
        // 댓글 수정
        input.editTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .compactMap { [weak self] comment in
                guard let self else { return nil }
                return (self.classCoreInfo, comment)
            }
            .bind(to: pushPostCommentVC)
            .disposed(by: disposeBag)
        
        // 댓글 삭제
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
                    // 댓글 ReFetch
                    reloadComments.accept(())
                case .failure(let error):
                    errorAlert.accept(("댓글 삭제 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        // 댓글 작성
        input.navItemTap?
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .compactMap { [weak self] _ in
                guard let self else { return nil }
                return (self.classCoreInfo, nil)
            }
            .bind(to: pushPostCommentVC)
            .disposed(by: disposeBag)
        
        // 댓글 ReFetch
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
                    // 이전 화면 데이터 동기화
                    owner.delegate?.comments.accept(value.data)
                case .failure(let error):
                    errorAlert.accept(("댓글 새로고침 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        // 새 댓글 작성 완료 시, 댓글 TableView 그려진 후 ScrollToTop
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
    
    // MARK: SubMethods
    private func isMine(id: String) -> Bool {
        return id == UserDefaultHelper.userId
    }
}
