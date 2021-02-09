//
//  BookDetailsFooter.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-26.
//

import Then
import UIKit

class BookDetailsFooter: UICollectionReusableView {

    var loading: Bool! {
        didSet {
            configure(loading: loading)
        }
    }

    let activityIndicator = UIActivityIndicatorView(style: .gray).then {
        $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        $0.color = .gray
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        activityIndicator.add(to: self)
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
