//
//  TestViewController.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-19.
//

import Foundation
import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Resources.Appearance.Color.viewBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        let v = UIView()
        v.backgroundColor = Resources.Appearance.Color.viewBackground

        v.add(to: self.view)
        v.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        v.heightAnchor.constraint(equalToConstant: 96).isActive = true

        let label = UILabel()
        label.text = "Search"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.sizeToFit()

        label.add(to: v)

        label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16).isActive = true
        label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -7.5).isActive = true
    }
}
