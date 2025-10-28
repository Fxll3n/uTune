//
//  Player.swift
//  uTune
//
//  Created by Angel Bitsov on 10/27/25.
//

import Foundation
import AVFoundation

@Observable
class Player {
    private var player: AVPlayer
    var isPlaying: Bool = false
    var currentTrack: Song?
    
    init() {
        player = AVPlayer()
    }
    
    func play(song: Song) {
        isPlaying = true
        currentTrack = song
        player = AVPlayer(url: currentTrack!.url)
        player.play()
    }
    
    
    func pause() {
        isPlaying = false
        player.pause()
    }
    
}
