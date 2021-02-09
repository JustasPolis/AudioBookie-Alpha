//
//  BrowseViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxCocoa
import RxSwift

protocol BrowseViewModelType {

    typealias Input = BrowseViewModelInput
    typealias Output = BrowseViewModelOutput

    func transform(input: Input) -> Output
}

struct BrowseViewModelInput {}

struct BrowseViewModelOutput {
    let items: Observable<[BrowseCollectionViewSectionModel]>
}

class BrowseViewModel: BrowseViewModelType {

    private let networkService: NetworkServiceType
    private let sceneCoordinator: SceneCoordinatorType

    init(networkService: NetworkServiceType, sceneCoordinator: SceneCoordinatorType) {
        self.networkService = networkService
        self.sceneCoordinator = sceneCoordinator
    }

    func transform(input: Input) -> Output {

        struct Test {
            let name: String
        }
        let genres = Observable.just(Genre.allCases)
        let newBooks = networkService.getNewBooks(limit: 15, offset: 0)
        let topBooks = networkService.getTopBooks(limit: 15, offset: 0)

        let items = Observable.zip(newBooks, topBooks, genres) { [sceneCoordinator] newBooks, topBooks, genres -> [BrowseCollectionViewSectionModel] in
            [
                .NewBooksSection(childCollectionView: .BooksCollectionView(BooksCollectionViewModel(books: newBooks, sceneCoordinator: sceneCoordinator))),
                .GenresSection(childCollectionView: .GenresCollectionView(GenresCollectionViewModel(genres: genres, sceneCoordinator: sceneCoordinator))),
                .LanguagesSection(childCollectionView: .LanguagesCollectionView(LanguagesCollectionViewModel(languages: ["Item one", "Item two"]))),
                .TopBooksSection(childCollectionView: .BooksCollectionView(BooksCollectionViewModel(books: topBooks, sceneCoordinator: sceneCoordinator))),
            ]
        }
        return Output(items: items)
    }
}
