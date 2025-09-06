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
    private let maxCount = 200
    private let minCount = 2
    private let warningCount = 150
    private let disposeBag = DisposeBag()
    
    struct Input {
        let contentText: ControlProperty<String?>
        let saveButtonTap: ControlEvent<()>?
        let dismissButtonTap: ControlEvent<()>?
    }
    
    struct Output {
        let category: BehaviorRelay<String>
        let title: BehaviorRelay<String>
        let countDescription: BehaviorRelay<String>
        let countWarning: BehaviorRelay<Bool>
        let saveEnabled: BehaviorRelay<Bool>
        let popVC: PublishRelay<Void>
        let toastMessage: PublishRelay<String>
        let errorAlert: PublishRelay<String>
    }
    
    init(classInfo: ClassCoreInfo) {
        self.classInfo = classInfo
    }
    
    func transform(input: Input) -> Output {
        let category = BehaviorRelay(value: classInfo.category.description)
        let title = BehaviorRelay(value: classInfo.title)
        let countDescription = BehaviorRelay(value: "0 / \(maxCount)")
        let countWarning = BehaviorRelay(value: false)
        let saveEnabled = BehaviorRelay(value: false)
        let popVC = PublishRelay<Void>()
        let toastMessage = PublishRelay<String>()
        let errorAlert = PublishRelay<String>()
        
        input.contentText
            .orEmpty
            .distinctUntilChanged()
            .map { $0.isEmpty }
        
        let count = input.contentText
            .orEmpty
            .distinctUntilChanged { $0.count == $1.count }
            .map {
                 $0.ranges(of: /\S/).count
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
            
        
        input.dismissButtonTap?
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: popVC)
            .disposed(by: disposeBag)
        
        return Output(category: category,
                      title: title,
                      countDescription: countDescription,
                      countWarning: countWarning,
                      saveEnabled: saveEnabled,
                      popVC: popVC,
                      toastMessage: toastMessage,
                      errorAlert: errorAlert
        )
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
