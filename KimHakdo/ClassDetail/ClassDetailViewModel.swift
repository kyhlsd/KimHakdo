//
//  ClassDetailViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ClassDetailViewModel: BaseViewModel {
    
    private let id: String
    private let disposeBag = DisposeBag()
    
    init(id: String) {
        self.id = id
    }
    
    struct Input {
        let callRequest: PublishRelay<Void>
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
        let isFavorited: PublishRelay<Bool>
        let errorAlert: PublishRelay<String>
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
        let isFavorited = PublishRelay<Bool>()
        let errorAlert = PublishRelay<String>()
        
        input.callRequest
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
                    isFavorited.accept(value.isLiked)
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            navTitle: navTitle,
            imageURLs: imageURLs,
            profileImage: profileImage,
            nickname: nickname,
            location: location,
            date: date,
            capacity: capacity,
            description: description,
            isFavorited: isFavorited,
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
