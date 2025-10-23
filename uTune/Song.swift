//
//  Song.swift
//  uTune
//
//  Created by Angel Bitsov on 10/23/25.
//

import Foundation

struct Song: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let duration: TimeInterval
}
