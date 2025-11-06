# Client API Specification - iOS/Swift HLS Streaming

## Overview

This API provides HLS (HTTP Live Streaming) video content optimized for iOS native playback. The server delivers adaptive bitrate streaming with multiple quality variants (720p, 1080p, 4k).

**Base URL:** `http://your-server-domain.com` (e.g., `http://localhost:3000` for local development)

---

## 📱 iOS Requirements

- **iOS 12.0+** (HLS support built into AVFoundation)
- **Swift 5.0+**
- **AVFoundation framework**
- No external dependencies required (native HLS support)

---

## 🔐 Authentication

Currently, no authentication is required. All endpoints are publicly accessible.

---

## 📋 API Endpoints

### 1. List All Media

Get a list of all available media.

**Endpoint:** `GET /api/media`

**Response:**

```json
[
  {
    "id": 3,
    "title": "The Office S01E03 - Health Care",
    "description": "Converted from The Office (US) - S01E03.mkv",
    "status": "ready",
    "hls_path": "/path/to/hls_output/3",
    "duration": 1320,
    "ready?": true,
    "created_at": "2025-10-21T14:11:29.798Z",
    "updated_at": "2025-10-21T14:45:12.123Z"
  }
]
```

**Status Values:**

- `pending` - Video uploaded, not yet processed
- `processing` - Currently converting to HLS
- `ready` - Available for streaming
- `failed` - Conversion failed

---

### 2. Get Media Details

Get details for a specific media item.

**Endpoint:** `GET /api/media/:id`

**Example:** `GET /api/media/3`

**Response:**

```json
{
  "id": 3,
  "title": "The Office S01E03 - Health Care",
  "description": "Converted from The Office (US) - S01E03.mkv",
  "status": "ready",
  "hls_path": "/path/to/hls_output/3",
  "duration": 1320,
  "ready?": true,
  "created_at": "2025-10-21T14:11:29.798Z",
  "updated_at": "2025-10-21T14:45:12.123Z"
}
```

---

### 3. Get HLS Stream (Master Playlist)

Get the master HLS playlist to start streaming.

**Endpoint:** `GET /api/media/:id/stream`

**Example:** `GET /api/media/3/stream`

**Response:** (Content-Type: `application/vnd.apple.mpegurl`)

```m3u8
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=1280x720
720p/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1920x1080
1080p_high/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=3840x2160
4k/index.m3u8
```

**Error Response (404):**

```json
{
  "error": "Media not ready for streaming"
}
```

---

## 📺 iOS Swift Implementation

### Basic Setup

```swift
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {

    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?

    // Base URL for your API
    let baseURL = "http://your-server-domain.com"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch available media
        fetchMediaList()
    }
}
```

---

### 1. Fetch Media List

