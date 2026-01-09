# BetterFM - Real-time Last.fm Scrobbler for Apple Music

Because Last.fm wouldn't do it themselves.

## What is BetterFM?

BetterFM is a native iOS app that provides **proper, real-time Last.fm scrobbling for Apple Music**. Unlike the official Last.fm app, BetterFM:

- **Scrobbles songs immediately when they start playing** (not at the end)
- **Works flawlessly with Apple Music streaming** (including Apple Music subscription tracks)
- **Monitors playback in real-time** using Apple's MusicKit framework
- **Updates Now Playing** status on Last.fm instantly

## Features

- Real-time scrobbling as soon as a song starts
- Full Apple Music integration with MusicKit
- Beautiful native iOS interface with SwiftUI
- Now Playing view with album artwork
- Complete scrobble history
- Background monitoring support
- Works with both downloaded and streamed Apple Music tracks

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- An active Last.fm account
- Apple Music subscription (for streaming tracks)

## Setup

### 1. Get Last.fm API Credentials

1. Go to [https://www.last.fm/api/account/create](https://www.last.fm/api/account/create)
2. Create a new API application
3. Note down your **API Key** and **API Secret**

### 2. Configure the App

Open `BetterFM/Services/LastFMService.swift` and replace the placeholder values:

```swift
private let apiKey = "YOUR_LASTFM_API_KEY"
private let apiSecret = "YOUR_LASTFM_API_SECRET"
```

### 3. Build and Run

1. Open `BetterFM.xcodeproj` in Xcode
2. Select your development team in the project settings (Signing & Capabilities)
3. Build and run on your iOS device (scrobbling requires a physical device with Apple Music)

## How It Works

### Real-time Monitoring

BetterFM uses Apple's **MusicKit** framework to monitor the `ApplicationMusicPlayer` state. The app polls the playback state every second and detects:

- When a new song starts playing
- When playback is paused or stopped
- Track metadata (title, artist, album, artwork)

### Instant Scrobbling

As soon as a new track is detected:

1. **Now Playing** is updated on Last.fm immediately
2. The track is **scrobbled** to Last.fm right away (not after 50% playback)
3. The scrobble is recorded in your local history

This ensures your Last.fm profile is always up-to-date, even if you skip songs frequently.

### Background Support

The app includes background audio mode support, allowing it to continue monitoring playback even when not in the foreground.

## Usage

1. **Launch the app** and log in with your Last.fm credentials
2. **Grant Apple Music access** when prompted
3. **Play music** in the Apple Music app
4. Watch your scrobbles appear in real-time in the BetterFM app!

## Project Structure

```
BetterFM/
├── BetterFMApp.swift           # App entry point
├── AppState.swift              # Main app state management
├── ContentView.swift           # Root view with routing
├── Models/
│   └── Models.swift            # Data models
├── Services/
│   ├── MusicPlayerService.swift    # MusicKit integration
│   ├── LastFMService.swift         # Last.fm API client
│   └── ScrobblingService.swift     # Scrobbling coordination
└── Views/
    ├── LoginView.swift             # Last.fm authentication
    ├── NowPlayingView.swift        # Current track display
    └── HistoryView.swift           # Scrobble history
```

## Key Technologies

- **SwiftUI** - Modern declarative UI framework
- **MusicKit** - Apple's framework for Apple Music integration
- **Combine** - Reactive programming for state management
- **Last.fm API** - Music scrobbling and authentication

## Why This App Exists

The official Last.fm iOS app has long-standing issues with Apple Music:

- Scrobbles only happen after songs finish or reach 50% completion
- Frequently fails to detect Apple Music streaming tracks
- Unreliable background monitoring
- Poor integration with Apple's native music frameworks

BetterFM solves these problems by using Apple's official MusicKit framework to directly monitor Apple Music playback, ensuring reliable, real-time scrobbling.

## Security Note

Your Last.fm credentials are stored securely in UserDefaults on your device. The app uses Last.fm's mobile authentication API with hashed passwords (MD5) as required by their API specification. Session keys are persisted locally for convenience.

## Contributing

Issues and pull requests are welcome! This is an open-source project built out of frustration with the official Last.fm app.

## License

See LICENSE file for details.

## Disclaimer

This app is not affiliated with or endorsed by Last.fm or Apple. Apple Music and MusicKit are trademarks of Apple Inc. Last.fm is a trademark of Last.fm Limited.
