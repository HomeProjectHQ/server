# Recommendations API Integration Guide

## Overview

The Recommendations API provides intelligent content suggestions to enhance the viewing experience. Currently focused on "up next" functionality, it determines what content to watch after the current media completes.

## Key Features

- 📺 **Smart Episode Sequencing**: Automatically finds the next episode in a TV show
- 🎬 **Movie Recommendations**: Suggests random movies (future: personalized based on viewing history)
- 👤 **Profile-Scoped**: Recommendations are tied to specific user profiles
- 🔄 **Seamless Binge-Watching**: Enable auto-play and continuous viewing

---

## Architecture

### Endpoints Overview

| Endpoint                                                              | Purpose                        | Scope            |
| --------------------------------------------------------------------- | ------------------------------ | ---------------- |
| `GET /api/profiles/:profile_id/recommendations/up_next?tv_episode_id` | Next episode in show           | Profile-specific |
| `GET /api/profiles/:profile_id/recommendations/up_next?movie_id`      | Recommended movie after movie  | Profile-specific |

### Design Decisions

**Why profile-scoped?**

- Different users have different viewing preferences
- Enables personalized recommendations in the future
- Respects profile access controls (kids vs adults)

**Why separate from streaming controller?**

- Streaming = file delivery (infrastructure concern)
- Recommendations = content discovery (business logic concern)
- Clean separation of concerns

---

## Endpoints

### 1. Get Up Next Recommendation

Returns the next content to watch - either the next episode in a TV show or a recommended movie.

```http
GET /api/profiles/:profile_id/recommendations/up_next?tv_episode_id=123
GET /api/profiles/:profile_id/recommendations/up_next?movie_id=456
```

**Path Parameters:**

- `profile_id`: Profile identifier

**Query Parameters (one required):**

- `tv_episode_id`: Current episode ID (for TV shows)
- `movie_id`: Current movie ID (for movies)

**Logic:**

- Finds next episode in sequence by season and episode number
- Automatically advances to next season when season ends
- Returns 404 if no more episodes available (series finale)

**Example Request (TV Episode):**

```bash
curl http://localhost:3000/api/profiles/1/recommendations/up_next?tv_episode_id=45
```

**Success Response - Next Episode (200 OK):**

```json
{
  "type": "tv_episode",
  "id": 46,
  "title": "The One After the Superbowl",
  "season_number": 2,
  "episode_number": 13,
  "overview": "Ross hunts for Marcel while Rachel tries to decide...",
  "still_url": "https://image.tmdb.org/t/p/w300/abc123.jpg",
  "air_date": "1996-01-28",
  "tv_show": {
    "id": 15,
    "title": "Friends",
    "poster_url": "https://image.tmdb.org/t/p/w500/xyz789.jpg"
  },
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 1320,
    "stream_url": "/api/tv_episodes/46/stream"
  }
}
```

**Example Request (Movie):**

```bash
curl http://localhost:3000/api/profiles/1/recommendations/up_next?movie_id=23
```

**Success Response - Next Movie (200 OK):**

```json
{
  "type": "movie",
  "id": 67,
  "title": "Inception",
  "year": 2010,
  "overview": "A thief who steals corporate secrets through dream-sharing technology...",
  "poster_url": "https://image.tmdb.org/t/p/w500/xyz789.jpg",
  "backdrop_url": "https://image.tmdb.org/t/p/w1280/abc123.jpg",
  "runtime": 148,
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 8880,
    "stream_url": "/api/movies/67/stream"
  }
}
```

**Error Responses:**

```json
// No more episodes available (404)
{
  "message": "No more episodes available"
}

// No movie recommendations (404)
{
  "message": "No recommendations available"
}

// Episode/Movie not found (404)
{
  "error": "Episode not found"
}
{
  "error": "Movie not found"
}

// Missing parameter (400)
{
  "error": "Must provide movie_id or tv_episode_id parameter"
}
```

**Recommendation Logic:**

**TV Episodes:**
- Finds next episode in sequence by season and episode number
- Automatically advances to next season when season ends
- Returns 404 if no more episodes available (series finale)

**Movies:**
- Returns a random movie (excluding current movie)
- Only suggests movies that are ready to stream (`status: 'ready'`)
- Future: Will use ML/collaborative filtering for personalized recommendations

---

## Integration Examples

### Video Player - Auto-Play Next Episode

