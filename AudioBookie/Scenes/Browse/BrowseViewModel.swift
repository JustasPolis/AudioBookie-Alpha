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

        let items = Observable.zip(newBooks, topBooks, genres) { [sceneCoordinator] newBooks, topBooks, _ -> [BrowseCollectionViewSectionModel] in
            [
                .TopBooksSection(childCollectionView: .HorizontalList(BooksCollectionViewModel(books: topBooks, sceneCoordinator: sceneCoordinator))),
                .NewBooksSection(childCollectionView: .HorizontalList(BooksCollectionViewModel(books: newBooks, sceneCoordinator: sceneCoordinator))),
                .GenresSection(items: [.VerticalListItem(text: "Action"), .VerticalListItem(text: "Horror"), .VerticalListItem(text: "Ancient Texts"), .VerticalListItem(text: "Astronomy"), .VerticalListItem(text: "Art")]),
                .LanguagesSection(items: [.VerticalListItem(text: "English"), .VerticalListItem(text: "Chinese"), .VerticalListItem(text: "Lithuanian"), .VerticalListItem(text: "German")])
            ]
        }
        return Output(items: items)
    }
}
