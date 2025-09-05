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
    private let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init(classInfo: ClassCoreInfo) {
        self.classInfo = classInfo
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
}
