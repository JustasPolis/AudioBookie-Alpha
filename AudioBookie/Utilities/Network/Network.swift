//
//  Network.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import Alamofire
import RxSwift

enum NetworkError: Error {
    case connection
    case other(message: String)
}

protocol NetworkType {
    func request<T: Decodable>(_ urlConvertible: URLRequestConvertible) -> Observable<T>
}

class Network: NetworkType {

    private let session: Session

    init() {
        self.session = Session(configuration: URLSessionConfiguration.af.default)
    }

    func request<T: Decodable>(_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        Observable<T>.create { [session] observer in
            let request = session.request(urlConvertible)
                .validate()
                .responseDecodable(of: T.self) { (response: DataResponse<T, AFError>) in
                    guard response.data != nil else {
                        return observer.onError(NetworkError.connection)
                    }
                    switch response.result {
                        case .success(let value):
                            observer.onNext(value.self)
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(NetworkError.other(message: error.localizedDescription))
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
