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
    
    struct Input {
        let email: ControlProperty<String?>
        let password: ControlProperty<String?>
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
        
        let email = input.email.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
            
        let password = input.password.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
        
        Observable.combineLatest(email, password)
            .flatMap { [weak self] texts in
                guard let self else {
                    return Single<Result<Void, LoginInputError>>.just(.failure(.unknown))
                }
                return self.validateTexts(texts: texts)
            }
            .bind { result in
                switch result {
                case .success:
                    buttonEnabled.accept(true)
                    warningText.accept(" ")
                case .failure(let error):
                    buttonEnabled.accept(false)
                    warningText.accept(error.localizedDescription)
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
    
    private func validateTexts(texts: (String, String)) -> Single<Result<Void, LoginInputError>> {
        return Single<Result<Void, LoginInputError>>.create { [weak self] observer in
            guard let self else {
                observer(.success(.failure(.unknown)))
                return Disposables.create()
            }
            
            let (email, password) = texts
            do {
                try self.validateEmpty(text: email)
                try self.validateEmpty(text: password)
                try self.validateEmail(text: email)
                try self.validatePassword(text: password)
                observer(.success(.success(())))
            } catch let error as LoginInputError {
                observer(.success(.failure(error)))
            } catch {
                observer(.success(.failure(.unknown)))
            }
            return Disposables.create()
        }
    }
    
    private func validateEmpty(text: String) throws(LoginInputError) {
        if text.isEmpty {
            throw .empty
        }
    }
    
    private func validateEmail(text: String) throws(LoginInputError) {
        let emailPattern = /^.+@.+\.com$/
        guard let _ = text.wholeMatch(of: emailPattern) else {
            throw .invalidEmail
        }
    }
    
    private func validatePassword(text: String) throws(LoginInputError) {
        let min = 2
        let max = 10
        if text.count < min || text.count >= max {
            throw .invalidPasswordRange(min: min, max: max)
        }
    }
}
