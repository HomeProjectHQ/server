# 🚀 Quick Start - Convert Your TV Show Episode

## Where to Place Your Video File

You can place your `.mp4` (or any video format) **anywhere on your computer**. Just reference the full path when converting.

Alternatively, for convenience:

```bash
# Copy to the source videos directory
cp /path/to/your/episode.mp4 storage/source_videos/
```

---

## Convert Your Video (3 Simple Steps)

### 1. Start the background job processor:

```bash
bin/jobs
```

_Keep this terminal open_

### 2. In a new terminal, convert your video:

```bash
# Using full path to your video file:
bin/rails media:convert[/Users/yourusername/Downloads/episode.mp4,'My Show S01E01']

# Or if you copied it to storage/source_videos:
bin/rails media:convert[storage/source_videos/episode.mp4,'My Show S01E01']
```

### 3. Monitor the conversion (optional):

```bash
tail -f log/development.log
```

---

## What Happens During Conversion?

The job will:

1. Create a Media record in the database
2. Convert your video to HLS format with **3 quality variants**:
   - **720p** (800kbps) - for mobile/slower connections
   - **1080p** (2.8Mbps) - for HD streaming
   - **4k** (5Mbps) - for ultra HD
3. Generate `.m3u8` playlists and `.ts` segments
4. Store everything in `public/hls_output/{media_id}/`
5. Update status to "ready" when complete

---

## Stream Your Video

Once the status is "ready", access your stream:

### Master playlist (auto-selects quality):

```
http://localhost:3000/api/media/1/stream
```

Use this URL in any HLS-compatible player:

- VLC Media Player
- Safari (iOS/macOS)
- Video.js (web player)
- Native iOS AVPlayer
- Android ExoPlayer

---

## Full Example

```bash
# Terminal 1: Start background jobs
bin/jobs

# Terminal 2: Convert your video
bin/rails media:convert[~/Movies/breaking-bad-pilot.mp4,'Breaking Bad - Pilot']

# Output:
# Created Media record with ID: 3
# Title: Breaking Bad - Pilot
# Status: pending
#
# Queued ProcessVideoJob for media 3
# The video will be converted to HLS format with 720p, 1080p, and 4k variants
# Monitor the job progress with: bin/rails solid_queue:start
#
# Once complete, stream at: GET /api/media/3/stream

# Wait for processing (watch logs or check status)
curl http://localhost:3000/api/media/3

# Once status is "ready", stream it!
# Use in VLC or any video player
```

---

## Test the Streaming

### Using curl:

```bash
# Get the master playlist
curl http://localhost:3000/api/media/1/stream

# Output:
# #EXTM3U
# #EXT-X-VERSION:3
# #EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=1280x720
# 720p/index.m3u8
# ...
```

### Using a browser/video player:

Just open: `http://localhost:3000/api/media/1/stream` in Safari or any HLS player

---

## Requirements

Make sure FFmpeg is installed:

```bash
# macOS
brew install ffmpeg

# Verify
ffmpeg -version
```

---

## Conversion Time Estimates

Conversion time depends on your video length and system:

- **10-minute video**: ~5-15 minutes
- **45-minute TV episode**: ~20-60 minutes
- **2-hour movie**: ~1-2 hours

The job creates 3 quality variants, so it takes 3x the processing time of a single transcode.

---

## Need Help?

See the full documentation: `USAGE.md`

Happy streaming! 🎬

