# Watch Progress API Integration Guide

## Overview

The Watch Progress API provides endpoints to track playback position, completion status, and watch history for movies, TV episodes, and songs. This system uses a polymorphic association to handle all media types through a unified interface.

## Key Features

- 📍 **Position Tracking**: Save and retrieve playback position in seconds
- ✅ **Auto-completion**: Automatically marks media as "completed" when 90%+ watched
- 🔢 **Watch Count**: Tracks how many times media has been restarted from beginning
- 📺 **Smart TV Navigation**: Automatically determines next episode to watch
- 🎬 **Continue Watching**: Cross-media "continue watching" shelf

---

## Endpoints

### 1. Get Continue Watching (All Media Types)

Returns in-progress media across movies, TV shows, and music.

```http
GET /api/profiles/:profile_id/watch_progresses
```

**Parameters:**

- `limit` (optional): Number of items to return (default: 20)

**Example Request:**

```bash
curl http://localhost:3000/api/profiles/1/watch_progresses?limit=10
```

**Example Response:**

```json
[
  {
    "id": 42,
    "watchable_type": "Movie",
    "watchable_id": 5,
    "position_seconds": 3245,
    "duration_seconds": 7200,
    "progress_percentage": 45.07,
    "completed": false,
    "last_watched_at": "2025-10-28T10:30:00.000Z",
    "watch_count": 1,
    "watchable": {
      "type": "movie",
      "id": 5,
      "title": "Inception",
      "year": 2010,
      "poster_url": "https://image.tmdb.org/t/p/w500/...",
      "hls_path": "/hls_output/5/index.m3u8"
    }
  },
  {
    "id": 43,
    "watchable_type": "TvEpisode",
    "watchable_id": 12,
    "position_seconds": 420,
    "duration_seconds": 1320,
    "progress_percentage": 31.82,
    "completed": false,
    "last_watched_at": "2025-10-28T09:15:00.000Z",
    "watch_count": 1,
    "watchable": {
      "type": "tv_episode",
      "id": 12,
      "title": "Pilot",
      "season_number": 1,
      "episode_number": 1,
      "still_url": "https://image.tmdb.org/t/p/w300/...",
      "tv_show": {
        "id": 3,
        "title": "Breaking Bad",
        "poster_url": "https://image.tmdb.org/t/p/w500/..."
      }
    }
  }
]
```

---

### 2. Get Progress for Specific Media

Retrieve watch progress for a specific movie, episode, or song.

```http
GET /api/profiles/:profile_id/watch_progresses/:watchable_type/:watchable_id
```

**Path Parameters:**

- `watchable_type`: One of `movie`, `tv_episode`, or `song` (lowercase, underscored)
- `watchable_id`: The ID of the media item

**Example Request:**

```bash
curl http://localhost:3000/api/profiles/1/watch_progresses/movie/5
```

**Example Response:**

```json
{
  "id": 42,
  "watchable_type": "Movie",
  "watchable_id": 5,
  "position_seconds": 3245,
  "duration_seconds": 7200,
  "progress_percentage": 45.07,
  "completed": false,
  "last_watched_at": "2025-10-28T10:30:00.000Z",
  "watch_count": 1,
  "watchable": {
    "type": "movie",
    "id": 5,
    "title": "Inception",
    "year": 2010,
    "poster_url": "https://image.tmdb.org/t/p/w500/...",
    "hls_path": "/hls_output/5/index.m3u8"
  }
}
```

---

### 3. Update Watch Progress

Update the playback position for any media item. Creates progress record if it doesn't exist.

```http
PUT /api/profiles/:profile_id/watch_progresses/:watchable_type/:watchable_id
PATCH /api/profiles/:profile_id/watch_progresses/:watchable_type/:watchable_id
```

**Request Body:**

```json
{
  "watch_progress": {
    "position_seconds": 3600,
    "duration_seconds": 7200
  }
}
```

**Example Request:**

```bash
curl -X PUT http://localhost:3000/api/profiles/1/watch_progresses/movie/5 \
  -H "Content-Type: application/json" \
  -d '{
    "watch_progress": {
      "position_seconds": 3600,
      "duration_seconds": 7200
    }
  }'
```

**Example Response:**

```json
{
  "id": 42,
  "watchable_type": "Movie",
  "watchable_id": 5,
  "position_seconds": 3600,
  "duration_seconds": 7200,
  "progress_percentage": 50.0,
  "completed": false,
  "last_watched_at": "2025-10-28T11:00:00.000Z",
  "watch_count": 1,
  "watchable": {
    "type": "movie",
    "id": 5,
    "title": "Inception",
    "year": 2010,
    "poster_url": "https://image.tmdb.org/t/p/w500/...",
    "hls_path": "/hls_output/5/index.m3u8"
  }
}
```

**Behavior Notes:**

- Auto-completes when `position_seconds / duration_seconds >= 0.90`
- Increments `watch_count` if user restarts (position < 30 seconds after previous position was higher)
- Updates `last_watched_at` timestamp on every update

