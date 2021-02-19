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
        $0.layer.cornerRadius = 4.0
        $0.clipsToBounds = true
    }

    let titleLabel = UILabel()
    let authorLabel = UILabel()

    let myView = UIView().then {
        $0.layer.cornerRadius = 8.0
        $0.clipsToBounds = true
    }

    lazy var stackView = UIStackView(arrangedSubviews: [coverImage]).then {
        $0.axis = .vertical
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
        stackView.do {
            $0.add(to: self)
            $0.pinToEdges(of: self)
        }
    }

    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        if let coverURL = book.cover {
            coverImage.kf.setImage(with: URL(string: coverURL))
        } else {
            coverImage.image = #imageLiteral(resourceName: "librivoxCover")
        }
    }
}
