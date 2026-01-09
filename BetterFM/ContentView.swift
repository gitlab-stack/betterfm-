//
//  ContentView.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .alert("Error", isPresented: .constant(appState.errorMessage != nil)) {
            Button("OK") {
                appState.errorMessage = nil
            }
        } message: {
            if let error = appState.errorMessage {
                Text(error)
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            NavigationView {
                NowPlayingView()
                    .navigationTitle("Now Playing")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                if let username = appState.lastFMUsername {
                                    Text("Logged in as \(username)")
                                        .font(.caption)
                                }

                                Divider()

                                Button(role: .destructive, action: logout) {
                                    Label("Logout", systemImage: "arrow.right.square")
                                }
                            } label: {
                                Image(systemName: "person.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Label("Now Playing", systemImage: "play.circle")
            }

            NavigationView {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
        }
    }

    private func logout() {
        Task {
            await appState.logout()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