---

### 4. Get Next Episode for TV Show

Intelligently determines which episode to watch next based on watch history.

```http
GET /api/profiles/:profile_id/tv_shows/:tv_show_id/next_episode
```

**Logic:**

- **Never watched**: Returns first episode of Season 1
- **In progress**: Returns the episode currently being watched
- **Completed latest**: Returns next unwatched episode in sequence

**Example Request:**

```bash
curl http://localhost:3000/api/profiles/1/tv_shows/3/next_episode
```

**Example Response:**

```json
{
  "episode": {
    "id": 15,
    "title": "Pilot",
    "season_number": 1,
    "episode_number": 1,
    "overview": "A high school chemistry teacher...",
    "still_url": "https://image.tmdb.org/t/p/w300/...",
    "file_path": "/path/to/episode.mkv",
    "tv_show_id": 3
  },
  "progress": {
    "id": 50,
    "watchable_type": "TvEpisode",
    "watchable_id": 15,
    "position_seconds": 0,
    "duration_seconds": null,
    "progress_percentage": 0.0,
    "completed": false,
    "last_watched_at": null,
    "watch_count": 0,
    "watchable": {
      "type": "tv_episode",
      "id": 15,
      "title": "Pilot",
      "season_number": 1,
      "episode_number": 1,
      "still_url": "https://image.tmdb.org/t/p/w300/...",
      "tv_show": {
        "id": 3,
        "title": "Breaking Bad",
        "poster_url": "https://image.tmdb.org/t/p/w500/..."
      }
    }
  }
}
```

**No More Episodes Response:**

```json
{
  "message": "No more episodes available"
}
```

---

## Data Models

### WatchProgress

| Field              | Type     | Description                                       |
| ------------------ | -------- | ------------------------------------------------- |
| `id`               | integer  | Primary key                                       |
| `profile_id`       | integer  | Foreign key to profiles                           |
| `watchable_type`   | string   | Polymorphic type: `Movie`, `TvEpisode`, or `Song` |
| `watchable_id`     | integer  | Polymorphic ID                                    |
| `position_seconds` | integer  | Current playback position                         |
| `duration_seconds` | integer  | Total duration (null if unknown)                  |
| `completed`        | boolean  | Auto-set to true when >= 90% watched              |
| `last_watched_at`  | datetime | Last update timestamp                             |
| `watch_count`      | integer  | Number of times restarted from beginning          |
| `created_at`       | datetime | Record creation                                   |
| `updated_at`       | datetime | Last modified                                     |

**Unique Constraint:** `[profile_id, watchable_type, watchable_id]`

---

## Integration Examples

### Video Player Integration

```javascript
// HLS video player with progress tracking
const player = new Hls();
const videoElement = document.getElementById("video");
const profileId = 1;
const movieId = 5;

// Load existing progress
async function loadProgress() {
  const response = await fetch(
    `/api/profiles/${profileId}/watch_progresses/movie/${movieId}`
  );
  const data = await response.json();

  if (data.position_seconds > 0) {
    videoElement.currentTime = data.position_seconds;
  }
}

// Save progress every 10 seconds
setInterval(async () => {
  if (!videoElement.paused) {
    await fetch(
      `/api/profiles/${profileId}/watch_progresses/movie/${movieId}`,
      {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          watch_progress: {
            position_seconds: Math.floor(videoElement.currentTime),
            duration_seconds: Math.floor(videoElement.duration),
          },
        }),
      }
    );
  }
}, 10000);

// Save on pause/exit
videoElement.addEventListener("pause", saveProgress);
window.addEventListener("beforeunload", saveProgress);
```

### Continue Watching Shelf

```javascript
// Fetch and display continue watching items
async function loadContinueWatching() {
  const response = await fetch(
    `/api/profiles/${profileId}/watch_progresses?limit=10`
  );
  const items = await response.json();

  items.forEach((item) => {
    const progress = item.progress_percentage;
    const watchable = item.watchable;

    // Render card with progress bar
    renderMediaCard({
      title: watchable.title,
      poster: watchable.poster_url || watchable.tv_show?.poster_url,
      progressPercent: progress,
      resumeTime: formatTime(item.position_seconds),
    });
  });
}
```

### TV Show Episode Navigation

```javascript
// Start watching a TV show from the right episode
async function watchShow(tvShowId) {
  const response = await fetch(
    `/api/profiles/${profileId}/tv_shows/${tvShowId}/next_episode`
  );
  const data = await response.json();

  if (data.episode) {
    // Load the episode
    const episode = data.episode;
    const progress = data.progress;

    loadEpisode(episode.id, progress.position_seconds);

    // Update UI
    document.getElementById(
      "episode-title"
    ).textContent = `S${episode.season_number}E${episode.episode_number}: ${episode.title}`;
  } else {
    alert("No more episodes available!");
  }
}
```

