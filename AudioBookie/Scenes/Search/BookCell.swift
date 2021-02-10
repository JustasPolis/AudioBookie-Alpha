//
//  BookCell.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-10.
//

import Then
import UIKit

class BookCell: UICollectionViewCell {

    let bookCoverImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.image = #imageLiteral(resourceName: "masters")
        $0.layer.cornerRadius = 2
    }

    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
        $0.text = "Art of War"
    }

    let subtitleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 15)
        $0.text = "Joe Macgneum"
        $0.alpha = 0.4
    }

    lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel]).then {
        $0.axis = .vertical
        $0.spacing = 6
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {

        bookCoverImageView.do {
            $0.add(to: self)
            $0.topAnchor.constraint(equalTo: topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            $0.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        }

        stackView.do {
            $0.add(to: self)
            $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: bookCoverImageView.trailingAnchor, constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
    }
}
