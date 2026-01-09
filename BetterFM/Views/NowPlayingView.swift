//
//  NowPlayingView.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            if let track = appState.currentTrack {
                AsyncImage(url: track.albumArtURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 250, height: 250)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    case .failure:
                        Image(systemName: "music.note")
                            .font(.system(size: 100))
                            .foregroundColor(.secondary)
                            .frame(width: 250, height: 250)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.top, 40)

                VStack(spacing: 8) {
                    Text(track.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(track.artist)
                        .font(.title3)
                        .foregroundColor(.secondary)

                    if let album = track.album {
                        Text(album)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 16) {
                    Image(systemName: playbackIcon)
                        .font(.title2)
                        .foregroundColor(playbackColor)

                    Text(playbackText)
                        .font(.subheadline)
                        .foregroundColor(playbackColor)
                }
                .padding(.top, 8)

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Scrobbled to Last.fm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)

            } else {
                VStack(spacing: 20) {
                    Image(systemName: "music.note")
                        .font(.system(size: 80))
                        .foregroundColor(.secondary)

                    Text("No Music Playing")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Start playing music in Apple Music to see it here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 100)
            }

            Spacer()
        }
    }

    private var playbackIcon: String {
        switch appState.playbackState {
        case .playing:
            return "play.circle.fill"
        case .paused:
            return "pause.circle.fill"
        case .stopped:
            return "stop.circle.fill"
        }
    }

    private var playbackColor: Color {
        switch appState.playbackState {
        case .playing:
            return .green
        case .paused:
            return .orange
        case .stopped:
            return .red
        }
    }

    private var playbackText: String {
        switch appState.playbackState {
        case .playing:
            return "Now Playing"
        case .paused:
            return "Paused"
        case .stopped:
            return "Stopped"
        }
    }
}

#Preview {
    NowPlayingView()
        .environmentObject(AppState())
}
