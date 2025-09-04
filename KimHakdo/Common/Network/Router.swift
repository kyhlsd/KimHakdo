//
//  Router.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/3/25.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible, URLConvertible {
    case login(email: String, password: String)
    case lookupCourses
    case fetchImage(url: String)
    
    var baseURL: String {
       return APIInfo.baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .lookupCourses, .fetchImage:
            return .get
        }
    }
        
    var version: String {
        return "v1"
    }
    
    var paths: String {
        switch self {
        case .login:
            return "/\(version)/users/login"
        case .lookupCourses:
            return "/\(version)/courses"
        case .fetchImage(let url):
            return "/\(version)\(url)"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
        case .lookupCourses, .fetchImage:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .login, .lookupCourses, .fetchImage:
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
        case .lookupCourses, .fetchImage:
            return Headers.asHTTPHeaders([
                .authorization,
                .sesacKey
            ])
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try asURL()
        var urlRequest = try URLRequest(url: url, method: method, headers: headers)
        urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest
    }
    
    func asURL() throws -> URL {
        var url = try baseURL.asURL()
        url = url.appendingPathComponent(paths)
        url = url.appending(queryItems: queryItems)
        return url
    }
    
    enum Headers {
        case contentType
        case sesacKey
        case authorization
        
        var header: (String, String) {
            switch self {
            case .contentType:
                return ("Content-Type", "application/json")
            case .sesacKey:
                return ("SesacKey", APIInfo.apiKey)
            case .authorization:
                return ("Authorization", UserDefaultHelper.token ?? "nilToken")
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
