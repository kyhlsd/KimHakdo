//
//  LookupClassViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation
import RxSwift
import RxCocoa

final class LookupClassViewModel: BaseViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let selectCategory: ControlEvent<(ClassCategory, Bool)>
    }
    
    struct Output {
        let categories: BehaviorRelay<[(ClassCategory, Bool)]>
        let courses: PublishRelay<[Course]>
    }
    
    func transform(input: Input) -> Output {
        let categories = BehaviorRelay(value: getInitialCategories())
        let courses = PublishRelay<[Course]>()
        let callRequest = PublishRelay<Void>()
        
        callRequest
            .flatMap { _ in
                NetworkManager.shared.callRequest(url: .lookupCourses, type: LookupCoursesResult.self)
            }
            .bind { result in
                switch result {
                case .success(let value):
                    courses.accept(value.data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.viewDidLoad
            .bind(to: callRequest)
            .disposed(by: disposeBag)
        
        input.selectCategory
            .distinctUntilChanged { ($0.0 == $1.0) && ($0.1 == $1.1) }
            .flatMap { [weak self] (category, _) in
                guard let self else { return categories.asObservable() }
                return self.updateSelectedCategories(current: categories.value, selected: category)
            }
            .bind(to: categories)
            .disposed(by: disposeBag)
        
        return Output(
            categories: categories,
            courses: courses
        )
    }
    
    private func getInitialCategories() -> [(ClassCategory, Bool)] {
        var initialCategories = ClassCategory.allCases.map { ($0, false) }
        initialCategories[0].1 = true
        return initialCategories
    }
    
    private func updateSelectedCategories(current: [(ClassCategory, Bool)], selected: ClassCategory) -> Observable<[(ClassCategory, Bool)]> {
        return Observable<[(ClassCategory, Bool)]>.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            if selected == .total { // 전체를 선택했을 경우 전체만 선택
                observer.onNext(self.getInitialCategories())
            } else {
                if let index = current.map({ $0.0 }).firstIndex(of: selected) {
                    // 그 외에는 선택 상태 토글
                    var data = current
                    data[0].1 = false
                    data[index].1.toggle()
                    
                    // 선택된 카테고리가 하나도 없으면 전체만 선택
                    if data.filter({ $0.1 == true }).isEmpty {
                        data = self.getInitialCategories()
                    }
                    observer.onNext(data)
                }
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
