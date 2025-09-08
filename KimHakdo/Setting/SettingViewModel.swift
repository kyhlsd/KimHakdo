//
//  SettingViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel: BaseViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let logoutButtonTap: ControlEvent<Void>
        let okButtonTap: PublishRelay<Void>
    }
    
    struct Output {
        let logoutAlert: PublishRelay<(String, String)>
        let convertToLoginVC: PublishRelay<Void>
    }
    
    // MARK: Transform
    func transform(input: Input) -> Output {
        let logoutAlert = PublishRelay<(String, String)>()
        let convertToLoginVC = PublishRelay<Void>()
        
        // 로그아웃 버튼 탭하면 Alert
        input.logoutButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .map { _ in ("로그아웃", "로그아웃 하시겠습니까?")}
            .bind(to: logoutAlert)
            .disposed(by: disposeBag)
        
        let okButtonTap = input.okButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .share()
        
        // LoginVC로 화면 전환
        okButtonTap
            .bind(to: convertToLoginVC)
            .disposed(by: disposeBag)
        
        // 정보 삭제
        okButtonTap
            .bind { _ in
                UserDefaultHelper.clear()
            }
            .disposed(by: disposeBag)
        
        return Output(
            logoutAlert: logoutAlert,
            convertToLoginVC: convertToLoginVC
        )
    }
    
}
