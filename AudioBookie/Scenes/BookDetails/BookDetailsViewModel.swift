//
//  BookDetailsViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-25.
//

import RxCocoa
import RxSwift

protocol BookDetailsViewModelType {

    typealias Input = BookDetailsViewModelInput
    typealias Output = BookDetailsViewModelOutput

    func transform(input: Input) -> Output
}

struct BookDetailsViewModelInput {
    let book: Driver<Book>
    let chapterSelected: Driver<IndexPath>
}

struct BookDetailsViewModelOutput {
    let chapters: Driver<[Chapter]>
    let loading: Driver<Bool>
    let presentAudioPlayerScene: Driver<Void>
}

class BookDetailsViewModel: BookDetailsViewModelType {

    private let sceneCoordinator: SceneCoordinatorType
    private let networkService: NetworkServiceType

    init(sceneCoordinator: SceneCoordinatorType, networkService: NetworkServiceType) {
        self.sceneCoordinator = sceneCoordinator
        self.networkService = networkService
    }

    func transform(input: Input) -> Output {

        let activityIndicator = ActivityIndicator()

        let getBookDetails = input.book.flatMap { [networkService] book in
            networkService.getBookDetails(id: book.key)
                .trackActivity(activityIndicator)
                .asDriverOnErrorJustComplete()
        }

        let chapters = getBookDetails.compactMap { book in
            book.chapters
        }

        let presentAudioPlayerScene = input.chapterSelected
            .withLatestFrom(getBookDetails) { ($0, $1) }
            .do(onNext: { [sceneCoordinator] indexPath, book in
                let index = indexPath.row
                return sceneCoordinator.transition(to: Scene.audioPlayer(index: index, book: book))
            }).mapToVoid()

        let loading = activityIndicator.asDriver()

        return Output(chapters: chapters, loading: loading, presentAudioPlayerScene: presentAudioPlayerScene)
    }
}
