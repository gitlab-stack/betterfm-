//
//  HistoryView.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            if appState.scrobbleHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("No Scrobbles Yet")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Your scrobble history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
                .listRowBackground(Color.clear)
            } else {
                ForEach(appState.scrobbleHistory) { entry in
                    ScrobbleRow(entry: entry)
                }
            }
        }
        .navigationTitle("History")
    }
}

struct ScrobbleRow: View {
    let entry: ScrobbleEntry

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: entry.track.albumArtURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                case .failure:
                    Image(systemName: "music.note")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .frame(width: 50, height: 50)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.track.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(entry.track.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(timeAgo(from: entry.scrobbledAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: entry.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(entry.success ? .green : .red)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    NavigationView {
        HistoryView()
            .environmentObject(AppState())
    }
}
