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
}

struct SearchViewModelOutput {
    let searchResult: Driver<String>
}


protocol SearchViewModelType {
    var input: SearchViewModelInput! { get }
    var output: SearchViewModelOutput! { get }
}

class SearchViewModel: SearchViewModelType {

    private(set) var input: SearchViewModelInput!
    private(set) var output: SearchViewModelOutput!

    private let searchText = PublishSubject<String>()

    init() {
        input = SearchViewModelInput(searchText: searchText.asObserver())
        let searchResult = Driver.just("test")
        output = SearchViewModelOutput(searchResult: searchResult)
    }
}