```swift
func fetchMediaList() {
    guard let url = URL(string: "\(baseURL)/api/media") else { return }

    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching media: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        do {
            let mediaList = try JSONDecoder().decode([Media].self, from: data)

            // Filter for ready media
            let readyMedia = mediaList.filter { $0.status == "ready" }

            DispatchQueue.main.async {
                // Update your UI with ready media
                print("Found \(readyMedia.count) ready videos")
            }
        } catch {
            print("Decoding error: \(error)")
        }
    }.resume()
}

// Media model
struct Media: Codable {
    let id: Int
    let title: String
    let description: String?
    let status: String
    let duration: Int?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, status, duration
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

---

### 2. Play HLS Stream

```swift
func playMedia(mediaId: Int) {
    // Construct the HLS stream URL
    guard let streamURL = URL(string: "\(baseURL)/api/media/\(mediaId)/stream") else {
        print("Invalid URL")
        return
    }

    // Create AVPlayer with the HLS URL
    player = AVPlayer(url: streamURL)

    // Create player view controller
    playerViewController = AVPlayerViewController()
    playerViewController?.player = player

    // Present the player
    if let playerVC = playerViewController {
        present(playerVC, animated: true) {
            // Start playback
            self.player?.play()
        }
    }
}
```

---

### 3. Complete Example with Error Handling

```swift
import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {

    let baseURL = "http://localhost:3000" // Change to your server URL
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Example: Play media with ID 3
        checkAndPlayMedia(mediaId: 3)
    }

    func checkAndPlayMedia(mediaId: Int) {
        // First, check if media is ready
        guard let url = URL(string: "\(baseURL)/api/media/\(mediaId)") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    print("HTTP Error: \(httpResponse.statusCode)")
                    return
                }
            }

            do {
                let media = try JSONDecoder().decode(Media.self, from: data)

                DispatchQueue.main.async {
                    if media.status == "ready" {
                        self.playVideo(mediaId: mediaId, title: media.title)
                    } else {
                        self.showAlert(message: "Video is \(media.status). Please try again later.")
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

    func playVideo(mediaId: Int, title: String) {
        guard let streamURL = URL(string: "\(baseURL)/api/media/\(mediaId)/stream") else {
            print("Invalid stream URL")
            return
        }

        // Create player
        let playerItem = AVPlayerItem(url: streamURL)
        player = AVPlayer(playerItem: playerItem)

        // Create player view controller
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        // Optional: Set title
        playerViewController?.title = title

        // Present player
        present(playerViewController!, animated: true) {
            self.player?.play()
        }

        // Optional: Observe player status
        observePlayerStatus()
    }

    func observePlayerStatus() {
        guard let player = player else { return }

        player.currentItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // Observe playback errors
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFailToPlay),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: player.currentItem
        )
    }

    @objc func playerDidFailToPlay(notification: Notification) {
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            print("Playback error: \(error.localizedDescription)")
            showAlert(message: "Failed to play video: \(error.localizedDescription)")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .readyToPlay:
                    print("Ready to play")
                case .failed:
                    print("Failed to load: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                case .unknown:
                    print("Unknown status")
                @unknown default:
                    break
                }
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Video Player", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    deinit {
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
}

struct Media: Codable {
    let id: Int
    let title: String
    let description: String?
    let status: String
    let duration: Int?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, status, duration
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

---

### 4. SwiftUI Implementation

```swift
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let mediaId: Int
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var errorMessage: String?

    let baseURL = "http://localhost:3000"

    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .padding()
                    Button("Retry") {
                        loadVideo()
                    }
                }
            } else {
                ProgressView("Loading video...")
            }
        }
        .onAppear {
            loadVideo()
        }
    }

    func loadVideo() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(baseURL)/api/media/\(mediaId)") else {
            errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                guard let data = data, error == nil else {
                    errorMessage = error?.localizedDescription ?? "Network error"
                    return
                }

                do {
                    let media = try JSONDecoder().decode(Media.self, from: data)

                    if media.status == "ready" {
                        let streamURL = URL(string: "\(baseURL)/api/media/\(mediaId)/stream")!
                        player = AVPlayer(url: streamURL)
                    } else {
                        errorMessage = "Video is \(media.status)"
                    }
                } catch {
                    errorMessage = "Failed to decode response"
                }
            }
        }.resume()
    }
}

// Usage
struct ContentView: View {
    var body: some View {
        VideoPlayerView(mediaId: 3)
            .edgesIgnoringSafeArea(.all)
    }
}
```

---

## 🎯 Quality Selection

The HLS protocol automatically selects the best quality based on:

- Network bandwidth
- Device capabilities
- Screen size

iOS AVPlayer handles this automatically. No manual quality selection needed.

**Available qualities:**

- **720p** - 1280x720, 800 kbps (mobile/Wi-Fi)
- **1080p** - 1920x1080, 2.8 Mbps (HD streaming)
- **4k** - 3840x2160, 5 Mbps (Ultra HD, Apple TV, iPad Pro)

---

## 🔍 Error Handling

### Common Errors

**1. Media Not Found (404)**

```json
{
  "error": "Media not found"
}
```

**2. Media Not Ready (404)**

```json
{
  "error": "Media not ready for streaming"
}
```

**3. Segment Not Found (404)**

```json
{
  "error": "Segment not found",
  "segment": "720p/segment_001.ts"
}
```

### Swift Error Handling Example

```swift
func handleAPIError(data: Data?, response: URLResponse?, error: Error?) -> String? {
    if let error = error {
        return "Network error: \(error.localizedDescription)"
    }

    guard let httpResponse = response as? HTTPURLResponse else {
        return "Invalid response"
    }

    switch httpResponse.statusCode {
    case 200:
        return nil // Success
    case 404:
        if let data = data,
           let json = try? JSONDecoder().decode([String: String].self, from: data),
           let message = json["error"] {
            return message
        }
        return "Resource not found"
    case 500:
        return "Server error"
    default:
        return "HTTP error: \(httpResponse.statusCode)"
    }
}
```

---

## 📊 Monitoring Playback

### Track Playback Progress

```swift
func observePlaybackProgress() {
    guard let player = player else { return }

    // Add periodic time observer (updates every 0.5 seconds)
    let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

    player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
        let currentTime = CMTimeGetSeconds(time)

        if let duration = player.currentItem?.duration {
            let totalTime = CMTimeGetSeconds(duration)
            let progress = currentTime / totalTime

            print("Progress: \(progress * 100)%")
            // Update your UI with progress
        }
    }
}
```

### Detect Buffering

```swift
func observeBuffering() {
    guard let player = player else { return }

    player.currentItem?.addObserver(
        self,
        forKeyPath: "playbackBufferEmpty",
        options: .new,
        context: nil
    )

    player.currentItem?.addObserver(
        self,
        forKeyPath: "playbackLikelyToKeepUp",
        options: .new,
        context: nil
    )
}

override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "playbackBufferEmpty" {
        // Show loading indicator
        print("Buffering...")
    } else if keyPath == "playbackLikelyToKeepUp" {
        // Hide loading indicator
        print("Ready to play")
    }
}
```

---

## 🎬 Background Playback (Optional)

To allow video to play in background:

### 1. Enable Audio, AirPlay, and Picture in Picture in Xcode

- Select your target
- Go to "Signing & Capabilities"
- Add "Background Modes"
- Check "Audio, AirPlay, and Picture in Picture"

### 2. Configure Audio Session

```swift
import AVFoundation

func setupAudioSession() {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("Failed to set up audio session: \(error)")
    }
}

// Call in viewDidLoad or before playing
setupAudioSession()
```

---

## 📱 Picture in Picture Support

```swift
import AVKit

var pipController: AVPictureInPictureController?

func setupPictureInPicture() {
    guard let playerViewController = playerViewController else { return }

    if AVPictureInPictureController.isPictureInPictureSupported() {
        pipController = AVPictureInPictureController(playerLayer: playerViewController.playerLayer)
        pipController?.delegate = self
    }
}

// Enable PiP
func enablePictureInPicture() {
    pipController?.startPictureInPicture()
}

// Implement AVPictureInPictureControllerDelegate
extension VideoPlayerViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will start")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did stop")
    }
}
```

---

## 🚀 Quick Start

**Minimal working example:**

```swift
import UIKit
import AVKit

class SimplePlayerViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Replace with your server URL and media ID
        let streamURL = URL(string: "http://localhost:3000/api/media/3/stream")!

        let player = AVPlayer(url: streamURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = player

        present(playerVC, animated: true) {
            player.play()
        }
    }
}
```

**That's it!** iOS handles HLS streaming natively.

---

## 🔧 Testing

### Test with cURL

```bash
# Check if media is ready
curl http://localhost:3000/api/media/3

# Get master playlist
curl http://localhost:3000/api/media/3/stream

# Test specific quality
curl http://localhost:3000/api/media/3/stream/720p/index.m3u8
```

### Test in Safari (iOS Simulator or Device)

Open Safari and navigate to:

```
http://localhost:3000/api/media/3/stream
```

Safari will automatically play the HLS stream.

---

## 📝 Notes

1. **HTTPS in Production**: For production apps, use HTTPS. Apple requires HTTPS for HLS streaming unless you add ATS exceptions.

2. **Network Performance**: The adaptive bitrate will automatically adjust quality based on network conditions.

3. **Caching**: iOS automatically caches HLS segments for smooth playback.

4. **AirPlay**: Works out of the box with AVPlayerViewController.

5. **Device Support**: All iOS devices support HLS natively. No additional codecs needed.

---

## 🐛 Troubleshooting

### "Cannot play video" error

1. Check media status is "ready"
2. Verify HLS files exist on server
3. Test the stream URL in Safari
4. Check network connectivity
5. Verify CORS headers (included by default)

### Buffering issues

1. Check network speed
2. Server may still be generating segments
3. Try lower quality variant manually

### Black screen

1. Ensure `AVPlayerViewController` is properly presented
2. Check if `player.play()` is called
3. Verify the stream URL is correct

---

## 📚 Additional Resources

- [Apple HLS Documentation](https://developer.apple.com/streaming/)
- [AVFoundation Programming Guide](https://developer.apple.com/documentation/avfoundation/)
- [AVPlayer Documentation](https://developer.apple.com/documentation/avfoundation/avplayer)

---

## Support

For API issues, contact the backend team or check the main API documentation.

