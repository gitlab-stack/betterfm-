//
//  AppState.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentTrack: Track?
    @Published var playbackState: PlaybackState = .stopped
    @Published var scrobbleHistory: [ScrobbleEntry] = []
    @Published var lastFMUsername: String?
    @Published var errorMessage: String?
    @Published var isMusicAuthorized = false

    private let lastFMService: LastFMService
    private let musicPlayerService: MusicPlayerService
    private let scrobblingService: ScrobblingService

    init() {
        self.lastFMService = LastFMService()
        self.musicPlayerService = MusicPlayerService()
        self.scrobblingService = ScrobblingService(lastFMService: lastFMService)

        Task {
            await loadSavedSession()
            await checkMusicAuthorization()
        }
    }

    func loadSavedSession() async {
        if let session = lastFMService.loadSession() {
            isAuthenticated = true
            lastFMUsername = session.username
            await startMonitoring()
        }
    }

    func checkMusicAuthorization() async {
        isMusicAuthorized = await musicPlayerService.requestAuthorization()
    }

    func login(username: String, password: String) async {
        do {
            let session = try await lastFMService.authenticate(username: username, password: password)
            isAuthenticated = true
            lastFMUsername = session.username
            await startMonitoring()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() async {
        lastFMService.logout()
        isAuthenticated = false
        lastFMUsername = nil
        await stopMonitoring()
        currentTrack = nil
        playbackState = .stopped
        scrobbleHistory = []
    }

    func startMonitoring() async {
        guard isMusicAuthorized else {
            await checkMusicAuthorization()
            return
        }

        await musicPlayerService.startMonitoring { [weak self] track, state in
            await self?.handlePlaybackChange(track: track, state: state)
        }
    }

    func stopMonitoring() async {
        await musicPlayerService.stopMonitoring()
    }

    private func handlePlaybackChange(track: Track?, state: PlaybackState) async {
        playbackState = state

        if let track = track, state == .playing {
            if currentTrack?.id != track.id {
                currentTrack = track
                await scrobbleTrack(track)
            }
        } else if state == .stopped || state == .paused {
            if state == .stopped {
                currentTrack = nil
            }
        }
    }

    private func scrobbleTrack(_ track: Track) async {
        do {
            try await scrobblingService.scrobble(track: track)
            let entry = ScrobbleEntry(track: track, success: true)
            scrobbleHistory.insert(entry, at: 0)

            if scrobbleHistory.count > 50 {
                scrobbleHistory = Array(scrobbleHistory.prefix(50))
            }
        } catch {
            let entry = ScrobbleEntry(track: track, success: false)
            scrobbleHistory.insert(entry, at: 0)
            errorMessage = error.localizedDescription
        }
    }
}
