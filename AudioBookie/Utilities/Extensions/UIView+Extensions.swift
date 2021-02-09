//
//  UIView+Extensions.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import UIKit

extension UIView {

    @discardableResult
    public func add(to parent: UIView) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        return self
    }

    @discardableResult
    public func pinToEdges(of view: UIView) -> Self {
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        return self
    }
}
