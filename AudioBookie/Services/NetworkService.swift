//
//  NetworkService.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import Alamofire
import RxSwift

protocol NetworkServiceType {
    func getNewBooks(limit: Int, offset: Int) -> Observable<[Book]>
    func getTopBooks(limit: Int, offset: Int) -> Observable<[Book]>
    func getBookDetails(id: Int) -> Observable<Book>
}

class NetworkService: NetworkServiceType {

    private let network: NetworkType

    init(network: NetworkType) {
        self.network = network
    }

    func getNewBooks(limit: Int, offset: Int) -> Observable<[Book]> {
        let result: Observable<Books> = network.request(Routes.newBooks(limit: limit, offset: offset))
        return result.map { result in
            result.books
        }
    }

    func getTopBooks(limit: Int, offset: Int) -> Observable<[Book]> {
        let result: Observable<Books> = network.request(Routes.topBooks(limit: limit, offset: offset))
        return result.map { result in
            result.books
        }
    }

    func getBookDetails(id: Int) -> Observable<Book> {
        network.request(Routes.book(id: id))
    }
}
