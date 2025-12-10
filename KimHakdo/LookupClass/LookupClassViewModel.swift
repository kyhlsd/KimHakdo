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
    
    let toastMessage = PublishRelay<String>()
    let errorAlert = PublishRelay<(String, String)>()
    private let disposeBag = DisposeBag()
    
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
        let toastMessage: PublishRelay<String>
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
        let toastMessage = self.toastMessage
        let errorAlert = self.errorAlert
        
        var isLikedUpdated = false
        
        let totalClass = BehaviorRelay(value: [ClassResult]())
        let filtered = Observable.combineLatest(totalClass, categories)
            .flatMap { [weak self] (total, category) in
                guard let self else {
                    return Observable.just([ClassResult]())
                }
                return self.filterByCategory(total: total, category: category)
            }
        let lastUpdateDate = PublishRelay<Date>()

        // 카테고리, 정렬 조건 변경 시
        Observable.combineLatest(filtered, sortOption)
            .flatMap { [weak self] (filtered, option) in
                guard let self else {
                    return Observable.just([ClassResult]())
                }
                return self.sortClassList(list: filtered, option: option)
            }
            .bind { value in
                if isLikedUpdated {
                    isLikedUpdated = false
                } else {
                    lastUpdateDate.accept(Date()) // 찜 변경으로 인한 리스트 변경이 아니라면 현재 시간 accept
                }
                classList.accept(value)
            }
            .disposed(by: disposeBag)
        
        // 클래스 개수
        classList
            .map {
                "\(MyFormatter.number.string(from: NSNumber(value: $0.count)) ?? "0")개"
            }
            .bind(to: countText)
            .disposed(by: disposeBag)
        
        // 전체 클래스 fetch
        input.callRequest
            .flatMap { _ in
                switch AppConfig.current {
                case .dev:
                    return NetworkManager.shared.callRequest(url: .lookupClass, type: ClassListResult.self)
                case .dummy:
                    return Single.just(.success(ClassListResult(data: ClassListResult.dummy)))
                }
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
        
        // 카테고리 collectionView
        input.selectCategory
            .distinctUntilChanged { ($0.0 == $1.0) && ($0.1 == $1.1) }
            .flatMap { [weak self] (category, _) in
                guard let self else { return categories.asObservable() }
                return self.updateSelectedCategories(current: categories.value, selected: category)
            }
            .bind(to: categories)
            .disposed(by: disposeBag)
        
        // 정렬 버튼
        input.sortButtonTap
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind { _ in
                let current = sortOption.value
                sortOption.accept(current.toggled)
            }
            .disposed(by: disposeBag)
        
        // CollectionView 그려진 후 ScrollToTop, 찜으로 인한 변경은 무시
        input.willDisplayCell
            .withLatestFrom(lastUpdateDate)
            .distinctUntilChanged()
            .map { _ in IndexPath(item: 0, section: 0) }
            .bind(to: scrollToTop)
            .disposed(by: disposeBag)
        
        // 클래스 선택 시
        input.classSelected
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .map { $0.classId }
            .bind(to: pushDetailVC)
            .disposed(by: disposeBag)
        
        // 좋아요 변경 동기화
        NotificationManager.shared.receiveIsLikedChanged { classId, isLiked in
            var list = totalClass.value
            if let index = list.firstIndex(where: {
                $0.classId == classId
            }) {
                list[index].isLiked = isLiked
                isLikedUpdated = true
                totalClass.accept(list)
            }
        }
        
        return Output(
            categories: categories,
            classList: classList,
            countText: countText,
            sortOption: sortOption,
            scrollToTop: scrollToTop,
            pushDetailVC: pushDetailVC,
            toastMessage: toastMessage,
            errorAlert: errorAlert
        )
    }
    
    // MARK: SubMethods
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
    
    // 카테고리 필터 반영
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
    
    // 전체만 선택된 상태
    private func getInitialCategories() -> [(ClassCategory, Bool)] {
        var initialCategories = ClassCategory.allCases.map { ($0, false) }
        initialCategories[0].1 = true
        return initialCategories
    }
    
    // 카테고리 선택 시 업데이트
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
