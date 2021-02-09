//
//  Double+Extensions.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-28.
//

import Foundation

extension Double {

    func formatToTimeString() -> String {
        let minutes = Int(self) / 60
        let remainder = Int(self) % 60
        let timeString = String(format: "%02d:%02d", minutes, remainder)
        return timeString
    }
}
