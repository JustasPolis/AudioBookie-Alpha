//
//  TabBarController.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-27.
//

import LNPopupController
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPopupBar()
    }

    func setupPopupBar() {
        self.popupBar.barStyle = .prominent
        self.popupInteractionStyle = .drag
        self.popupContentView.popupCloseButtonStyle = .chevron
        self.popupBar.progressView.progressTintColor = .purple
        self.popupBar.progressViewStyle = .top
    }
}
