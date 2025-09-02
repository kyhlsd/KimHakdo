//
//  PointButton.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import UIKit
import RxSwift
import RxCocoa

final class PointButton: UIButton {

    let isEnabledTrigger = BehaviorRelay(value: true)
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        bind()
    }
    
    private func setup() {
        titleLabel?.font = AppFont.button
        layer.cornerRadius = CornerRadius.small
        clipsToBounds = true
    }
    
    private func bind() {
        isEnabledTrigger.bind(with: self) { owner, value in
            owner.isEnabled = value
            owner.backgroundColor = value ? .point : .disabled
        }
        .disposed(by: disposeBag)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
