//
//  NetworkManager.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func callRequest<T: Decodable> (url: Router, type: T.Type = T.self) -> Single<Result<T, APIError>> {
        return Single.create { observer in
            AF.request(url).responseDecodable(of: type) { response in
                switch response.result {
                case .success(let value):
                    observer(.success(.success(value)))
                case .failure:
                    // TODO: 에러 처리
                    observer(.success(.failure(APIError.unknown)))
                }
            }
            return Disposables.create()
        }
    }
}
