//
//  LoginViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: BaseViewModel {
    
    struct Input {
        let emailText: ControlProperty<String?>
        let passwordText: ControlProperty<String?>
        let buttonTap: ControlEvent<Void>
    }
    
    struct Output {
        let buttonEnabled: BehaviorRelay<Bool>
        let firstResponder: Observable<Void>
        let warningText: PublishRelay<String>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let buttonEnabled = BehaviorRelay(value: false)
        let firstResponder = Observable.just(())
        let warningText = PublishRelay<String>()
        let isValidEmail = PublishRelay<Bool>()
        let isValidPassword = PublishRelay<Bool>()
        
        Observable.combineLatest(isValidEmail, isValidPassword)
            .map { $0 && $1 }
            .bind(to: buttonEnabled)
            .disposed(by: disposeBag)
        
        input.emailText.orEmpty
            .distinctUntilChanged()
            .flatMap { [weak self] text in
                guard let self else {
                    return Single<Result<Void, LoginInputError>>.just(.failure(.unknown))
                }
                return self.validateEmail(text: text)
            }
            .bind { result in
                switch result {
                case .success:
                    isValidEmail.accept(true)
//                    warningText.accept(" ")
                case .failure(let error):
                    isValidEmail.accept(false)
//                    warningText.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.passwordText.orEmpty
            .distinctUntilChanged()
            .flatMap { [weak self] text in
                guard let self else {
                    return Single<Result<Void, LoginInputError>>.just(.failure(.unknown))
                }
                return self.validatePassword(text: text)
            }
            .bind { result in
                switch result {
                case .success:
                    isValidPassword.accept(true)
                case .failure(let error):
                    isValidPassword.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.buttonTap
            .bind {
                print("buttonTap")
            }
            .disposed(by: disposeBag)
        
        return Output(
            buttonEnabled: buttonEnabled,
            firstResponder: firstResponder,
            warningText: warningText
        )
    }
    
    private func validateEmail(text: String) -> Single<Result<Void, LoginInputError>> {
        return Single<Result<Void, LoginInputError>>.create { observer in
            let emailPattern = /^.+@.+\.com$/
            if let _ = text.wholeMatch(of: emailPattern) {
                observer(.success(.success(())))
            } else {
                observer(.success(.failure(.invalidEmail)))
            }
            return Disposables.create()
        }
    }
    
    private func validatePassword(text: String) -> Single<Result<Void, LoginInputError>> {
        return Single<Result<Void, LoginInputError>>.create { observer in
            let min = 2
            let max = 10
            if text.count >= min && text.count < max {
                observer(.success(.success(())))
            } else {
                observer(.success(.failure(.invalidPasswordRange(min: min, max: max))))
            }
            return Disposables.create()
        }
    }
    
}
enum LoginInputError: LocalizedError {
    case invalidEmail
    case invalidPasswordRange(min: Int, max: Int)
    case empty
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "@와 .com, 사이에 1자 이상의 문자를 포함해주세요."
        case .invalidPasswordRange(let min, let max):
            return "비밀번호는 \(min)글자 이상 \(max)글자 미만으로 설정해주세요."
        case .empty:
            return "이메일과 비밀번호를 입력해주세요."
        case .unknown:
            return "알 수 없는 에러가 발생했습니다."
        }
    }
}