```javascript
const profileId = 1;
const episodeId = 45;
const videoElement = document.getElementById("video");

// Fetch "up next" info when player initializes
async function loadUpNext() {
  try {
    const response = await fetch(
      `/api/profiles/${profileId}/recommendations/up_next?tv_episode_id=${episodeId}`
    );

    if (response.ok) {
      const nextEpisode = await response.json();
      showUpNextOverlay(nextEpisode);
    } else {
      console.log("Series complete - no more episodes");
    }
  } catch (error) {
    console.error("Failed to fetch next episode:", error);
  }
}

// Show "Up Next" overlay 30 seconds before end
videoElement.addEventListener("timeupdate", () => {
  const timeRemaining = videoElement.duration - videoElement.currentTime;

  if (timeRemaining <= 30 && timeRemaining > 29) {
    loadUpNext();
  }
});

function showUpNextOverlay(nextEpisode) {
  const overlay = document.createElement("div");
  overlay.className = "up-next-overlay";
  overlay.innerHTML = `
    <div class="up-next-content">
      <img src="${nextEpisode.still_url}" alt="${nextEpisode.title}">
      <div class="up-next-info">
        <h3>Up Next</h3>
        <h2>S${nextEpisode.season_number}E${nextEpisode.episode_number}: ${nextEpisode.title}</h2>
        <button onclick="playNext('${nextEpisode.id}')">Play Now</button>
        <button onclick="dismissOverlay()">Cancel</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);

  // Auto-play after 10 seconds
  setTimeout(() => {
    if (!overlay.dismissed) {
      playNext(nextEpisode.id);
    }
  }, 10000);
}

function playNext(episodeId) {
  window.location.href = `/watch/episode/${episodeId}`;
}
```

### Movie Player - Suggest Next Movie

```javascript
const profileId = 1;
const movieId = 23;

// When movie ends, show recommendation
videoElement.addEventListener("ended", async () => {
  try {
    const response = await fetch(
      `/api/profiles/${profileId}/recommendations/up_next?movie_id=${movieId}`
    );

    if (response.ok) {
      const nextMovie = await response.json();
      showMovieRecommendation(nextMovie);
    }
  } catch (error) {
    console.error("Failed to fetch movie recommendation:", error);
  }
});

function showMovieRecommendation(movie) {
  const modal = document.createElement("div");
  modal.className = "recommendation-modal";
  modal.innerHTML = `
    <div class="recommendation-card">
      <img src="${movie.backdrop_url}" alt="${movie.title}">
      <div class="recommendation-details">
        <h2>${movie.title} (${movie.year})</h2>
        <p>${movie.overview}</p>
        <div class="recommendation-actions">
          <button onclick="watchMovie(${movie.id})">
            Watch Now
          </button>
          <button onclick="closeModal()">
            Back to Browse
          </button>
        </div>
      </div>
    </div>
  `;
  document.body.appendChild(modal);
}
```

### React Component Example

```jsx
import { useState, useEffect } from "react";

function UpNextOverlay({ profileId, episodeId, currentTime, duration }) {
  const [nextEpisode, setNextEpisode] = useState(null);
  const [showOverlay, setShowOverlay] = useState(false);

  useEffect(() => {
    const timeRemaining = duration - currentTime;

    // Show overlay 30 seconds before end
    if (timeRemaining <= 30 && timeRemaining > 0 && !nextEpisode) {
      fetchUpNext();
    }
  }, [currentTime]);

  async function fetchUpNext() {
    try {
      const response = await fetch(
        `/api/profiles/${profileId}/recommendations/up_next?tv_episode_id=${episodeId}`
      );

      if (response.ok) {
        const data = await response.json();
        setNextEpisode(data);
        setShowOverlay(true);
      }
    } catch (error) {
      console.error("Failed to fetch next episode:", error);
    }
  }

  if (!showOverlay || !nextEpisode) return null;

  return (
    <div className="up-next-overlay">
      <div className="up-next-card">
        <img
          src={nextEpisode.still_url}
          alt={nextEpisode.title}
          className="episode-thumbnail"
        />
        <div className="episode-info">
          <p className="label">Up Next</p>
          <h3 className="episode-title">
            S{nextEpisode.season_number}E{nextEpisode.episode_number}:{" "}
            {nextEpisode.title}
          </h3>
          <p className="show-title">{nextEpisode.tv_show.title}</p>
        </div>
        <div className="actions">
          <button
            onClick={() =>
              (window.location.href = `/watch/episode/${nextEpisode.id}`)
            }
            className="play-button">
            Play Now
          </button>
          <button
            onClick={() => setShowOverlay(false)}
            className="cancel-button">
            Cancel
          </button>
        </div>
      </div>
    </div>
  );
}
```

---

## Related Endpoints

### Get Episode Details

Before showing the video player, fetch full episode details:

```http
GET /api/tv_episodes/:id
```

**Response:**

```json
{
  "type": "tv_episode",
  "id": 45,
  "title": "The One with the Prom Video",
  "season_number": 2,
  "episode_number": 12,
  "overview": "Monica's parents bring boxes...",
  "still_url": "https://image.tmdb.org/t/p/w300/abc.jpg",
  "air_date": "1996-02-01",
  "tv_show": {
    "id": 15,
    "title": "Friends",
    "poster_url": "https://image.tmdb.org/t/p/w500/xyz.jpg",
    "backdrop_url": "https://image.tmdb.org/t/p/w1280/def.jpg"
  },
  "tv_season": {
    "id": 3,
    "season_number": 2,
    "name": "Season 2"
  },
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 1320,
    "stream_url": "/api/tv_episodes/45/stream"
  }
}
```

### Get Movie Details

```http
GET /api/movies/:id
```

**Response:**

```json
{
  "type": "movie",
  "id": 23,
  "title": "The Matrix",
  "year": 1999,
  "overview": "A computer hacker learns from mysterious rebels...",
  "tagline": "Welcome to the Real World",
  "runtime": 136,
  "poster_url": "https://image.tmdb.org/t/p/w500/xyz.jpg",
  "backdrop_url": "https://image.tmdb.org/t/p/w1280/abc.jpg",
  "release_date": "1999-03-31",
  "vote_average": 8.7,
  "vote_count": 25432,
  "genres": ["Action", "Science Fiction"],
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 8160,
    "stream_url": "/api/movies/23/stream"
  }
}
```

---

## Workflow: Complete Viewing Experience

### TV Show Binge-Watching Flow

```
1. User clicks "Watch Show"
   ↓
