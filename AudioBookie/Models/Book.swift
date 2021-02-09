//
//  Book.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import Foundation

struct Book: Decodable {
    let title: String
    let author: String
    let cover: String?
    let key: Int
    let description: String?
    let chapters: [Chapter]?

    private enum CodingKeys: String, CodingKey {
        case title = "title_key"
        case author = "author_key"
        case cover = "cover_key"
        case key = "lvid_key"
        case chapters = "chlist"
        case description = "desc"
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        title = try rootContainer.decode(String.self, forKey: .title)
        author = try rootContainer.decode(String.self, forKey: .author)
        cover = try rootContainer.decodeIfPresent(String.self, forKey: .cover)
        key = try rootContainer.decode(Int.self, forKey: .key)
        description = try rootContainer.decodeIfPresent(String.self, forKey: .description)
        let chapterList = try rootContainer.decodeIfPresent([String].self, forKey: .chapters)
        var arr = [Chapter]()
        try chapterList?.forEach { chapter in
            arr.append(try JSONDecoder().decode(Chapter.self, from: Data(chapter.utf8)))
        }
        chapters = arr
    }
}
