//
//  AudioPlayerViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-27.
//

import RxCocoa
import RxSwift

protocol AudioPlayerViewModelType {

    typealias Input = AudioPlayerViewModelInput
    typealias Output = AudioPlayerViewModelOutput

    func transform(input: Input) -> Output
}

struct AudioPlayerViewModelInput {
    let itemDidPlayToEndTime: Driver<Void>
}

struct AudioPlayerViewModelOutput {
    let streamURL: Driver<URL?>
    let endOfChapters: Driver<Bool>
    let chapterTitle: Driver<String>
    let bookTitle: Driver<String>
    let cover: Driver<String?>
}

class AudioPlayerViewModel: AudioPlayerViewModelType {

    private let startIndex: Int
    private let book: Driver<Book>

    init(startIndex: Int, book: Book) {
        self.startIndex = startIndex
        self.book = .just(book)
    }

    func transform(input: Input) -> Output {

        let bookTitle = book.map(\.title)
        let cover = book.map(\.cover)
        let chapters = book.compactMap(\.chapters)

        let currentIndex = input.itemDidPlayToEndTime
            .scan(startIndex) { index, _ -> Int in
                index + 1
            }.startWith(startIndex)

        let currentChapter = currentIndex
            .withLatestFrom(chapters) { ($0, $1) }
            .filter { index, chapters in
                index < chapters.count
            }
            .map { index, chapters in
                chapters[index]
            }

        let streamURL = currentChapter
            .map { URL(string: $0.streamURL) }

        let chapterTitle = currentChapter
            .map(\.title)

        let lastIndex = currentIndex
            .withLatestFrom(chapters) { ($0, $1) }
            .filter { index, chapters in
                index == chapters.count
            }.mapTo(true)

        let endOfChapters = input.itemDidPlayToEndTime
            .withLatestFrom(lastIndex)

        return Output(streamURL: streamURL,
                      endOfChapters: endOfChapters,
                      chapterTitle: chapterTitle,
                      bookTitle: bookTitle,
                      cover: cover)
    }
}
