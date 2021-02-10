//
//  Routes.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import Alamofire

enum Routes {
    case newBooks(limit: Int, offset: Int)
    case topBooks(limit: Int, offset: Int)
    case book(id: Int)
    case booksByGenre(genre: Genre)
    case booksByLanguage(language: Language)
    case search(query: String, limit: Int, offset: Int)

    var baseURL: URL {
        URL(string: "https://librivox.app/api/")!
    }

    var path: String {
        switch self {
            case .newBooks:
                return "newbooks"
            case .topBooks:
                return "getrecs"
            case .book:
                return "getbookdetails"
            case .booksByGenre:
                return "genre"
            case .booksByLanguage:
                return "language"
            case .search:
                return "search"
        }
    }

    var method: HTTPMethod {
        switch self {
            case .newBooks,
                 .topBooks,
                 .book,
                 .booksByGenre,
                 .booksByLanguage,
                 .search:
                return .get
        }
    }

    var parameters: [String: String] {
        switch self {
            case .newBooks(let limit, let offset):
                return ["limit": String(limit), "offset": String(offset), "languages": "English", "timestamp": String(Date().millisecondsSince1970)]
            case .topBooks(let limit, let offset):
                return ["limit": String(limit), "offset": String(offset), "languages": "English", "timestamp": String(Date().millisecondsSince1970), "user": "15800617"]
            case .book(let id):
                return ["book": String(id), "languages": "English", "timestamp": String(Date().millisecondsSince1970)]
            case .booksByGenre(let genre):
                return ["genre": genre.name]
            case .booksByLanguage(let language):
                return ["language": language.name]
            case .search(let query, let limit, let offset):
                return ["limit": String(limit), "offset": String(offset), "query": query, "timestamp": String(Date().millisecondsSince1970)]
        }
    }

    var headers: [String: String] {
        switch self {
            case .topBooks, .booksByGenre, .booksByLanguage:
                return ["X-USERTOKEN": "Jb58qisahprM2POMSLAToJxFVKc3WiPVzYbx6zeqR9MRJ28R9aIpmMI2QJ99Uodq"]
            case .newBooks, .book, .search:
                return [:]
        }
    }
}

extension Routes: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {

        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)

        request.method = method

        request.allHTTPHeaderFields = headers

        request = try URLEncodedFormParameterEncoder(destination: .methodDependent)
            .encode(parameters, into: request)

        return request
    }
}
