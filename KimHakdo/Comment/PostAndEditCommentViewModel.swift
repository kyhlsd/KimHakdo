//
//  PostAndEditCommentViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation
import RxSwift
import RxCocoa

// 댓글 작성/수정에 따른 정보 이전 화면으로 전달
protocol PostAndEditDelegate: AnyObject {
    var reloadComments: PublishRelay<Void> { get }
    var shouldScrollToTop: Bool { get set }
    var toastMessage: PublishRelay<String> { get }
}

final class PostAndEditCommentViewModel: BaseViewModel {
    
    private let classInfo: ClassCoreInfo
    private let prevComment: Comment?
    private var isNew: Bool {
        return prevComment == nil
    }
    
    private let maxCount = 200
    private let minCount = 2
    private let warningCount = 150
    private let placeholderText = "댓글을\u{00A0}작성해주세요."
    
    private let disposeBag = DisposeBag()
    weak var delegate: PostAndEditDelegate?
    
    struct Input {
        let contentText: ControlProperty<String?>
        let didBeginEditing: ControlEvent<Void>
        let didEndEditing: ControlEvent<Void>
        let saveButtonTap: ControlEvent<()>?
        let dismissButtonTap: ControlEvent<()>?
    }
    
    struct Output {
        let navTitle: BehaviorRelay<String>
        let category: BehaviorRelay<String>
        let classTitle: BehaviorRelay<String>
        let countDescription: BehaviorRelay<String>
        let isPlaceholder: BehaviorRelay<Bool>
        let contentText: BehaviorRelay<String>
        let countWarning: BehaviorRelay<Bool>
        let saveEnabled: BehaviorRelay<Bool>
        let popVC: PublishRelay<Void>
        let errorAlert: PublishRelay<String>
    }
    
    init(classInfo: ClassCoreInfo, prevComment: Comment?) {
        self.classInfo = classInfo
        self.prevComment = prevComment
    }
    
    // MARK: Transform
    func transform(input: Input) -> Output {
        let navTitle = BehaviorRelay(value: isNew ? "댓글 작성" : "댓글 수정")
        let category = BehaviorRelay(value: classInfo.category.description)
        let classTitle = BehaviorRelay(value: classInfo.title)
        let countDescription = BehaviorRelay(value: getCountDescription(count: 0))
        let isPlaceholder = BehaviorRelay(value: isNew)
        let contentText = BehaviorRelay(value: prevComment?.content ?? placeholderText)
        let countWarning = BehaviorRelay(value: false)
        let saveEnabled = BehaviorRelay(value: false)
        let popVC = PublishRelay<Void>()
        let errorAlert = PublishRelay<String>()
        
        let postComment = PublishRelay<String>()
        let editComment = PublishRelay<String>()
        
        // placeholder 상태 해제
        input.didBeginEditing
            .withLatestFrom(input.contentText.orEmpty)
            .filter { [weak self] text in
                guard let self else { return false }
                return text == self.placeholderText
            }
            .bind { _ in
                isPlaceholder.accept(false)
                contentText.accept("")
            }
            .disposed(by: disposeBag)
        
        // 글이 비었으면 placeholder 표기
        input.didEndEditing
            .withLatestFrom(input.contentText.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty }
            .bind(with: self) { owner, _ in
                isPlaceholder.accept(true)
                contentText.accept(owner.placeholderText)
            }
            .disposed(by: disposeBag)
        
        // 공백 제외 글자수
        let count = input.contentText
            .orEmpty
            .distinctUntilChanged { $0.count == $1.count }
            .compactMap { [weak self] in
                self?.calculateCount(text: $0)
            }
            .distinctUntilChanged()
            .share()
        
        // 글자수 표기
        count
            .compactMap { [weak self] in
                self?.getCountDescription(count: $0)
            }
            .bind(to: countDescription)
            .disposed(by: disposeBag)
        
        // 글자수 많아질 때
        count
            .compactMap { [weak self] in self?.checkCountWarning(count: $0) }
            .bind(to: countWarning)
            .disposed(by: disposeBag)
        
        // enabled 체크
        count
            .compactMap { [weak self] in self?.checkSaveEnabled(count: $0) }
            .bind(to: saveEnabled)
            .disposed(by: disposeBag)

        // 불필요 공백 제거 후 댓글 작성/수정
        input.saveButtonTap?
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .withLatestFrom(input.contentText.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .bind(with: self) { owner, content in
                if owner.isNew {
                    postComment.accept(content)
                } else {
                    editComment.accept(content)
                }
            }
            .disposed(by: disposeBag)
        
        // 작성 후 전 화면 데이터 ReFetch, ScrollToTop
        postComment
            .flatMap { [weak self] content in
                guard let self else {
                    return Single<Result<Comment, APIError>>.just(.failure(.unknown))
                }
                
                return NetworkManager.shared.callRequest(url: .postComment(id: classInfo.classId, content: content), type: Comment.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success:
                    owner.delegate?.toastMessage.accept("댓글이 작성되었습니다.")
                    owner.delegate?.reloadComments.accept(())
                    owner.delegate?.shouldScrollToTop = true
                    popVC.accept(())
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 댓글 수정 사항 없다면 서버 호출 안함
        editComment
            .flatMap { [weak self] content in
                guard let self, let prevCommentId = self.prevComment?.commentId else {
                    return Single<Result<Comment, APIError>>.just(.failure(.unknown))
                }
                
                if let prevComment = self.prevComment, content == prevComment.content {
                    return Single<Result<Comment, APIError>>.just(.success(prevComment))
                }
                
                return NetworkManager.shared.callRequest(url: .editComment(classId: classInfo.classId, commentId: prevCommentId, content: content), type: Comment.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.delegate?.toastMessage.accept("댓글이 수정되었습니다.")
                    if let prevComment = owner.prevComment, value.content != prevComment.content {
                        owner.delegate?.reloadComments.accept(())
                    }
                    popVC.accept(())
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 댓글 작성/수정 취소
        input.dismissButtonTap?
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: popVC)
            .disposed(by: disposeBag)
        
        return Output(navTitle: navTitle,
                      category: category,
                      classTitle: classTitle,
                      countDescription: countDescription,
                      isPlaceholder: isPlaceholder,
                      contentText: contentText,
                      countWarning: countWarning,
                      saveEnabled: saveEnabled,
                      popVC: popVC,
                      errorAlert: errorAlert
        )
    }
    
    // MARK: SubMethods
    private func calculateCount(text: String) -> Int {
        if text == placeholderText { return 0 }
        return text.ranges(of: /\S/).count
    }
    
    private func getCountDescription(count: Int) -> String {
        return count > maxCount ? "\(maxCount)글자 초과" : "\(count) / \(maxCount)"
    }
    
    private func checkCountWarning(count: Int) -> Bool {
        return count >= warningCount
    }
    
    private func checkSaveEnabled(count: Int) -> Bool {
        return count >= minCount && count <= maxCount
    }
}
