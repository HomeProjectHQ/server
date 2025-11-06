# Featured Items API - TV Client Integration Guide

## Overview

The Featured Items API provides AI-curated, contextual media recommendations for your TV app. Featured items are personalized for each profile based on their viewing preferences, patterns, and current context (time of day, season, etc.).

## What is the Epic Stage?

**Epic Stage** is the hero placement in your TV app - think Netflix's main hero banner when you first log in. It's the prime real estate at the top of the home screen that showcases a single, highly personalized recommendation with:

- Full-screen backdrop image
- Title and metadata
- Contextual caption explaining why this is perfect right now
- Prominent "Play" and "More Info" buttons

Unlike Netflix which shows one static hero item, our system generates multiple options but the client should display only the first one for now.

---

## Quick Start

### Get Epic Stage Item

```http
GET /api/profiles/:profile_id/featured?placement=epic_stage
```

**Example Request:**

```bash
curl http://localhost:3000/api/profiles/1/featured?placement=epic_stage
```

**Example Response:**

```json
[
  {
    "id": 123,
    "caption": "Perfect Friday night comfort watch",
    "placements": ["epic_stage"],
    "generated_at": "2025-11-06T20:30:00Z",
    "expires_at": null,
    "media": {
      "type": "movie",
      "id": 45,
      "title": "Practical Magic",
      "year": 1998,
      "overview": "Two witch sisters, raised by their eccentric aunts...",
      "runtime": 104,
      "poster_path": "/poster123.jpg",
      "backdrop_path": "/backdrop456.jpg",
      "genres": [
        { "id": 14, "name": "Fantasy" },
        { "id": 10749, "name": "Romance" }
      ],
      "rating": "PG-13",
      "vote_average": 6.4,
      "hls_path": "/storage/movies/45/master.m3u8"
    }
  }
]
```

---

## Client Implementation

### Display Logic

**⚠️ IMPORTANT:** For now, always use the **first item** (`[0]`) from the response array:

```javascript
// Fetch epic stage item
const response = await fetch("/api/profiles/1/featured?placement=epic_stage");
const items = await response.json();

// Always use first item (for now)
const epicStageItem = items[0];

// Display in hero section
displayEpicStage({
  title: epicStageItem.media.title,
  caption: epicStageItem.caption,
  backdrop: epicStageItem.media.backdrop_path,
  year: epicStageItem.media.year,
  genres: epicStageItem.media.genres.map((g) => g.name),
  overview: epicStageItem.media.overview,
  onPlay: () => playMedia(epicStageItem.media),
});
```

**Why only the first item?** The API currently returns multiple items for future flexibility (carousels, rotations, etc.), but the epic stage should only show one. We'll add proper filtering server-side in a future update.

---

## API Reference

### Endpoint

```
GET /api/profiles/:profile_id/featured?placement=epic_stage
```

**Path Parameters:**

- `profile_id` (required) - The profile ID to get featured items for

**Query Parameters:**

- `placement` (required) - Filter by placement tag. Use `epic_stage` for hero section.

### Response Format

Returns an array of featured item objects.

#### Featured Item Object

| Field          | Type          | Description                                                             |
| -------------- | ------------- | ----------------------------------------------------------------------- |
| `id`           | Integer       | Featured item ID                                                        |
| `caption`      | String        | Contextual caption (20-80 chars) explaining why this is recommended now |
| `placements`   | Array<String> | Placement tags (e.g., `["epic_stage"]`)                                 |
| `generated_at` | DateTime      | When this item was generated                                            |
| `expires_at`   | DateTime      | When this item expires (null = still current)                           |
| `media`        | Object        | The recommended media content (see below)                               |

#### Media Object (Polymorphic)

The `media` object will be one of three types:

##### 1. Movie

```json
{
  "type": "movie",
  "id": 45,
  "title": "Practical Magic",
  "year": 1998,
  "overview": "Two witch sisters...",
  "runtime": 104,
  "poster_path": "/abc123.jpg",
  "backdrop_path": "/xyz789.jpg",
  "genres": [
    { "id": 14, "name": "Fantasy" },
    { "id": 10749, "name": "Romance" }
  ],
  "rating": "PG-13",
  "vote_average": 6.4,
  "vote_count": 1234,
  "release_date": "1998-10-16",
  "hls_path": "/storage/movies/45/master.m3u8",
  "status": "ready"
}
```

##### 2. TV Show

```json
{
  "type": "tv_show",
  "id": 123,
  "title": "Breaking Bad",
  "year": 2008,
  "overview": "A high school chemistry teacher...",
  "poster_path": "/poster.jpg",
  "backdrop_path": "/backdrop.jpg",
  "genres": [
    { "id": 18, "name": "Drama" },
    { "id": 80, "name": "Crime" }
  ],
  "vote_average": 9.5,
  "number_of_seasons": 5,
  "number_of_episodes": 62,
  "status": "Ended",
  "first_air_date": "2008-01-20",
  "last_air_date": "2013-09-29"
}
```

**Note:** For TV shows, you'll need to make an additional API call to get the specific episode to play (typically the next unwatched episode).

##### 3. TV Episode

```json
{
  "type": "tv_episode",
  "id": 890,
  "title": "One Minute",
  "season_number": 3,
  "episode_number": 7,
  "overview": "Hank's increasing volatility...",
  "air_date": "2010-05-02",
  "runtime": 47,
  "still_path": "/episode_still.jpg",
  "hls_path": "/storage/episodes/890/master.m3u8",
  "status": "ready",
  "tv_show": {
    "id": 123,
    "title": "Breaking Bad",
    "backdrop_path": "/backdrop.jpg"
  }
}
```

