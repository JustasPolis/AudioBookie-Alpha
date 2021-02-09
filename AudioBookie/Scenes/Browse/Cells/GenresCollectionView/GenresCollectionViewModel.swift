//
//  GenresCollectionViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxCocoa
import RxSwift

protocol GenresCollectionViewModelType {

    var genres: Driver<[Genre]> { get }

    typealias Input = GenresCollectionViewModelInput
    typealias Output = GenresCollectionViewModelOutput

    func transform(input: Input) -> Output
}

struct GenresCollectionViewModelInput {
    let genreSelected: Driver<Genre>
}

struct GenresCollectionViewModelOutput {
    let navigateToBooksByGenreScene: Driver<Void>
}

class GenresCollectionViewModel: GenresCollectionViewModelType {

    let genres: Driver<[Genre]>
    private let sceneCoordinator: SceneCoordinatorType

    init(genres: [Genre], sceneCoordinator: SceneCoordinatorType) {
        self.sceneCoordinator = sceneCoordinator
        self.genres = .just(genres)
    }

    func transform(input: Input) -> Output {

        let navigateToBooksByGenreScene = input.genreSelected
            .do(onNext: { [sceneCoordinator] genre in
                sceneCoordinator.transition(to: Scene.bookListByGenre(genre))
            }).mapToVoid()

        return Output(navigateToBooksByGenreScene: navigateToBooksByGenreScene)
    }
}
