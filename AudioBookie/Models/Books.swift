//
//  Books.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import Foundation

struct Books: Decodable {
    let books: [Book]

    enum RootKeys: String, CodingKey {
        case bookList = "booklist"
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        let bookList = try rootContainer.decode([String].self, forKey: .bookList)
        var arr = [Book]()
        try bookList.forEach { book in
            arr.append(try JSONDecoder().decode(Book.self, from: Data(book.utf8)))
        }
        books = arr
    }
}
