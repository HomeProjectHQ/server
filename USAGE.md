# HLS Media Streaming Server - Usage Guide

## 📁 Where to Place Your Video Files

You have two options:

### Option 1: Use the Rake Task (Recommended)

Place your TV show episode (`.mp4`, `.mkv`, `.avi`, etc.) **anywhere on your computer**. You'll reference the full path when running the conversion command.

### Option 2: Use the storage directory

Copy your video file to: `storage/source_videos/`

Example:

```bash
cp ~/Downloads/my-episode.mp4 storage/source_videos/
```

---

## 🎬 Converting Video to HLS Format

### Using the Rake Task (Easiest)

1. **Make sure Solid Queue is running** (in a separate terminal):

```bash
bin/jobs
```

2. **Queue the conversion job**:

```bash
# From anywhere on your system:
bin/rails media:convert[/path/to/your/episode.mp4,'Episode 1 - Pilot']

# Or from the storage directory:
bin/rails media:convert[storage/source_videos/episode.mp4,'My TV Show S01E01']
```

3. **Monitor the conversion**:
   The job will automatically:

- Create a Media record in the database
- Convert the video to HLS format with 3 quality variants:
  - 720p (800kbps)
  - 1080p (2.8Mbps)
  - 4k (5Mbps)
- Store segments in `public/hls_output/{media_id}/`
- Update the status to "ready" when complete

### Manual Job Queuing (via Rails console)

```ruby
# Create a media record
media = Media.create!(title: "Episode 1", status: "pending")

# Queue the conversion job
ProcessVideoJob.perform_later(media.id, "/path/to/video.mp4")
```

---

## 📺 Streaming the Video

Once the conversion is complete (status: "ready"), you can stream the video:

### Get Media Info

```bash
curl http://localhost:3000/api/media/1
```

### Stream the Video (Master Playlist)

```bash
curl http://localhost:3000/api/media/1/stream
```

This returns the master `.m3u8` playlist that lists all quality variants.

### Access Specific Variant Playlists

```bash
# 720p variant
curl http://localhost:3000/api/media/1/stream/720p/index.m3u8

# 1080p variant
curl http://localhost:3000/api/media/1/stream/1080p_high/index.m3u8

# 4k variant
curl http://localhost:3000/api/media/1/stream/4k/index.m3u8
```

### Access Video Segments

```bash
curl http://localhost:3000/api/media/1/stream/720p/segment_000.ts
curl http://localhost:3000/api/media/1/stream/1080p_high/segment_001.ts
```

---

## 🔧 Running the Server

### Start the Rails server:

```bash
bin/rails server
```

### Start Solid Queue (for background jobs):

```bash
bin/jobs
```

Or start both together:

```bash
bin/dev
```

---

## 📋 Useful Commands

### List all media:

```bash
bin/rails media:list
```

### Check job queue:

```bash
bin/rails runner "puts SolidQueue::Job.all.map { |j| [j.class_name, j.arguments, j.finished_at].inspect }.join('\n')"
```

### View logs:

```bash
tail -f log/development.log
```

---

## 🎯 Example Workflow

1. **Place your video file**:

```bash
cp ~/Downloads/breaking-bad-s01e01.mp4 storage/source_videos/
```

2. **Start background jobs**:

```bash
bin/jobs
```

3. **Queue conversion** (in another terminal):

```bash
bin/rails media:convert[storage/source_videos/breaking-bad-s01e01.mp4,'Breaking Bad S01E01']
```

4. **Wait for processing** (watch the logs):

```bash
tail -f log/development.log
```

5. **Once ready, test streaming**:

```bash
curl http://localhost:3000/api/media/1/stream
```

6. **Use in a video player** (like VLC or a web player):

```
http://localhost:3000/api/media/1/stream
```

---

## 🌐 API Endpoints

| Method | Endpoint                      | Description                    |
| ------ | ----------------------------- | ------------------------------ |
| GET    | `/api/media`                  | List all media                 |
| GET    | `/api/media/:id`              | Get media details              |
| POST   | `/api/media`                  | Create media (with video_file) |
| PATCH  | `/api/media/:id`              | Update media                   |
| DELETE | `/api/media/:id`              | Delete media                   |
| GET    | `/api/media/:id/stream`       | Get master HLS playlist        |
| GET    | `/api/media/:id/stream/*path` | Get HLS segments/variants      |

---

## 🎬 FFmpeg Requirements

Make sure FFmpeg is installed:

```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get install ffmpeg

# Verify installation
ffmpeg -version
```

---

## 📱 iOS/Safari Compatibility

The server is configured with proper CORS headers for iOS streaming:

- Content-Type: `application/vnd.apple.mpegurl` for `.m3u8`
- Content-Type: `video/mp2t` for `.ts` segments
- CORS enabled for cross-origin requests
- Range request support for seeking

---

## 🔍 Troubleshooting

### Job not processing?

- Make sure `bin/jobs` is running
- Check logs: `tail -f log/development.log`

### FFmpeg not found?

- Install FFmpeg (see above)
- Verify with: `which ffmpeg`

### Video not streaming?

- Check media status: `curl http://localhost:3000/api/media/:id`
- Verify HLS files exist: `ls public/hls_output/:id/`

### Out of disk space?

- HLS files can be large (especially 4k)
- Consider reducing quality variants in `ProcessVideoJob`

