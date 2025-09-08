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
        
        // email 검증
        let emailSucceed = BehaviorRelay(value: false)
        let emailError = BehaviorRelay(value: LoginInputError.empty)
        email
            .flatMap { [weak self] text in
                guard let self else {
                    return Single<Result<Void, LoginInputError>>.just(.failure(.unknown))
                }
                return self.validateText(text: text, isEmail: true)
            }
            .bind { result in
                switch result {
                case .success:
                    emailSucceed.accept(true)
                case .failure(let error):
                    emailSucceed.accept(false)
                    emailError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        // password 검증
        let passwordSucceed = BehaviorRelay(value: false)
        let passwordError = BehaviorRelay(value: LoginInputError.empty)
        password
            .flatMap { [weak self] text in
                guard let self else {
                    return Single<Result<Void, LoginInputError>>.just(.failure(.unknown))
                }
                return self.validateText(text: text, isEmail: false)
            }
            .bind { result in
                switch result {
                case .success:
                    passwordSucceed.accept(true)
                case .failure(let error):
                    passwordSucceed.accept(false)
                    passwordError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        // 둘 다 성공 시 버튼 활성화
        Observable.combineLatest(emailSucceed, passwordSucceed)
            .map { $0 && $1 }
            .distinctUntilChanged()
            .bind(to: buttonEnabled)
            .disposed(by: disposeBag)
        
        // WarningMessage
        Observable.combineLatest(emailSucceed, passwordSucceed, emailError, passwordError)
            .skip(1)
            .bind { data in
                let (emailSucceed, passwordSucceed, emailError, passwordError) = data
                
                if emailSucceed {
                    if passwordSucceed { // email: 성공, password: 성공
                        warningText.accept("")
                    } else { // email: 성공, password: 실패
                        warningText.accept(passwordError.localizedDescription)
                    }
                } else {
                    if passwordSucceed { // email: 실패, password: 성공
                        warningText.accept(emailError.localizedDescription)
                    } else if passwordError == .empty { // email: 실패, password: 실패(empty) -> empty 우선
                        warningText.accept(passwordError.localizedDescription)
                    } else { // email: 실패, password: 실패(nonEmpty)
                        warningText.accept(emailError.localizedDescription)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 로그인 성공 시 토큰/아이디 저장, 실패 시 Alert
        input.buttonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(email, password))
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
    
    // 텍스트 검증
    private func validateText(text: String, isEmail: Bool) -> Single<Result<Void, LoginInputError>> {
        return Single<Result<Void, LoginInputError>>.create { [weak self] observer in
            guard let self else {
                observer(.success(.failure(.unknown)))
                return Disposables.create()
            }
            
            do {
                try self.validateEmpty(text: text)
                isEmail ? try self.validateEmailFormat(text: text) : try self.validatePasswordRange(text: text)
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
    private func validateEmailFormat(text: String) throws(LoginInputError) {
        let emailPattern = /^.+@.+\.com$/
        guard let _ = text.wholeMatch(of: emailPattern) else {
            throw .invalidEmail
        }
    }
    
    // 패스워드 검증 - 2글자 이상 10글자 미만
    private func validatePasswordRange(text: String) throws(LoginInputError) {
        let min = 2
        let max = 10
        if text.count < min || text.count >= max {
            throw .invalidPasswordRange(min: min, max: max)
        }
    }
}
