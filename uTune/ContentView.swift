//
//  ContentView.swift
//  uTune
//
//  Created by Angel Bitsov on 10/23/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var songs: [Song] = []
    @State private var showingImporter = false
    @State private var player: AVAudioPlayer?
    @State private var currentSong: Song?
    @State private var isPlaying = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            List {
                if songs.isEmpty {
                    Text("No songs added. Tap + to import audio files.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(songs) { song in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(song.name)
                                    .font(.headline)
                                Text(formatTime(song.duration))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if currentSong?.id == song.id && isPlaying {
                                Image(systemName: "waveform.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { play(song) }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Music Player")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingImporter = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [UTType.audio],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    importSongs(from: urls)
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    func importSongs(from urls: [URL]) {
        for url in urls {
            do {
                let asset = AVURLAsset(url: url)
                let duration = CMTimeGetSeconds(asset.duration)
                let name = url.deletingPathExtension().lastPathComponent
                let song = Song(url: url, name: name, duration: duration)
                if !songs.contains(where: { $0.url == url }) {
                    songs.append(song)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func play(_ song: Song) {
        do {
            if currentSong?.id == song.id && isPlaying {
                player?.pause()
                isPlaying = false
                return
            }
            player = try AVAudioPlayer(contentsOf: song.url)
            player?.prepareToPlay()
            player?.play()
            currentSong = song
            isPlaying = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(at offsets: IndexSet) {
        songs.remove(atOffsets: offsets)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
