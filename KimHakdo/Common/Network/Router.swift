//
//  Router.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    case login(email: String, password: String)
    
    var baseURL: String {
       return APIInfo.baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
        
    var version: String {
        return "v1"
    }
    
    var paths: String {
        switch self {
        case .login:
            return "/\(version)/users/login"
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .login:
            return []
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .login:
            return Headers.asHTTPHeaders([
                .contentType,
                .sesacKey
            ])
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = try baseURL.asURL()
        url = url.appendingPathComponent(paths)
        url = url.appending(queryItems: queryItems)
        var urlRequest = try URLRequest(url: url, method: method, headers: headers)
        urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest
    }
    
    enum Headers {
        case contentType
        case sesacKey
        
        var header: (String, String) {
            switch self {
            case .contentType:
                return ("Content-Type", "application/json")
            case .sesacKey:
                return ("SesacKey", APIInfo.apiKey)
            }
        }
        
        static func asHTTPHeaders(_ list: [Headers]) -> HTTPHeaders {
            var headers: HTTPHeaders = [:]
            list.forEach {
                let header = $0.header
                headers.add(name: header.0, value: header.1)
            }
            return headers
        }
    }
}
