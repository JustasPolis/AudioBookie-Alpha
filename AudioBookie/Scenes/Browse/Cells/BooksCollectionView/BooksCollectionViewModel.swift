//
//  NewBooksCollectionViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxCocoa
import RxSwift

protocol BooksCollectionViewModelType {

    var books: Driver<[Book]> { get }

    typealias Input = BooksCollectionViewModelInput
    typealias Output = BooksCollectionViewModelOutput

    func transform(input: Input) -> Output
}

struct BooksCollectionViewModelInput {
    let bookSelected: Driver<Book>
}

struct BooksCollectionViewModelOutput {
    let navigateToBookDetails: Driver<Void>
}

class BooksCollectionViewModel: BooksCollectionViewModelType {

    let books: Driver<[Book]>
    private let sceneCoordinator: SceneCoordinatorType

    init(books: [Book], sceneCoordinator: SceneCoordinatorType) {
        self.sceneCoordinator = sceneCoordinator
        self.books = .just(books)
    }

    func transform(input: Input) -> Output {

        let navigateToBookDetails = input.bookSelected
            .do(onNext: { [sceneCoordinator] book in
                sceneCoordinator.transition(to: Scene.bookDetails(book))
            }).mapToVoid()

        
        return Output(navigateToBookDetails: navigateToBookDetails)
    }
}
