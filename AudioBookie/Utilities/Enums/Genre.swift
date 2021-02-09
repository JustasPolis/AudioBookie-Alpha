//
//  Genres.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-25.
//

import Foundation

enum Genre: CaseIterable {
    case horror
    case scienceFiction
}

extension Genre {
    var name: String {
        switch self {
            case .horror:
                return "horror"
            case .scienceFiction:
                return "science fiction"
        }
    }
}
