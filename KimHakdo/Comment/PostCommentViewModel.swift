//
//  PostCommentViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class PostCommentViewModel: BaseViewModel {
    
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
        let toastMessage: PublishRelay<String>
        let errorAlert: PublishRelay<String>
    }
    
    init(classInfo: ClassCoreInfo, prevComment: Comment?) {
        self.classInfo = classInfo
        self.prevComment = prevComment
    }
    
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
        let toastMessage = PublishRelay<String>()
        let errorAlert = PublishRelay<String>()
        
        let postComment = PublishRelay<Void>()
        let editComment = PublishRelay<Void>()
        
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
        
        input.didEndEditing
            .withLatestFrom(input.contentText.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty }
            .bind(with: self) { owner, _ in
                isPlaceholder.accept(true)
                contentText.accept(owner.placeholderText)
            }
            .disposed(by: disposeBag)
        
        let count = input.contentText
            .orEmpty
            .distinctUntilChanged { $0.count == $1.count }
            .compactMap { [weak self] in
                self?.calculateCount(text: $0)
            }
            .distinctUntilChanged()
            .share()
        
        count
            .compactMap { [weak self] in
                self?.getCountDescription(count: $0)
            }
            .bind(to: countDescription)
            .disposed(by: disposeBag)
        
        count
            .compactMap { [weak self] in self?.checkCountWarning(count: $0) }
            .bind(to: countWarning)
            .disposed(by: disposeBag)
        
        count
            .compactMap { [weak self] in self?.checkSaveEnabled(count: $0) }
            .bind(to: saveEnabled)
            .disposed(by: disposeBag)

        input.saveButtonTap?
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                if owner.isNew {
                    postComment.accept(())
                } else {
                    editComment.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        postComment
            .withLatestFrom(input.contentText.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .flatMap { [weak self] content in
                guard let self else {
                    return Single<Result<Comment, APIError>>.just(.failure(.unknown))
                }
                
                return NetworkManager.shared.callRequest(url: .postComment(id: classInfo.classId, content: content), type: Comment.self)
            }
            .bind { result in
                switch result {
                case .success:
                    toastMessage.accept("댓글이 작성되었습니다.")
                    popVC.accept(())
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        editComment
            .withLatestFrom(input.contentText.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .flatMap { [weak self] content in
                guard let self, let prevCommentId = self.prevComment?.commentId else {
                    return Single<Result<Comment, APIError>>.just(.failure(.unknown))
                }
                
                return NetworkManager.shared.callRequest(url: .editComment(classId: classInfo.classId, commentId: prevCommentId, content: content), type: Comment.self)
            }
            .bind { result in
                switch result {
                case .success:
                    toastMessage.accept("댓글이 수정되었습니다.")
                    popVC.accept(())
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
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
                      toastMessage: toastMessage,
                      errorAlert: errorAlert
        )
    }
    
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
