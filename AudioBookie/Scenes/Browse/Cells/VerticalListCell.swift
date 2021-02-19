//
//  VerticalListCell.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-19.
//

import Then
import UIKit

class VerticalListCell: UICollectionViewCell {

    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17, weight: .semibold)
    }

    let separator = UIView().then {
        if #available(iOS 13.0, *) {
            $0.backgroundColor = .label
        } else {
            $0.backgroundColor = .black
        }
        $0.alpha = 0.225
    }

    let rightIconImageView = UIImageView().then {
        $0.image = #imageLiteral(resourceName: "right-arrow").withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            $0.tintColor = .label
            $0.alpha = 0.4
        } else {
            $0.tintColor = .black
        }
    }

    lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, rightIconImageView]).then {
        $0.axis = .horizontal
        $0.alignment = .firstBaseline
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.add(to: self)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        separator.add(to: self)
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        rightIconImageView.translatesAutoresizingMaskIntoConstraints = false
        rightIconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        rightIconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ButtonWithImage: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: bounds.width - 5, bottom: 0, right: 0)
        }
    }
}
