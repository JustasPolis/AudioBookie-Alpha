//
import Then
//  SectionHeader.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//
import UIKit

class SectionHeader: UICollectionReusableView {
    let sectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    let seeAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("See All", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()

    lazy var stackView = UIStackView(arrangedSubviews: [sectionLabel, seeAllButton]).then {
        $0.axis = .horizontal
        $0.distribution = .equalCentering
        $0.alignment = .firstBaseline
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

