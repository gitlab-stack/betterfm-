//
//  Models.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import Foundation

struct Track: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let albumArtURL: URL?
    let timestamp: Date

    init(id: String = UUID().uuidString, title: String, artist: String, album: String? = nil, duration: TimeInterval = 0, albumArtURL: URL? = nil, timestamp: Date = Date()) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.albumArtURL = albumArtURL
        self.timestamp = timestamp
    }
}

struct ScrobbleEntry: Identifiable, Codable {
    let id: String
    let track: Track
    let scrobbledAt: Date
    let success: Bool

    init(id: String = UUID().uuidString, track: Track, scrobbledAt: Date = Date(), success: Bool) {
        self.id = id
        self.track = track
        self.scrobbledAt = scrobbledAt
        self.success = success
    }
}

struct LastFMSession: Codable {
    let sessionKey: String
    let username: String
}

enum PlaybackState {
    case playing
    case paused
    case stopped
}

enum ScrobbleError: Error, LocalizedError {
    case notAuthenticated
    case networkError(String)
    case apiError(String)
    case invalidTrack

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not logged in to Last.fm"
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "Last.fm API error: \(message)"
        case .invalidTrack:
            return "Invalid track information"
        }
    }
}
