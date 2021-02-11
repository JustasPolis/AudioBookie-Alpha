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
    let textDidChange: Driver<Void>
    let cancelButtonClicked: Driver<Void>
    let reachedBottom: Driver<Void>
}

struct SearchViewModelOutput {
    let books: Driver<[TestBook]>
    let loading: Driver<Bool>
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

        let merge = Driver.merge(input.cancelButtonClicked, input.textDidChange)

        let activityIndicator = ActivityIndicator()

        let resetBooks = merge
            .flatMap { _ -> Driver<[TestBook]> in
                .just([])
            }

        let loading = activityIndicator.asDriver()

        let isEmptySubject = BehaviorSubject(value: false)

        let obs = isEmptySubject.asDriverOnErrorJustComplete()

        let getBooks = input
            .textDidChange
            .do(onNext: { _ in
                isEmptySubject.onNext(false)
            })
            .withLatestFrom(input.searchText)
            .flatMapLatest { searchText -> Driver<[TestBook]> in
                input.reachedBottom
                    .startWith(())
                    .skip(if: loading)
                    .skip(if: obs)
                    .scan(0) { (pageNumber, _) -> Int in
                        pageNumber + 1
                    }
                    .map { pageNumber in
                        (searchText, pageNumber)
                    }.flatMap { _, pageNumber -> Driver<[TestBook]> in
                        data(pageNumber: pageNumber)
                            .do(onNext: { book in
                                if book.isEmpty {
                                    isEmptySubject.onNext(true)
                                }
                            })
                            .delay(.seconds(2), scheduler: MainScheduler.instance)
                            .trackActivity(activityIndicator)
                            .asDriverOnErrorJustComplete()
                    }.scan([]) { (acc, book) -> [TestBook] in
                        acc + book
                    }
            }

        let books = Driver.merge(getBooks, resetBooks)

        return Output(books: books, loading: loading)
    }
}

struct TestBook {
    let title: String
    let author: String
}
