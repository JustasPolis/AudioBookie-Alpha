//
//  Resources.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-09.
//

import Then
import UIKit

// Temporary

let url = "https://librivox.app/api/getgenre?genre=Action%20%26%20Adventure&limit=40&offset=0&ff=t&timestamp=1611747621203"
let searchURL = "https://librivox.app/api/search?limit=40&offset=0&query=Art%20of%20war&ff=t&timestamp=1611747741551"

enum Resources {}

extension Resources {
    enum Appearance {
        enum Color {
            static let barColor = UIColor(named: "barColor")
            static let viewBackground = UIColor(named: "viewBackground")
            static let purple = UIColor(named: "purple")
        }
    }
}

extension Resources.Appearance {

    enum Icon {}
}
