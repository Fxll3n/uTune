//
//  ContentView.swift
//  uTune
//
//  Created by Angel Bitsov on 10/23/25.
//

import SwiftUI
import AVFoundation
import UIKit
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @Environment(Player.self) var player
    
    @Query var songs: [Song] = []
    @State private var showingImporter = false
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
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(song.name)
                                        .font(.headline)
                                    Text(song.artist)
                                        .font(.caption2)
                                    Text(formatTime(song.duration))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if player.currentTrack == song && player.isPlaying {
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
                    print("Imported URLs:", urls)
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
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let dest = documents.appendingPathComponent(url.lastPathComponent)
                
                if !fileManager.fileExists(atPath: dest.path) {
                    try fileManager.copyItem(at: url, to: dest)
                }
                
                let asset = AVURLAsset(url: dest)
                let duration = CMTimeGetSeconds(asset.duration)
                let name = dest.deletingPathExtension().lastPathComponent
                let artist = asset.commonMetadata
                    .first(where: { $0.commonKey?.rawValue == "artist" })?.stringValue ?? "Unknown Artist"
                
                let song = Song(url: dest, name: name, artist: artist, duration: duration)
                if !songs.contains(where: { $0.url == dest }) {
                    context.insert(song)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        do { try context.save() } catch { errorMessage = error.localizedDescription }
    }



    func play(_ song: Song) {
        do {
            if player.currentTrack == song && player.isPlaying {
                player.pause()
                player.isPlaying = false
                return
            }
            player.play(song: song)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(offsets: IndexSet) {
        for index in offsets {
            if player.currentTrack == songs[index] {
                player.pause()
                player.currentTrack = nil
            }
            context.delete(songs[index])
        }
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
