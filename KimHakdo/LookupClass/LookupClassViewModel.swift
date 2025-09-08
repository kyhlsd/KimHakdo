//
//  LookupClassViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation
import RxSwift
import RxCocoa

final class LookupClassViewModel: BaseViewModel, FavoriteButtonDelegate {
    
    private let disposeBag = DisposeBag()
    let errorAlert = PublishRelay<(String, String)>()
    
    struct Input {
        let callRequest: PublishRelay<Void>
        let selectCategory: ControlEvent<(ClassCategory, Bool)>
        let sortButtonTap: ControlEvent<Void>
        let willDisplayCell: Observable<Void>
        let classSelected: ControlEvent<ClassResult>
    }
    
    struct Output {
        let categories: BehaviorRelay<[(ClassCategory, Bool)]>
        let classList: PublishRelay<[ClassResult]>
        let countText: BehaviorRelay<String>
        let sortOption: BehaviorRelay<ClassSortOption>
        let scrollToTop: PublishRelay<IndexPath>
        let pushDetailVC: PublishRelay<String>
        let errorAlert: PublishRelay<(String, String)>
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func transform(input: Input) -> Output {
        let categories = BehaviorRelay(value: getInitialCategories())
        let classList = PublishRelay<[ClassResult]>()
        let countText = BehaviorRelay<String>(value: "0개")
        let sortOption = BehaviorRelay<ClassSortOption>(value: .latest)
        let scrollToTop = PublishRelay<IndexPath>()
        let pushDetailVC = PublishRelay<String>()
        let errorAlert = self.errorAlert
        
        let totalClass = BehaviorRelay(value: [ClassResult]())
        let filtered = Observable.combineLatest(totalClass, categories)
            .flatMap { [weak self] (total, category) in
                guard let self else {
                    return Observable.just([ClassResult]())
                }
                return self.filterByCategory(total: total, category: category)
            }
        let lastUpdateDate = PublishRelay<Date>()

        let conditionChanged = Observable.combineLatest(filtered, sortOption)
            .flatMap { [weak self] (filtered, option) in
                guard let self else {
                    return Observable.just([ClassResult]())
                }
                return self.sortClassList(list: filtered, option: option)
            }
            .share()
        
        var isLikedUpdated = false

        conditionChanged
            .bind(to: classList)
            .disposed(by: disposeBag)
        
        conditionChanged
            .map { _ in Date() }
            .bind { value in
                if isLikedUpdated {
                    isLikedUpdated.toggle()
                } else {
                    lastUpdateDate.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        classList
            .map {
                "\(MyFormatter.number.string(from: NSNumber(value: $0.count)) ?? "0")개"
            }
            .bind(to: countText)
            .disposed(by: disposeBag)
        
        input.callRequest
            .flatMap { _ in
                NetworkManager.shared.callRequest(url: .lookupClass, type: ClassListResult.self)
            }
            .bind { result in
                switch result {
                case .success(let value):
                    totalClass.accept(value.data)
                case .failure(let error):
                    errorAlert.accept(("데이터 불러오기 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        input.selectCategory
            .distinctUntilChanged { ($0.0 == $1.0) && ($0.1 == $1.1) }
            .flatMap { [weak self] (category, _) in
                guard let self else { return categories.asObservable() }
                return self.updateSelectedCategories(current: categories.value, selected: category)
            }
            .bind(to: categories)
            .disposed(by: disposeBag)
        
        input.sortButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind { _ in
                let current = sortOption.value
                sortOption.accept(current.toggled)
            }
            .disposed(by: disposeBag)
        
        input.willDisplayCell
            .withLatestFrom(lastUpdateDate)
            .distinctUntilChanged()
            .map { _ in IndexPath(item: 0, section: 0) }
            .bind(to: scrollToTop)
            .disposed(by: disposeBag)
        
        input.classSelected
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .map { $0.classId }
            .bind(to: pushDetailVC)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.receiveIsLikcedChanged { classId, isLiked in
            var list = totalClass.value
            if let index = list.firstIndex(where: {
                $0.classId == classId
            }) {
                list[index].isLiked = isLiked
            }
            isLikedUpdated = true
            totalClass.accept(list)
        }
        
        return Output(
            categories: categories,
            classList: classList,
            countText: countText,
            sortOption: sortOption,
            scrollToTop: scrollToTop,
            pushDetailVC: pushDetailVC,
            errorAlert: errorAlert
        )
    }
    
    private func sortClassList(list: [ClassResult], option: ClassSortOption) -> Observable<[ClassResult]> {
        return Observable<[ClassResult]>.create { observer in
            let sorted: [ClassResult]
            switch option {
            case .latest:
                sorted = list.sorted {
                    $0.createdAt > $1.createdAt
                }
            case .highPrice:
                sorted = list.sorted {
                    let first = $0.price ?? 0
                    let second = $1.price ?? 0
                    if first == second {
                        return $0.createdAt > $1.createdAt
                    } else {
                        return first > second
                    }
                }
            }
            observer.onNext(sorted)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    private func filterByCategory(total: [ClassResult], category: [(ClassCategory, Bool)]) -> Observable<[ClassResult]> {
        return Observable<[ClassResult]>.create { observer in
            if category[0].1 {
                observer.onNext(total)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let selectedCategories = category
                .filter { $0.1 }
                .map { $0.0 }
            
            let selectedClasses = total.filter{
                selectedCategories.contains($0.category)
            }
            
            observer.onNext(selectedClasses)
            observer.onCompleted()
            return Disposables.create()
        }
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
