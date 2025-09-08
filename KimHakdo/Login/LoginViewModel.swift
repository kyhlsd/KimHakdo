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
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let email: ControlProperty<String?>
        let password: ControlProperty<String?>
        let buttonTap: ControlEvent<Void>
    }
    
    struct Output {
        let buttonEnabled: BehaviorRelay<Bool>
        let firstResponder: Observable<Void>
        let warningText: PublishRelay<String>
        let convertToLookupVC: PublishRelay<Void>
        let errorAlert: PublishRelay<String>
    }
    
    // MARK: Transform
    func transform(input: Input) -> Output {
        let buttonEnabled = BehaviorRelay(value: false)
        let firstResponder = Observable.just(())
        let warningText = PublishRelay<String>()
        let convertToLookupVC = PublishRelay<Void>()
        let errorAlert = PublishRelay<String>()
        
        let email = input.email.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
        let password = input.password.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
        let inputTexts = Observable.combineLatest(email, password)
            .share()
        
        // 텍스트 검증
        inputTexts
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
        
        // 로그인 성공 시 토큰/아이디 저장, 실패 시 Alert
        input.buttonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(inputTexts)
            .flatMap { (email, password) in
                NetworkManager.shared.callRequest(url: .login(email: email, password: password), type: LoginResult.self)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.saveToken(token: value.accessToken)
                    owner.saveId(userId: value.userId)
                    convertToLookupVC.accept(())
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            buttonEnabled: buttonEnabled,
            firstResponder: firstResponder,
            warningText: warningText,
            convertToLookupVC: convertToLookupVC,
            errorAlert: errorAlert
        )
    }
    
    // MARK: SubMethods
    private func saveToken(token: String) {
        UserDefaultHelper.token = token
    }

    private func saveId(userId: String) {
        UserDefaultHelper.userId = userId
    }
    
    // warning 문구 순위: empty -> email -> password
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
    
    // 이메일 검증 - 한 글자 이상 + @ + 한 글자 이상 + .com
    private func validateEmail(text: String) throws(LoginInputError) {
        let emailPattern = /^.+@.+\.com$/
        guard let _ = text.wholeMatch(of: emailPattern) else {
            throw .invalidEmail
        }
    }
    
    // 패스워드 검증 - 2글자 이상 10글자 미만
    private func validatePassword(text: String) throws(LoginInputError) {
        let min = 2
        let max = 10
        if text.count < min || text.count >= max {
            throw .invalidPasswordRange(min: min, max: max)
        }
    }
}
