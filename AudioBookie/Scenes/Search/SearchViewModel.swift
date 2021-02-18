//
//  SearchViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-09.
//

import RxCocoa
import RxSwift

struct SearchViewModelInput {
    let searchText: Driver<String>
    let textIsEmpty: Driver<Void>
    let textNotEmpty: Driver<Bool>
    let textDidChange: Driver<Void>
    let reachedBottom: Driver<Bool>
    let searchCancelButtonTapped: Driver<Void>
}

struct SearchViewModelOutput {
    let books: Driver<[TestBook]>
    let loading: Driver<Bool>
    let noResults: Driver<Bool>
}

protocol SearchViewModelType {
    typealias Input = SearchViewModelInput
    typealias Output = SearchViewModelOutput

    func transform(input: Input) -> Output
}

class SearchViewModel: SearchViewModelType {

    private let networkService: NetworkServiceType

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }

    func transform(input: Input) -> Output {

        func data(searchText: String, pageNumber: Int) -> Observable<[TestBook]> {
            let books = [TestBook(title: "1", author: "Albert Einstein"), TestBook(title: "2", author: "Albert Einstein"), TestBook(title: "3", author: "Albert Einstein"), TestBook(title: "4", author: "Albert Einstein"), TestBook(title: "5", author: "Albert Einstein"), TestBook(title: "6", author: "my Author2"), TestBook(title: "7", author: "my Author"), TestBook(title: "8", author: "my Author2"), TestBook(title: "9", author: "my Author"), TestBook(title: "10", author: "my Author2"), TestBook(title: "11", author: "my Author"), TestBook(title: "12", author: "my Author2")]
            let books2 = [TestBook(title: "13", author: "Albert Einstein"), TestBook(title: "14", author: "Albert Einstein"), TestBook(title: "15", author: "Albert Einstein"), TestBook(title: "16", author: "Albert Einstein"), TestBook(title: "17", author: "Albert Einstein"), TestBook(title: "18", author: "my Author2"), TestBook(title: "19", author: "my Author"), TestBook(title: "20", author: "my Author2"), TestBook(title: "21", author: "my Author"), TestBook(title: "22", author: "my Author2"), TestBook(title: "23", author: "my Author"), TestBook(title: "24", author: "my Author2")]
            if pageNumber == 1 {
                return .just(books)
            } else if pageNumber == 2 {
                return .just(books2)
            } else {
                return .just([])
            }
        }

        let activityIndicator = ActivityIndicator()

        let loading = activityIndicator.asDriver()

        let isEmpty = input.textIsEmpty.mapTo(true)
        let merge = Driver.merge(isEmpty, input.textNotEmpty)
        let loadingSubject = BehaviorSubject(value: false)
        let loadingObs = loadingSubject.asDriverOnErrorJustComplete()

        let emptyResponseSubject = BehaviorSubject(value: false)

        let emptyResponseObs = emptyResponseSubject.asDriverOnErrorJustComplete()

        let getBooks = input
            .searchText
            .do(onNext: { _ in
                emptyResponseSubject.onNext(false)
                loadingSubject.onNext(false)
            })
            .flatMapLatest { searchText -> Driver<[TestBook]> in
                input.reachedBottom
                    .filter { $0 }
                    .skip(if: loadingObs)
                    .skip(if: emptyResponseObs)
                    .do(onNext: { _ in
                        loadingSubject.onNext(true)
                    })
                    .scan(0) { (pageNumber, _) -> Int in
                        pageNumber + 1
                    }
                    .map { pageNumber in
                        (searchText, pageNumber)
                    }.flatMap { searchText, pageNumber -> Driver<[TestBook]> in
                        data(searchText: searchText, pageNumber: pageNumber)
                            .delay(.seconds(1), scheduler: MainScheduler.instance)
                            .asDriver(onErrorJustReturn: [])
                            .do(onNext: { books in
                                loadingSubject.onNext(false)
                                if books.isEmpty {
                                    emptyResponseSubject.onNext(true)
                                }
                            })
                            .skip(if: merge)
                    }.scan([]) { (acc, books) -> [TestBook] in
                        acc + books
                    }
            }

        let resetBooks = Driver.merge(input.textIsEmpty, input.searchCancelButtonTapped)
            .flatMap { _ -> Driver<[TestBook]> in
                .just([])
            }

        let noResults = getBooks.asObservable().take(1).map { books in
            books.isEmpty
        }.asDriverOnErrorJustComplete()

        let books = Driver.merge(resetBooks, getBooks)

        return Output(books: books, loading: loading, noResults: noResults)
    }
}

struct TestBook {
    let title: String
    let author: String
}
