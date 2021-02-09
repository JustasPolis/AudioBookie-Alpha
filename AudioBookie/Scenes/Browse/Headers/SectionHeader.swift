//
//  SectionHeader.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//
import UIKit

class SectionHeader: UICollectionReusableView {
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.sizeToFit()
        return label
    }()

    var label2: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("See All", for: .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.titleEdgeInsets.bottom = button.safeAreaInsets.top
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(label2)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        label2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SectionHeader1: UICollectionReusableView {
    var label3: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Browse"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.sizeToFit()
        return label
    }()

    var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.sizeToFit()
        return label
    }()

    var label2: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "See All"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(label3)
        addSubview(label2)

        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        label3.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        label2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
