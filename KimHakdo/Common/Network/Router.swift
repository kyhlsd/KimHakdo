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
    case deleteComment(classId: String, commentId: String)
    case editComment(classId: String, commentId: String, content: String)
    case searchClass(keyword: String)
    case updateFavorite(classId: String, isFavorite: Bool)
    
    var baseURL: String {
       return APIInfo.baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .postComment, .updateFavorite:
            return .post
        case .lookupClass, .fetchImage, .getDetail, .lookupComment, .searchClass:
            return .get
        case .deleteComment:
            return .delete
        case .editComment:
            return .put
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
        case .lookupComment(let id), .postComment(let id, _):
            return "/\(version)/courses/\(id)/comments"
        case .deleteComment(let classId, let commentId), .editComment(let classId, let commentId, _):
            return "/\(version)/courses/\(classId)/comments/\(commentId)"
        case .searchClass:
            return "/\(version)/courses/search"
        case .updateFavorite(let classId, _):
            return "/\(version)/courses/\(classId)/like"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
        case .postComment(_, let content), .editComment(_, _, let content):
            return [
                "content": content
            ]
        case .updateFavorite(_, let isFavorite):
            return [
                "like_status": isFavorite
            ]
        case .lookupClass, .fetchImage, .getDetail, .lookupComment, .deleteComment, .searchClass:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .searchClass(let keyword):
            return Query.asURLQueryItems([
                .searchWord(keyword: keyword)
            ])
        default:
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
        case .lookupClass, .fetchImage, .getDetail, .lookupComment, .deleteComment, .searchClass, .updateFavorite:
            return Headers.asHTTPHeaders([
                .authorization,
                .sesacKey
            ])
        case .postComment, .editComment:
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
    
    enum Query {
        case searchWord(keyword: String)
        
        var queryItem: URLQueryItem {
            switch self {
            case .searchWord(let keyword):
                return URLQueryItem(name: "title", value: keyword)
            }
        }
        
        static func asURLQueryItems(_ list: [Query]) -> [URLQueryItem] {
            return list.map { $0.queryItem }
        }
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
