//
//  SearchViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-09.
//

import RxCocoa
import RxSwift

struct SearchViewModelInput {
    let searchText: AnyObserver<String>
    let textDidEndEditing: AnyObserver<Void>
    let reachedBottom: AnyObserver<Void>
}

struct SearchViewModelOutput {
    let books: Driver<[TestBook]>
    let searchMoreBooks: Driver<(String, Int)>
}

protocol SearchViewModelType {
    var input: SearchViewModelInput! { get }
    var output: SearchViewModelOutput! { get }
}

class SearchViewModel: SearchViewModelType {

    private let networkService: NetworkServiceType
    private(set) var input: SearchViewModelInput!
    private(set) var output: SearchViewModelOutput!

    private let searchText = PublishSubject<String>()
    private let textDidEndEditing = PublishSubject<Void>()
    private let reachedBottom = PublishSubject<Void>()

    init(networkService: NetworkServiceType) {
        self.networkService = networkService

        input = SearchViewModelInput(searchText: searchText.asObserver(),
                                     textDidEndEditing: textDidEndEditing.asObserver(),
                                     reachedBottom: reachedBottom.asObserver())

        let books = Driver.merge(searchBooks(), resetBooks())

        output = SearchViewModelOutput(books: books, searchMoreBooks: searchMoreBooks())
    }

    private func resetBooks() -> Driver<[TestBook]> {
        textDidEndEditing.asDriverOnErrorJustComplete().flatMap { _ -> Driver<[TestBook]> in
            .just([])
        }
    }

    private func searchBooks() -> Driver<[TestBook]> {
        let books = [TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2")]

        return searchText
            .flatMapLatest { _ -> Observable<[TestBook]> in
                .just(books)
            }.asDriverOnErrorJustComplete()
    }

    private func getBooks(pageNumber: Int) -> Driver<[TestBook]> {
        let books = [TestBook(title: "1", author: "Albert Einstein"), TestBook(title: "2", author: "Albert Einstein"), TestBook(title: "3", author: "Albert Einstein"), TestBook(title: "4", author: "Albert Einstein"), TestBook(title: "5", author: "Albert Einstein"), TestBook(title: "6", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2")]
        let books2 = [TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "Art of War", author: "Albert Einstein"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2"), TestBook(title: "My title", author: "my Author"), TestBook(title: "my title 2", author: "my Author2")]
        if pageNumber == 1 {
            return .just(books)
        } else if pageNumber == 2 {
            return .just(books2)
        } else {
            return .just([])
        }
    }

    private func searchMoreBooks() -> Driver<(String, Int)> {

        let books = searchText
            .flatMapLatest { searchText -> Observable<(String, Int)> in
                self.reachedBottom.asObservable()
                    .startWith(())
                    .scan(0) { (pageNumber, _) -> Int in
                        pageNumber + 1
                    }
                    .map { pageNumber in
                        (searchText, pageNumber)
                    }
            }.asDriverOnErrorJustComplete()

        return books
    }
}

struct TestBook {
    let title: String
    let author: String
}

/*

 private func searchMoreBooks() -> Driver<[TestBook]> {

 let books = searchText
 .flatMapLatest { searchText -> Observable<(String, Int)> in
 self.reachedBottom.asObservable()
 .startWith(())
 .scan(0) { (pageNumber, _) -> Int in
 pageNumber + 1
 }
 .map { pageNumber in
 (searchText, pageNumber)
 }
 }.asDriverOnErrorJustComplete()
 .flatMapLatest { _, pageNumber -> Driver<[TestBook]> in
 self.getBooks(pageNumber: pageNumber)
 .delay(.seconds(2))
 .asObservable()
 .take(until: { book -> Bool in
 book.isEmpty
 })
 .asDriverOnErrorJustComplete()
 }

 let combined = books.scan([]) { old, new in
 old + new
 }
 return combined
 }
 }
 */
