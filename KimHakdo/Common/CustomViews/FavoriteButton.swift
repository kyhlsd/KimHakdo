//
//  FavoriteButton.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit
import RxSwift
import RxCocoa

protocol FavoriteButtonDelegate: AnyObject {
    func presentErrorAlert(title: String, message: String)
    func updateLikeStatus(classId: String, isLiked: Bool)
}

final class FavoriteButton: UIButton {
    
    private let classId = BehaviorRelay<String?>(value: nil)
    private let isLiked = BehaviorRelay<Bool?>(value: nil)
    private let errorMessage = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    weak var delegate: FavoriteButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(classId: String, likeStatus: Bool) {
        self.classId.accept(classId)
        self.isLiked.accept(likeStatus)
    }
    
    func reset() {
        classId.accept(nil)
        isLiked.accept(nil)
    }
    
    private func bind() {
        
        let data = Observable.combineLatest(classId, isLiked)
            .compactMap { data -> (String, Bool)? in
                let (classId, isLiked) = data
                guard let classId, let isLiked else { return nil }
                return (classId, isLiked)
            }
        
        rx.tap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .withLatestFrom(data)
            .flatMap { data in
                let (id, likeStatus) = data
                return NetworkManager.shared.callRequest(url: .updateFavorite(classId: id, isFavorite: !likeStatus), type: FavoriteResult.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.isLiked.accept(value.isLiked)
                    if let classId = owner.classId.value {
                        owner.delegate?.updateLikeStatus(classId: classId, isLiked: value.isLiked)
                    }
                case .failure(let error):
                    owner.errorMessage.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        isLiked
            .distinctUntilChanged()
            .bind(with: self) { owner, isLiked in
                owner.setImage(isLiked: isLiked)
            }
            .disposed(by: disposeBag)
        
        errorMessage
            .bind(with: self) { owner, message in
                owner.delegate?.presentErrorAlert(title: "좋아요 상태 변경 실패", message: message)
            }
            .disposed(by: disposeBag)
    }
    
    private func setImage(isLiked: Bool?) {
        let image: UIImage = (isLiked == true) ? .likeButtonFill : .likeButton
        let config = UIImage.SymbolConfiguration(scale: .large)
        let resized = image.applyingSymbolConfiguration(config)
        setImage(resized, for: .normal)
    }
    
    func setStatusWithBorder(likeStatus: Bool) {
        let image = UIImage(systemName: likeStatus ? "heart.fill" : "heart")
        tintColor = likeStatus ? .point : .border
        let config = UIImage.SymbolConfiguration(scale: .large)
        let resized = image?.applyingSymbolConfiguration(config)
        setImage(resized, for: .normal)
    }
}

struct FavoriteResult: Decodable {
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case isLiked = "like_status"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
    }
}
