//
//  LastFMService.swift
//  BetterFM
//
//  Created by BetterFM on 2026-01-09.
//

import Foundation
import CryptoKit

class LastFMService {
    private let apiKey = "YOUR_LASTFM_API_KEY"
    private let apiSecret = "YOUR_LASTFM_API_SECRET"
    private let baseURL = "https://ws.audioscrobbler.com/2.0/"

    private var sessionKey: String?
    private var username: String?

    init() {
        loadSession()
    }

    func authenticate(username: String, password: String) async throws -> LastFMSession {
        let authToken = md5(username + md5(password))

        var params: [String: String] = [
            "method": "auth.getMobileSession",
            "username": username,
            "authToken": authToken,
            "api_key": apiKey
        ]

        params["api_sig"] = generateSignature(params: params)
        params["format"] = "json"

        guard let url = URL(string: baseURL) else {
            throw ScrobbleError.apiError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ScrobbleError.networkError("HTTP error")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        if let error = json?["error"] as? Int, let message = json?["message"] as? String {
            throw ScrobbleError.apiError(message)
        }

        guard let session = json?["session"] as? [String: Any],
              let key = session["key"] as? String,
              let name = session["name"] as? String else {
            throw ScrobbleError.apiError("Invalid response")
        }

        let lastFMSession = LastFMSession(sessionKey: key, username: name)
        self.sessionKey = key
        self.username = name
        saveSession(lastFMSession)

        return lastFMSession
    }

    func scrobble(track: Track, timestamp: Date = Date()) async throws {
        guard let sessionKey = sessionKey else {
            throw ScrobbleError.notAuthenticated
        }

        var params: [String: String] = [
            "method": "track.scrobble",
            "artist": track.artist,
            "track": track.title,
            "timestamp": String(Int(timestamp.timeIntervalSince1970)),
            "api_key": apiKey,
            "sk": sessionKey
        ]

        if let album = track.album {
            params["album"] = album
        }

        params["api_sig"] = generateSignature(params: params)
        params["format"] = "json"

        guard let url = URL(string: baseURL) else {
            throw ScrobbleError.apiError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        if let error = json?["error"] as? Int, let message = json?["message"] as? String {
            throw ScrobbleError.apiError(message)
        }
    }

    func updateNowPlaying(track: Track) async throws {
        guard let sessionKey = sessionKey else {
            throw ScrobbleError.notAuthenticated
        }

        var params: [String: String] = [
            "method": "track.updateNowPlaying",
            "artist": track.artist,
            "track": track.title,
            "api_key": apiKey,
            "sk": sessionKey
        ]

        if let album = track.album {
            params["album"] = album
        }

        if track.duration > 0 {
            params["duration"] = String(Int(track.duration))
        }

        params["api_sig"] = generateSignature(params: params)
        params["format"] = "json"

        guard let url = URL(string: baseURL) else {
            throw ScrobbleError.apiError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        if let error = json?["error"] as? Int, let message = json?["message"] as? String {
            throw ScrobbleError.apiError(message)
        }
    }

    private func generateSignature(params: [String: String]) -> String {
        let sorted = params.sorted { $0.key < $1.key }
        let signatureString = sorted.map { "\($0.key)\($0.value)" }.joined() + apiSecret
        return md5(signatureString)
    }

    private func md5(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    func saveSession(_ session: LastFMSession) {
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: "lastfm_session")
        }
    }

    @discardableResult
    func loadSession() -> LastFMSession? {
        guard let data = UserDefaults.standard.data(forKey: "lastfm_session"),
              let session = try? JSONDecoder().decode(LastFMSession.self, from: data) else {
            return nil
        }

        self.sessionKey = session.sessionKey
        self.username = session.username
        return session
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "lastfm_session")
        sessionKey = nil
        username = nil
    }
}
