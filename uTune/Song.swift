//
//  Song.swift
//  uTune
//
//  Created by Angel Bitsov on 10/23/25.
//

import Foundation
import UIKit
import SwiftData

@Model
class Song: Identifiable {
    var id = UUID()
    var url: URL
    var name: String
    var artist: String
    var duration: TimeInterval
    
    init(id: UUID = UUID(), url: URL, name: String, artist: String, duration: TimeInterval) {
        self.id = id
        self.url = url
        self.name = name
        self.artist = artist
        self.duration = duration
    }
}

