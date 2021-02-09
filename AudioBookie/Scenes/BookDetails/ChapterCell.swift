//
//  BookDetailsCell.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-26.
//

import Then
import UIKit

class ChapterCell: UICollectionViewCell {

    let title = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        title.add(to: self)
        title.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with chapter: Chapter) {
        title.text = chapter.title
    }
}
