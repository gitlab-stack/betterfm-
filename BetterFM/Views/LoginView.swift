//
//  LoginView.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .padding(.top, 60)

                Text("BetterFM")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Real-time Last.fm scrobbling for Apple Music")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    TextField("Last.fm Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)

                if let error = appState.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 32)
                }

                Button(action: login) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login to Last.fm")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(username.isEmpty || password.isEmpty || isLoading)
                .padding(.horizontal, 32)
                .padding(.top, 16)

                if !appState.isMusicAuthorized {
                    VStack(spacing: 12) {
                        Text("Apple Music Access Required")
                            .font(.headline)
                            .foregroundColor(.orange)

                        Text("Please grant access to Apple Music in Settings to enable scrobbling")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.caption)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)
                }

                Spacer()

                Text("Note: You'll need your Last.fm account credentials.\nDon't have an account? Sign up at last.fm")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
            .navigationBarHidden(true)
        }
    }

    private func login() {
        isLoading = true
        Task {
            await appState.login(username: username, password: password)
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
