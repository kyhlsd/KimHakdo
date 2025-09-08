//
//  SearchClassViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/6/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchClassViewModel: BaseViewModel, FavoriteButtonDelegate {
    
    private let disposeBag = DisposeBag()
    let toastMessage = PublishRelay<String>()
    let errorAlert = PublishRelay<(String, String)>()
    
    struct Input {
        let searchText: ControlProperty<String?>
        let searchButtonClicked: ControlEvent<Void>
        let willDisplayCell: Observable<Void>
        let classSelected: ControlEvent<ClassResult>
        let collectionViewTapGesture: Observable<Void>
    }
    
    struct Output {
        let guideText: BehaviorRelay<String>
        let searchedClassList: BehaviorRelay<[ClassResult]>
        let scrollToTop: PublishRelay<IndexPath>
        let hideKeyboard: PublishRelay<Void>
        let pushDetailVC: PublishRelay<String>
        let toastMessage: PublishRelay<String>
        let errorAlert: PublishRelay<(String, String)>
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func transform(input: Input) -> Output {
        let guideText = BehaviorRelay(value: "원하는 클래스가 있으신가요?")
        let searchedClassList = BehaviorRelay(value: [ClassResult]())
        let scrollToTop = PublishRelay<IndexPath>()
        let hideKeyboard = PublishRelay<Void>()
        let pushDetailVC = PublishRelay<String>()
        let toastMessage = self.toastMessage
        let errorAlert = self.errorAlert
        
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
                    errorAlert.accept(("검색 실패", error.localizedDescription))
                }
            }
            .disposed(by: disposeBag)
        
        searchedClassList
            .skip(1)
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
        
        NotificationManager.shared.receiveIsLikedChanged { classId, isLiked in
            var list = searchedClassList.value
            if let index = list.firstIndex(where: {
                $0.classId == classId
            }) {
                list[index].isLiked = isLiked
                searchedClassList.accept(list)
            }
        }
        
        return Output(
            guideText: guideText,
            searchedClassList: searchedClassList,
            scrollToTop: scrollToTop,
            hideKeyboard: hideKeyboard,
            pushDetailVC: pushDetailVC,
            toastMessage: toastMessage,
            errorAlert: errorAlert
        )
    }
}
