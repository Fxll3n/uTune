//
//  uTuneApp.swift
//  uTune
//
//  Created by Angel Bitsov on 10/23/25.
//

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import SwiftData

@main
struct uTuneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Song.self)
        
    }
}
