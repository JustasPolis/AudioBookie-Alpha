//
//  Chapter.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-25.
//

import Foundation

struct Chapter: Decodable {
    let duration: String?
    let author: String?
    let title: String
    let streamURL: String
    let altStreamURL: String?

    private enum CodingKeys: String, CodingKey {
        case duration
        case author
        case title
        case streamURL = "link"
        case altStreamURL = "alt"
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        duration = try rootContainer.decodeIfPresent(String.self, forKey: .duration)
        author = try rootContainer.decodeIfPresent(String.self, forKey: .author)
        title = try rootContainer.decode(String.self, forKey: .title)
        streamURL = try rootContainer.decode(String.self, forKey: .streamURL)
        altStreamURL = try rootContainer.decodeIfPresent(String.self, forKey: .altStreamURL)
    }
}

struct Test: Decodable {
    let name: String
}
