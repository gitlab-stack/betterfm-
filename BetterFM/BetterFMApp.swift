//
//  BetterFMApp.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import SwiftUI

@main
struct BetterFMApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
