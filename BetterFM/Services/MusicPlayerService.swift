//
//  MusicPlayerService.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import Foundation
import MusicKit
import MediaPlayer
import Combine

@MainActor
class MusicPlayerService: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var monitoringTask: Task<Void, Never>?
    private var playbackCallback: ((Track?, PlaybackState) -> Void)?

    func requestAuthorization() async -> Bool {
        let status = await MusicAuthorization.request()
        return status == .authorized
    }

    func startMonitoring(callback: @escaping (Track?, PlaybackState) async -> Void) async {
        playbackCallback = { track, state in
            Task { @MainActor in
                await callback(track, state)
            }
        }

        monitoringTask = Task { @MainActor in
            await self.monitorPlayback()
        }
    }

    func stopMonitoring() async {
        monitoringTask?.cancel()
        monitoringTask = nil
        playbackCallback = nil
    }

    private func monitorPlayback() async {
        let player = ApplicationMusicPlayer.shared
        var lastTrackID: String?

        while !Task.isCancelled {
            do {
                let state = player.state

                if state.playbackStatus == .playing, let currentEntry = state.queue.currentEntry {
                    if let track = await self.extractTrack(from: currentEntry) {
                        if lastTrackID != track.id {
                            lastTrackID = track.id
                            playbackCallback?(track, .playing)
                        }
                    }
                } else if state.playbackStatus == .paused {
                    playbackCallback?(nil, .paused)
                } else if state.playbackStatus == .stopped {
                    lastTrackID = nil
                    playbackCallback?(nil, .stopped)
                }

                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                if Task.isCancelled {
                    break
                }
            }
        }
    }

    private func extractTrack(from entry: ApplicationMusicPlayer.Queue.Entry) async -> Track? {
        switch entry.item {
        case .song(let song):
            return Track(
                id: song.id.rawValue,
                title: song.title,
                artist: song.artistName,
                album: song.albumTitle,
                duration: song.duration ?? 0,
                albumArtURL: song.artwork?.url(width: 300, height: 300),
                timestamp: Date()
            )
        default:
            return nil
        }
    }
}
