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
    
    let toastMessage = PublishRelay<String>()
    let errorAlert = PublishRelay<(String, String)>()
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
    
    // MARK: Transform
    func transform(input: Input) -> Output {
        let guideText = BehaviorRelay(value: "원하는 클래스가 있으신가요?")
        let searchedClassList = BehaviorRelay(value: [ClassResult]())
        let scrollToTop = PublishRelay<IndexPath>()
        let hideKeyboard = PublishRelay<Void>()
        let pushDetailVC = PublishRelay<String>()
        let toastMessage = self.toastMessage
        let errorAlert = self.errorAlert
        
        let lastUpdateDate = PublishRelay<Date>()
        
        // 검색, 성공 시 현재 시간 aceept
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
        
        // 검색 결과에 따른 문구
        searchedClassList
            .skip(1)
            .map { $0.isEmpty ? "검색 결과가 없습니다" : ""}
            .distinctUntilChanged()
            .bind(to: guideText)
            .disposed(by: disposeBag)
        
        // 좋아요 변경으로 인한 업데이트는 무시
        let willDisplayCell = input.willDisplayCell
            .withLatestFrom(lastUpdateDate)
            .distinctUntilChanged()
            .share()
        
        // CollectionView 그려진 후 scrollToTop
        willDisplayCell
            .map { _ in IndexPath(item: 0, section: 0) }
            .bind(to: scrollToTop)
            .disposed(by: disposeBag)
        
        // 검색 결과가 있다면 키보드 내리기
        willDisplayCell
            .map { _ in () }
            .bind(to: hideKeyboard)
            .disposed(by: disposeBag)
        
        // 클래스 선택 시
        input.classSelected
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .map { $0.classId }
            .bind(to: pushDetailVC)
            .disposed(by: disposeBag)
        
        // 검색 결과가 없을 때에도 화면 터치 시 키보드 내리기 위함
        input.collectionViewTapGesture
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: hideKeyboard)
            .disposed(by: disposeBag)
        
        // 좋아요 변경 시 동기화
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
