//
//  ScrobblingService.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import Foundation

class ScrobblingService {
    private let lastFMService: LastFMService
    private var currentTrackID: String?

    init(lastFMService: LastFMService) {
        self.lastFMService = lastFMService
    }

    func scrobble(track: Track) async throws {
        guard track.title.count > 0 && track.artist.count > 0 else {
            throw ScrobbleError.invalidTrack
        }

        if currentTrackID == track.id {
            return
        }

        currentTrackID = track.id

        try await lastFMService.updateNowPlaying(track: track)

        try await lastFMService.scrobble(track: track, timestamp: Date())
    }

    func reset() {
        currentTrackID = nil
    }
}
