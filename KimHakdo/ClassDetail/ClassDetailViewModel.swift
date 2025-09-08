//
//  ClassDetailViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ClassDetailViewModel: BaseViewModel, FavoriteButtonDelegate {
    
    private let id: String
    private let disposeBag = DisposeBag()
    let errorAlert = PublishRelay<(String, String)>()
    
    init(id: String) {
        self.id = id
    }
    
    struct Input {
        let callRequestForDetail: PublishRelay<Void>
        let callRequestForComments: PublishRelay<Void>
        let commentsButtonTap: ControlEvent<Void>
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    struct Output {
        let navTitle: PublishRelay<String>
        let imageURLs: PublishRelay<[String]>
        let profileImage: PublishRelay<String?>
        let nickname: PublishRelay<String>
        let location: PublishRelay<String>
        let date: PublishRelay<String>
        let capacity: PublishRelay<String>
        let description: PublishRelay<String>
        let isLikedData: PublishRelay<(String, Bool)>
        let commentsButtonTitle: BehaviorRelay<String>
        let commentsButtonEnabled: BehaviorRelay<Bool>
        let pushCommentVC: PublishRelay<([Comment], ClassCoreInfo)>
        let errorAlert: PublishRelay<(String, String)>
    }
    
    func transform(input: Input) -> Output {
        let navTitle = PublishRelay<String>()
        let imageURLs = PublishRelay<[String]>()
        let profileImage = PublishRelay<String?>()
        let nickname = PublishRelay<String>()
        let location = PublishRelay<String>()
        let date = PublishRelay<String>()
        let capacity = PublishRelay<String>()
        let description = PublishRelay<String>()
        let isLikedData = PublishRelay<(String, Bool)>()
        let commentsButtonTitle = BehaviorRelay<String>(value: "댓글보기 (0)")
        let commentsButtonEnabled = BehaviorRelay<Bool>(value: false)
        let pushCommentVC = PublishRelay<([Comment], ClassCoreInfo)>()
        let errorAlert = self.errorAlert
                
        let comments = PublishRelay<[Comment]>()
        let classCoreInfo = PublishRelay<ClassCoreInfo>()
        
        input.callRequestForDetail
            .flatMap { [weak self] in
                guard let self else {
                    return Single<Result<ClassDetailResult, APIError>>.just(.failure(.unknown))
                }
                return NetworkManager.shared.callRequest(url: .getDetail(id: self.id), type: ClassDetailResult.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    navTitle.accept(value.title)
                    imageURLs.accept(value.imageURLs)
                    profileImage.accept(value.creator.profileImage)
                    nickname.accept(value.creator.nick)
                    location.accept(value.location ?? "미정")
                    date.accept(owner.dateToString(date: value.date))
                    capacity.accept(owner.capacityToString(capacity: value.capacity))
                    description.accept(value.description)
                    isLikedData.accept((value.classId, value.isLiked))
                    classCoreInfo.accept(ClassCoreInfo(classId: value.classId, title: value.title, category: value.category))
                case .failure(let error):
                    errorAlert.accept(("데이터 불러오기 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        input.callRequestForComments
            .flatMap { [weak self] in
                guard let self else {
                    return Single<Result<CommentsResult, APIError>>.just(.failure(.unknown))
                }
                return NetworkManager.shared.callRequest(url: .lookupComment(id: id), type: CommentsResult.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    comments.accept(value.data)
                case .failure(let error):
                    errorAlert.accept(("데이터 불러오기 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        comments
            .map { "댓글보기 \($0.count)" }
            .distinctUntilChanged()
            .bind(to: commentsButtonTitle)
            .disposed(by: disposeBag)
        
        comments
            .map { $0.count > 0 }
            .distinctUntilChanged()
            .bind(to: commentsButtonEnabled)
            .disposed(by: disposeBag)
        
        input.commentsButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(comments, classCoreInfo))
            .bind(to: pushCommentVC)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.receiveIsLikedChanged { [ weak self] classId, isLiked in
            if self?.id == classId {
                isLikedData.accept((classId, isLiked))
            }
        }
        
        return Output(
            navTitle: navTitle,
            imageURLs: imageURLs,
            profileImage: profileImage,
            nickname: nickname,
            location: location,
            date: date,
            capacity: capacity,
            description: description,
            isLikedData: isLikedData,
            commentsButtonTitle: commentsButtonTitle,
            commentsButtonEnabled: commentsButtonEnabled,
            pushCommentVC: pushCommentVC,
            errorAlert: errorAlert
        )
    }
    
    private func dateToString(date: Date?) -> String {
        if let date {
            return MyFormatter.userDate.string(from: date)
        } else {
            return "미정"
        }
    }
    
    private func capacityToString(capacity: Int?) -> String {
        if let capacity {
            return MyFormatter.number.string(from: NSNumber(value: capacity)) ?? "미정"
        } else {
            return "미정"
        }
    }
}