2. GET /api/profiles/:profile_id/tv_shows/:tv_show_id/next_episode
   (from Watch Progress API - finds where they left off)
   ↓
3. GET /api/tv_episodes/:id
   (get full episode details)
   ↓
4. Player loads: GET /api/tv_episodes/:id/stream
   ↓
5. 30 seconds before end: GET /api/profiles/:profile_id/tv_episodes/:id/up_next
   (fetch next episode)
   ↓
6. Show "Up Next" overlay with countdown
   ↓
7. Auto-play or user clicks "Play Now"
   ↓
8. Loop back to step 3 with new episode
```

### Movie Watching Flow

```
1. User clicks "Watch Movie"
   ↓
2. GET /api/movies/:id
   (get full movie details)
   ↓
3. Player loads: GET /api/movies/:id/stream
   ↓
4. Movie ends
   ↓
5. GET /api/profiles/:profile_id/movies/:id/up_next
   (fetch recommended next movie)
   ↓
6. Show recommendation modal
   ↓
7. User decides: Watch recommendation or browse library
```

---

## Best Practices

### 1. Prefetch Up Next Content

Load the "up next" info early to ensure smooth transitions:

```javascript
// Start prefetching 60 seconds before end
if (timeRemaining <= 60 && !prefetched) {
  prefetchUpNext();
}

// Show overlay 30 seconds before end
if (timeRemaining <= 30) {
  showUpNextOverlay();
}
```

### 2. Graceful Degradation

Always handle the case where no recommendations are available:

```javascript
async function fetchUpNext() {
  try {
    const response = await fetch(upNextUrl);

    if (response.status === 404) {
      // No more episodes or no recommendations
      showCompletionScreen();
      return null;
    }

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error("Failed to fetch recommendation:", error);
    // Fall back to browse screen
    showBrowsePrompt();
    return null;
  }
}
```

### 3. User Control

Always give users control over auto-play:

```javascript
// User preferences
const userPrefs = {
  autoPlayNextEpisode: true,
  autoPlayCountdown: 10, // seconds
};

function showUpNextOverlay(nextEpisode) {
  // Show overlay
  renderOverlay(nextEpisode);

  if (userPrefs.autoPlayNextEpisode) {
    startCountdown(userPrefs.autoPlayCountdown, () => {
      playNext(nextEpisode.id);
    });
  }
}

// Allow cancellation
function cancelAutoPlay() {
  clearCountdown();
  hideOverlay();
}
```

### 4. Combine with Watch Progress

Track progress while showing recommendations:

```javascript
// Update watch progress for current episode
await fetch(
  `/api/profiles/${profileId}/watch_progresses/tv_episode/${episodeId}`,
  {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      watch_progress: {
        position_seconds: videoElement.currentTime,
        duration_seconds: videoElement.duration,
      },
    }),
  }
);

