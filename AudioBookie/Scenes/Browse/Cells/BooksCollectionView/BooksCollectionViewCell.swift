//
//  BooksCollectionViewCell.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import Gradients
import Kingfisher
import Then
import UIKit

final class BooksCollectionViewCell: UICollectionViewCell {

    let coverImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 6.0
        $0.clipsToBounds = true
    }

    let titleLabel = UILabel().then {
        $0.text = "Joe rogan experience ewqweqeqeq"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }

    let authorLabel = UILabel().then {
        $0.text = "By Joe rogan"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.alpha = 0.5
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {

        coverImage.add(to: self)
        titleLabel.add(to: self)
        authorLabel.add(to: self)
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.heightAnchor.constraint(equalToConstant: 165).isActive = true
        coverImage.widthAnchor.constraint(equalToConstant: 165).isActive = true
        coverImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        coverImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        coverImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    func configure(with book: Book) {
        titleLabel.text = book.title
        if let bookAuthor = book.author {
            authorLabel.text = "By \(bookAuthor)"
        } else {
            authorLabel.text = "By Anonymous"
        }
        if let coverURL = book.cover {
            coverImage.kf.setImage(with: URL(string: coverURL))
        } else {
            coverImage.image = #imageLiteral(resourceName: "librivoxCover")
        }
    }
}
