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
    let reachedBottom: Driver<Void>
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

        func data(pageNumber: Int) -> Observable<[TestBook]> {
            print("fetching")
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

        // let isEmptySubject = BehaviorSubject(value: false)

        // take(1) for error kai nebent errorina pirmas resultatas

        // take(1) get books paziuret ar tuscias, jei tuscia tai renderinti no results view

        // let obs = isEmptySubject.asDriverOnErrorJustComplete()

        let isEmpty = input.textIsEmpty.mapTo(true)

        let merge = Driver.merge(isEmpty, input.textNotEmpty)

        let getBooks = input
            .searchText
            .flatMapLatest { searchText -> Driver<[TestBook]> in
                input.reachedBottom
                    .startWith(())
                    .scan(0) { (pageNumber, _) -> Int in
                        pageNumber + 1
                    }
                    .map { pageNumber in
                        (searchText, pageNumber)
                    }.flatMap { _, pageNumber -> Driver<[TestBook]> in
                        data(pageNumber: pageNumber)
                            .delay(.seconds(3), scheduler: MainScheduler.instance)
                            .trackActivity(activityIndicator)
                            .asDriverOnErrorJustComplete()
                            .skip(if: merge)
                    }.scan([]) { (acc, books) -> [TestBook] in
                        acc + books
                    }
            }

        let test = input
            .searchText
            .flatMapLatest { searchText -> Driver<[TestBook]> in
                input.reachedBottom
                    .startWith(())
                    .scan(0) { (pageNumber, _) -> Int in
                        pageNumber + 1
                    }
                    .map { pageNumber in
                        (searchText, pageNumber)
                    }.flatMap { _, pageNumber -> Driver<[TestBook]> in
                        data(pageNumber: pageNumber)
                            .delay(.seconds(6), scheduler: MainScheduler.instance)
                            .trackActivity(activityIndicator)
                            .asDriverOnErrorJustComplete()
                            .skip(if: merge)
                    }.scan([]) { (acc, books) -> [TestBook] in
                        acc + books
                    }
            }

        let test1 = input
            .searchText
            .flatMapLatest { searchText -> Driver<(String, [TestBook])> in
                data(pageNumber: 1)
                    .delay(.seconds(6), scheduler: MainScheduler.instance)
                    .asDriverOnErrorJustComplete()
                    .skip(if: merge)
                    .map { books in
                        (searchText, books)
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