// Then show next episode
const nextEpisode = await fetchUpNext();
```

---

## Future Enhancements

### Planned Features

**Personalized Movie Recommendations:**

```json
{
  "type": "movie",
  "id": 67,
  "title": "Inception",
  "recommendation_reason": "Because you watched The Matrix",
  "match_score": 0.92,
  ...
}
```

**Similar Items Endpoint:**

```http
GET /api/profiles/:profile_id/movies/:movie_id/similar
```

**Featured Content:**

```http
GET /api/profiles/:profile_id/recommendations/featured
```

**Contextual Recommendations:**

- Time-based (shorter content for late night)
- Mood-based (action, comedy, drama)
- Social (what friends are watching)

---

## Data Flow Architecture

### Current Episode → Next Episode

```
TvEpisode (current)
  ↓
tv_season_id, episode_number
  ↓
Query: JOIN tv_seasons
       WHERE same tv_show
       AND (higher season OR higher episode in same season)
       ORDER BY season, episode
       LIMIT 1
  ↓
TvEpisode (next)
```

### Current Movie → Recommended Movie

```
Movie (current)
  ↓
Exclude current.id
Filter by status = 'ready'
Filter by hls_path != null
  ↓
Random() [Future: ML Model]
  ↓
Movie (recommendation)
```

---

## Performance Considerations

### Database Indexes

Ensure these indexes exist for optimal performance:

```ruby
# TV Episodes - for next episode lookup
add_index :tv_episodes, [:tv_season_id, :episode_number]
add_index :tv_seasons, [:tv_show_id, :season_number]

# Movies - for recommendation filtering
add_index :movies, [:status, :hls_path]
```

### Caching Strategy

Consider caching recommendations for frequently watched content:

```ruby
# In RecommendationsController
def episode_up_next
  cache_key = "up_next/episode/#{params[:episode_id]}"

  @next_episode = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
    # ... query logic
  end
end
```

---

## Error Handling

### Common Errors

| Error                          | Status | Cause                 | Solution               |
| ------------------------------ | ------ | --------------------- | ---------------------- |
| `Profile not found`            | 404    | Invalid profile_id    | Verify profile exists  |
| `Episode not found`            | 404    | Invalid episode_id    | Check episode ID       |
| `Movie not found`              | 404    | Invalid movie_id      | Check movie ID         |
| `No more episodes available`   | 404    | Series finale reached | Show completion screen |
| `No recommendations available` | 404    | No ready movies       | Prompt library browse  |

### Error Response Format

All errors follow consistent format:

```json
{
  "error": "Human-readable error message"
}
```

Or for "end of content":

```json
{
  "message": "Informational message"
}
```

---

## Testing

### RSpec Examples

```ruby
RSpec.describe "Recommendations API", type: :request do
  let(:profile) { create(:profile) }
  let(:tv_show) { create(:tv_show) }
  let(:season_1) { create(:tv_season, tv_show: tv_show, season_number: 1) }
  let(:episode_1) { create(:tv_episode, tv_season: season_1, episode_number: 1) }
  let(:episode_2) { create(:tv_episode, tv_season: season_1, episode_number: 2) }

  describe "GET /api/profiles/:id/tv_episodes/:id/up_next" do
    it "returns next episode in sequence" do
      get "/api/profiles/#{profile.id}/tv_episodes/#{episode_1.id}/up_next"

      expect(response).to have_http_status(:success)
      expect(json_response['id']).to eq(episode_2.id)
      expect(json_response['episode_number']).to eq(2)
    end

    it "returns 404 when no more episodes" do
      get "/api/profiles/#{profile.id}/tv_episodes/#{episode_2.id}/up_next"

      expect(response).to have_http_status(:not_found)
      expect(json_response['message']).to eq('No more episodes available')
    end
  end

  describe "GET /api/profiles/:id/movies/:id/up_next" do
    let(:movie_1) { create(:movie, status: 'ready', hls_path: '/path/to/hls') }
    let(:movie_2) { create(:movie, status: 'ready', hls_path: '/path/to/hls') }

    it "returns a different movie recommendation" do
      get "/api/profiles/#{profile.id}/movies/#{movie_1.id}/up_next"

      expect(response).to have_http_status(:success)
      expect(json_response['id']).not_to eq(movie_1.id)
      expect(json_response['type']).to eq('movie')
    end
  end
end
```

---

## Support

For questions or issues with the Recommendations API, please refer to:

- Watch Progress API: `WATCH_PROGRESS_API.md`
- Main API documentation: `CLIENT_API_SPEC.md`
- Admin API documentation: `ADMIN_API.md`
- Media setup guide: `MEDIA_LIBRARY_SETUP.md`
