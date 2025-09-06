//
//  SearchClassViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchClassViewModel: BaseViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchText: ControlProperty<String?>
        let searchButtonClicked: ControlEvent<Void>
        let willDisplayCell: Observable<Void>
        let classSelected: ControlEvent<ClassResult>
        let collectionViewTapGesture: Observable<Void>
    }
    
    struct Output {
        let guideText: BehaviorRelay<String>
        let searchedClassList: PublishRelay<[ClassResult]>
        let scrollToTop: PublishRelay<IndexPath>
        let hideKeyboard: PublishRelay<Void>
        let pushDetailVC: PublishRelay<String>
        let errorAlert: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let guideText = BehaviorRelay(value: "원하는 클래스가 있으신가요?")
        let searchedClassList = PublishRelay<[ClassResult]>()
        let scrollToTop = PublishRelay<IndexPath>()
        let hideKeyboard = PublishRelay<Void>()
        let pushDetailVC = PublishRelay<String>()
        let errorAlert = PublishRelay<String>()
        
        let lastUpdateDate = PublishRelay<Date>()
        
        input.searchButtonClicked
            .withLatestFrom(input.searchText.orEmpty)
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1 }
            .distinctUntilChanged()
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .flatMap {
                NetworkManager.shared.callRequest(url: .searchClass(keyword: $0), type: ClassListResult.self)
            }
            .bind { result in
                switch result {
                case .success(let value):
                    searchedClassList.accept(value.data)
                    lastUpdateDate.accept(Date())
                case .failure(let error):
                    errorAlert.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        searchedClassList
            .map { $0.isEmpty ? "검색 결과가 없습니다" : ""}
            .distinctUntilChanged()
            .bind(to: guideText)
            .disposed(by: disposeBag)
        
        let willDisplayCell = input.willDisplayCell
            .withLatestFrom(lastUpdateDate)
            .distinctUntilChanged()
            .share()
        
        willDisplayCell
            .map { _ in IndexPath(item: 0, section: 0) }
            .bind(to: scrollToTop)
            .disposed(by: disposeBag)
        
        willDisplayCell
            .map { _ in () }
            .bind(to: hideKeyboard)
            .disposed(by: disposeBag)
        
        input.classSelected
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .map { $0.classId }
            .bind(to: pushDetailVC)
            .disposed(by: disposeBag)
        
        input.collectionViewTapGesture
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: hideKeyboard)
            .disposed(by: disposeBag)
        
        return Output(
            guideText: guideText,
            searchedClassList: searchedClassList,
            scrollToTop: scrollToTop,
            hideKeyboard: hideKeyboard,
            pushDetailVC: pushDetailVC,
            errorAlert: errorAlert
        )
    }
}
