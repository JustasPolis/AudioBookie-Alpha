//
//  Languages.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-25.
//

import Foundation

enum Language: CaseIterable {
    case english
    case russian
    case chinese
}

extension Language {
    var name: String {
        switch self {
            case .english:
                return "English"
            case .russian:
                return "Russian"
            case .chinese:
                return "Chinese"
        }
    }
}
