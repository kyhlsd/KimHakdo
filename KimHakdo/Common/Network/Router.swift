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
    case lookupClass
    case fetchImage(url: String)
    case getDetail(id: String)
    case lookupComment(id: String)
    case postComment(id: String, content: String)
    
    var baseURL: String {
       return APIInfo.baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .postComment:
            return .post
        case .lookupClass, .fetchImage, .getDetail, .lookupComment:
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
        case .lookupClass:
            return "/\(version)/courses"
        case .fetchImage(let url):
            return "/\(version)\(url)"
        case .getDetail(let id):
            return "/\(version)/courses/\(id)"
        case .lookupComment(let id):
            return "/\(version)/courses/\(id)/comments"
        case .postComment(let id, _):
            return "/\(version)/courses/\(id)/comments"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
        case .postComment(_, let content):
            return [
                "content": content
            ]
        case .lookupClass, .fetchImage, .getDetail, .lookupComment:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .login:
            return Headers.asHTTPHeaders([
                .contentType,
                .sesacKey
            ])
        case .lookupClass, .fetchImage, .getDetail, .lookupComment:
            return Headers.asHTTPHeaders([
                .authorization,
                .sesacKey
            ])
        case .postComment:
            return Headers.asHTTPHeaders([
                .authorization,
                .contentType,
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
