//
//  NetworkManager.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation
import Network
import Alamofire
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor = NWPathMonitor()
    
    private(set) var isConnected = true
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            if path.status == .satisfied {
                isConnected = true
            } else {
                isConnected = false
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    func callRequestWithNoResponse(url: Router) -> Single<Result<Void, APIError>> {
        return Single.create { [weak self] observer in
            guard let self else {
                observer(.success(.failure(.unknown)))
                return Disposables.create()
            }
            guard isConnected else {
                observer(.success(.failure(.network)))
                return Disposables.create()
            }
            print("--------- API 호출 ---------")
            AF.request(url)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        observer(.success(.success(())))
                    case .failure:
                        if let data = response.data, let errorResult = try? JSONDecoder().decode(APIErrorResult.self, from: data) {
                            observer(.success(.failure(.some(message: errorResult.message))))
                        } else {
                            observer(.success(.failure(APIError.unknown)))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    func callRequest<T: Decodable> (url: Router, type: T.Type = T.self) -> Single<Result<T, APIError>> {
        return Single.create { [weak self] observer in
            guard let self else {
                observer(.success(.failure(.unknown)))
                return Disposables.create()
            }
            guard isConnected else {
                observer(.success(.failure(.network)))
                return Disposables.create()
            }
            print("--------- API 호출 ---------")
            AF.request(url)
                .validate()
                .responseDecodable(of: type) { response in
                switch response.result {
                case .success(let value):
                    observer(.success(.success(value)))
                case .failure:
                    if let data = response.data, let errorResult = try? JSONDecoder().decode(APIErrorResult.self, from: data) {
                        observer(.success(.failure(.some(message: errorResult.message))))
                    } else {
                        observer(.success(.failure(APIError.unknown)))
                    }
                }
            }
            return Disposables.create()
        }
    }
}