**Note:** When the type is `tv_episode`, use the episode's `still_path` or fall back to the show's `backdrop_path` for the epic stage background.

---

## Response Status Codes

| Code            | Description                                            |
| --------------- | ------------------------------------------------------ |
| `200 OK`        | Featured items found and returned                      |
| `404 Not Found` | No current featured items available (need to generate) |
| `404 Not Found` | Profile not found                                      |

### 404 Response

```json
{
  "message": "No current featured items available. Generate some first."
}
```

---

## Generating Featured Items

Featured items are generated by an LLM workflow that analyzes:

- Profile's viewing preferences and patterns
- Current date/time context
- Recent watch history
- Available library content

### Trigger Generation

```http
POST /api/profiles/:profile_id/featured/generate
```

**Optional Body:**

```json
{
  "placements": ["epic_stage"]
}
```

**Response:** Returns the newly generated items (status 201).

**Note:** Generation typically takes 5-10 seconds as it involves LLM processing.

---

## Client Integration Patterns

### On App Launch

```javascript
async function loadEpicStage(profileId) {
  try {
    const response = await fetch(
      `/api/profiles/${profileId}/featured?placement=epic_stage`
    );

    if (response.ok) {
      const items = await response.json();
      return items[0]; // Use first item
    }

    // No items exist, trigger generation
    if (response.status === 404) {
      await generateEpicStage(profileId);
      return await loadEpicStage(profileId); // Retry
    }
  } catch (error) {
    console.error("Failed to load epic stage:", error);
    return null;
  }
}

async function generateEpicStage(profileId) {
  const response = await fetch(`/api/profiles/${profileId}/featured/generate`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ placements: ["epic_stage"] }),
  });

  if (!response.ok) {
    throw new Error("Failed to generate epic stage items");
  }

  return await response.json();
}
```

### Epic Stage Component

```jsx
function EpicStage({ profileId }) {
  const [item, setItem] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadEpicStage(profileId).then((item) => {
      setItem(item);
      setLoading(false);
    });
  }, [profileId]);

  if (loading) return <EpicStageSkeleton />;
  if (!item) return <EpicStageFallback />;

  const media = item.media;
  const backdrop = media.backdrop_path || media.tv_show?.backdrop_path;

  return (
    <div className="epic-stage" style={{ backgroundImage: `url(${backdrop})` }}>
      <div className="content">
        <h1>{media.title}</h1>
        <p className="caption">{item.caption}</p>

        <div className="metadata">
          {media.year && <span>{media.year}</span>}
          {media.runtime && <span>{media.runtime}m</span>}
          {media.genres && (
            <span>{media.genres.map((g) => g.name).join(" • ")}</span>
          )}
        </div>

        <p className="overview">{media.overview}</p>

        <div className="actions">
          <button onClick={() => playMedia(media)}>▶ Play</button>
          <button onClick={() => showInfo(media)}>ℹ More Info</button>
        </div>
      </div>
    </div>
  );
}
```

### Handling Different Media Types

```javascript
function playMedia(media) {
  switch (media.type) {
    case "movie":
      // Play movie directly
      player.load(media.hls_path);
      break;

    case "tv_episode":
      // Play episode directly
      player.load(media.hls_path);
      break;

    case "tv_show":
      // Need to fetch next episode
      fetchNextEpisode(media.id).then((episode) => {
        player.load(episode.hls_path);
      });
      break;
  }
}

async function fetchNextEpisode(tvShowId) {
  const response = await fetch(
    `/api/profiles/${profileId}/tv_shows/${tvShowId}/next_episode`
  );
  return await response.json();
}
```

---

## Refresh Strategy

### When to Refresh

Refresh epic stage items when:

- **Time-based:** Every 6-12 hours
- **Context change:** Morning → Evening transition
- **User action:** User dismisses the current item
- **Empty state:** No current items available

### Manual Refresh

```javascript
async function refreshEpicStage(profileId) {
  // Expire current items for this placement
  await fetch(`/api/profiles/${profileId}/featured?placement=epic_stage`, {
    method: "DELETE",
  });

  // Generate new items
  return await generateEpicStage(profileId);
}
```

---

## Error Handling

### Profile Without Prompt

If a profile doesn't have an AI prompt configured, generation will fail:

```json
{
  "error": "Failed to generate featured items",
  "details": "Profile must have a prompt to generate featured items"
}
```

**Solution:** Ensure profiles have their `prompt` field set with viewing preferences before generating featured items.

### No Available Content

If the profile has no accessible movies or TV shows, featured items cannot be generated.

**Solution:** Assign content to the profile via the admin API first.

---

## Future Enhancements

### Coming Soon

1. **Single Item Response** - API will return only one item when `placement=epic_stage` instead of array
2. **Auto-rotation** - Multiple items will rotate automatically in the UI
3. **Carousel Placement** - Additional placements like `carousel`, `trending`, `continue_watching`
4. **Real-time Updates** - WebSocket support for live item updates
5. **A/B Testing** - Track which featured items get the most engagement

---

## See Also

- [Watch Progress API](WATCH_PROGRESS_API.md) - Track viewing progress
- [Recommendations API](RECOMMENDATIONS_API.md) - Simple "up next" recommendations
- [Streaming API](MEDIA_API_ENDPOINTS.md) - HLS streaming endpoints