---

## Best Practices

### 1. **Update Frequency**

- Save progress every 5-10 seconds during active playback
- Always save on pause, seek, and before page unload
- Don't send updates when paused

### 2. **Error Handling**

```javascript
async function saveProgress(position, duration) {
  try {
    const response = await fetch(url, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        watch_progress: {
          position_seconds: position,
          duration_seconds: duration,
        },
      }),
    });

    if (!response.ok) {
      console.error("Failed to save progress:", await response.json());
      // Queue for retry
    }
  } catch (error) {
    console.error("Network error saving progress:", error);
    // Queue for retry when connection restored
  }
}
```

### 3. **Completion Threshold**

The system considers media "completed" at 90% to account for:

- Credits at the end
- Users who stop slightly before the end
- Avoid re-watching the last few seconds

### 4. **Watch Count Logic**

`watch_count` increments when:

- Previous position was > 30 seconds
- New position is < 30 seconds
- This indicates a deliberate restart, not seeking

---

## Rails Model Usage

### Profile Methods

```ruby
profile = Profile.find(1)

# Get continue watching
profile.continue_watching(limit: 10)

# Get latest episode for a show
profile.latest_episode_for(tv_show)

# Get next episode to watch
profile.next_episode_for(tv_show)

# Get or create progress for any media
progress = profile.progress_for(movie)
progress = profile.progress_for(episode)
progress = profile.progress_for(song)
```

### WatchProgress Methods

```ruby
progress = profile.progress_for(movie)

# Update position
progress.update_progress(3600, 7200)

# Check completion
progress.completed?  # => false

# Get percentage
progress.progress_percentage  # => 50.0
```

### Scopes

```ruby
# Get all in-progress items
WatchProgress.in_progress

# Get completed items
WatchProgress.completed

# Filter by type
WatchProgress.for_movies
WatchProgress.for_episodes
WatchProgress.for_songs

# Recent items
WatchProgress.recent
```

---

## Testing Examples

### RSpec

```ruby
RSpec.describe "Watch Progress API", type: :request do
  let(:profile) { create(:profile) }
  let(:movie) { create(:movie) }

  describe "PUT /api/profiles/:id/watch_progresses/:type/:id" do
    it "creates and updates watch progress" do
      put "/api/profiles/#{profile.id}/watch_progresses/movie/#{movie.id}",
        params: {
          watch_progress: {
            position_seconds: 3600,
            duration_seconds: 7200
          }
        },
        as: :json

      expect(response).to have_http_status(:success)
      expect(json_response['position_seconds']).to eq(3600)
      expect(json_response['progress_percentage']).to eq(50.0)
      expect(json_response['completed']).to be false
    end

    it "marks as completed at 90%" do
      put "/api/profiles/#{profile.id}/watch_progresses/movie/#{movie.id}",
        params: {
          watch_progress: {
            position_seconds: 6500,
            duration_seconds: 7200
          }
        },
        as: :json

      expect(json_response['completed']).to be true
    end
  end
end
```

---

## Architecture Notes

### Why Polymorphic Associations?

The `watch_progresses` table uses a **polymorphic association** (`watchable_type` + `watchable_id`) to handle all media types in a single table. This provides:

✅ **Single source of truth** for watch progress  
✅ **Unified continue watching** across all media types  
✅ **Simple API** with consistent endpoints  
✅ **Easy to extend** to new media types

### Separation of Concerns

- **`ProfileMovie/TvShow/Song`**: Controls which media a profile can access (watchlist/library)
- **`WatchProgress`**: Tracks playback state for media the profile is watching

These are intentionally separate! A profile might have access to 100 movies but only have watch progress for 10 of them.

---

## Troubleshooting

### Progress Not Saving

1. Check that `profile_id` and `watchable_id` are valid
2. Verify `watchable_type` is properly classified: `movie`, `tv_episode`, or `song` (lowercase)
3. Ensure `position_seconds` and `duration_seconds` are positive integers

### Next Episode Not Working

1. Verify episodes have correct `season_number` and `episode_number`
2. Check that TV seasons are properly associated with the show
3. Ensure episode order is correct in the database

### Continue Watching Empty

Items only appear in continue watching if:

- `position_seconds > 0`
- `completed = false`
- Check that progress updates are actually saving

---

## Future Enhancements

Potential additions to consider:

- **Analytics**: Track viewing patterns, popular content
- **Sharing**: Allow sharing watch progress between profiles
- **Sync**: Real-time sync across devices
- **Recommendations**: AI-powered "watch next" suggestions
- **Playlists**: Create custom playlists with progress tracking
- **Bookmarks**: Save specific timestamps with notes

---

## Support

For questions or issues with the Watch Progress API, please refer to:

- Main API documentation: `CLIENT_API_SPEC.md`
- Admin API documentation: `ADMIN_API.md`
- Media setup guide: `MEDIA_LIBRARY_SETUP.md`
