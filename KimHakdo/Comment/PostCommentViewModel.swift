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
    private let disposeBag = DisposeBag()
    
    struct Input {
        let textInput: ControlProperty<String?>
        let saveButtonTap: ControlEvent<()>?
        let dismissButtonTap: ControlEvent<()>?
    }
    
    struct Output {
        let category: BehaviorRelay<String>
        let title: BehaviorRelay<String>
        let countDescription: BehaviorRelay<String>
        let saveEnabled: BehaviorRelay<Bool>
        let popVC: PublishRelay<Void>
    }
    
    init(classInfo: ClassCoreInfo) {
        self.classInfo = classInfo
    }
    
    func transform(input: Input) -> Output {
        let category = BehaviorRelay(value: classInfo.category.description)
        let title = BehaviorRelay(value: classInfo.title)
        let countDescription = BehaviorRelay(value: "0 / \(maxCount)")
        let saveEnabled = BehaviorRelay(value: false)
        let popVC = PublishRelay<Void>()
        
        let count = input.textInput
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
        
        return Output(category: category,
                      title: title,
                      countDescription: countDescription,
                      saveEnabled: saveEnabled,
                      popVC: popVC)
    }
    
    private func getCountDescription(count: Int) -> String {
        return count > maxCount ? "\(maxCount)글자 초과" : "\(count) / \(maxCount)"
    }
}
