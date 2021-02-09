//
//  LanguagesCollectionViewModel.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxCocoa
import RxSwift

class LanguagesCollectionViewModel {

    let languages: Observable<[String]>

    init(languages: [String]) {
        self.languages = .just(languages)
    }
}
