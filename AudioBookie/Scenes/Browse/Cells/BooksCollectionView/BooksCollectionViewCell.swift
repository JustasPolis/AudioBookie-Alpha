//
//  BooksCollectionViewCell.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import Gradients
import SDWebImage
import Then
import UIKit

final class BooksCollectionViewCell: UICollectionViewCell {

    let coverImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    let titleLabel = UILabel()
    let authorLabel = UILabel()

    let myView = UIView().then {
        $0.layer.cornerRadius = 8.0
        $0.clipsToBounds = true
    }

    lazy var stackView = UIStackView(arrangedSubviews: [myView]).then {
        $0.axis = .vertical
    }

    override func layoutSubviews() {
        coverImage.add(to: myView)
        coverImage.pinToEdges(of: myView)
        myView.setGradientBackground(.confidentCloud)
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
        coverImage.sd_setImage(with: URL(string: book.cover ?? ""), placeholderImage: UIImage())
    }
}

extension UIView {
    func setGradientBackground(_ type: Gradients) {
        let gradientLayer = type.layer
        gradientLayer.frame = bounds

        layer.insertSublayer(gradientLayer, at: 0)
    }
}
