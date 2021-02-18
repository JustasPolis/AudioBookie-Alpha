//
//  Date+Extensions.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-14.
//

import Foundation

extension Date {
    var millisecondsSince1970: Int {
        Int(timeIntervalSince1970 * 1000)
    }
}
