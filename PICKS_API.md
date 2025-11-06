# Picks API

Personalized media recommendations powered by Apple Foundation Models.

## Overview

The Picks system generates a single, contextual media recommendation for each profile based on:
- Profile description (their taste, patterns, preferences)
- Current date/time
- Recent watch history
- Available media library

Unlike generic "up next" recommendations, Picks are **AI-curated** based on deep understanding of the profile and context.

## Setting Up a Profile

Before generating picks, a profile needs a description:

### Update Profile Description

```http
PATCH /api/admin/profiles/:id
Content-Type: application/json

{
  "profile": {
    "description": "Kate loves reality TV like Real Housewives and The Bachelor, which she has on in the background while doing laundry or dishes (usually weekday mornings around 10am). She's also obsessed with Halloween - from late September through November, she gravitates toward spooky content like Practical Magic, Hocus Pocus, and true crime documentaries. Friday nights are sacred: she and her husband watch Dateline NBC together at 11pm without fail. She avoids anything too intense or violent unless it's true crime. Comfort shows like The Office get heavy rotation when she needs to wind down."
  }
}
```

**Profile Description Best Practices:**
- Include viewing patterns (when they watch, with whom)
- Mention specific shows/genres they love
- Note seasonal preferences
- Describe viewing contexts (background vs focused)
- Mention what they avoid

## Endpoints

### Get Current Pick

Get the active personalized pick for a profile.

```http
GET /api/profiles/:profile_id/pick
```

**Response (200 OK):**
```json
{
  "id": 123,
  "caption": "Perfect Friday night comfort watch",
  "generated_at": "2025-11-06T20:30:00Z",
  "expires_at": null,
  "media": {
    "type": "movie",
    "id": 45,
    "title": "Practical Magic",
    "year": 1998,
    "overview": "Two witch sisters...",
    "poster_path": "/abc123.jpg",
    "backdrop_path": "/xyz789.jpg"
  }
}
```

**Response (404 Not Found):**
```json
{
  "message": "No current pick available. Generate one first."
}
```

### Generate New Pick

Generate a new personalized pick using the LLM workflow.

```http
POST /api/profiles/:profile_id/pick/generate
```

**Process:**
1. Expires any existing current picks
2. Launches the `generate_pick` workflow
3. LLM analyzes profile + context + library
4. Returns the newly generated pick

**Response (201 Created):**
```json
{
  "id": 124,
  "caption": "Getting into Halloween spirit 🎃",
  "generated_at": "2025-10-15T20:00:00Z",
  "expires_at": null,
  "media": {
    "type": "movie",
    "id": 67,
    "title": "Hocus Pocus",
    "year": 1993,
    "overview": "Three witches are resurrected...",
    "poster_path": "/abc456.jpg"
  },
  "reasoning": {
    "type": "Movie",
    "id": 67,
    "caption": "Getting into Halloween spirit 🎃"
  }
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "error": "Failed to generate pick",
  "details": "Profile must have a description to generate picks"
}
```

**Response (408 Request Timeout):**
```json
{
  "error": "Pick generation timed out",
  "workflow_id": 456,
  "status": "active"
}
```

### Expire Current Pick

Mark the current pick as expired (useful when user dismisses it).

```http
DELETE /api/profiles/:profile_id/pick
```

**Response (204 No Content)**

**Response (404 Not Found):**
```json
{
  "error": "No current pick to expire"
}
```

### Get Pick History

View the last 20 picks generated for this profile.

```http
GET /api/profiles/:profile_id/picks/history
```

**Response (200 OK):**
```json
[
  {
    "id": 124,
    "caption": "Getting into Halloween spirit 🎃",
    "generated_at": "2025-10-15T20:00:00Z",
    "expires_at": "2025-10-15T21:30:00Z",
    "media": {
      "type": "movie",
      "id": 67,
      "title": "Hocus Pocus"
    }
  },
  {
    "id": 123,
    "caption": "Perfect Friday night comfort watch",
    "generated_at": "2025-10-10T23:00:00Z",
    "expires_at": "2025-10-11T01:00:00Z",
    "media": {
      "type": "tv_episode",
      "id": 890,
      "title": "Dateline NBC - S32E05: Mystery at the Marina"
    }
  }
]
```

## Pick Media Types

The LLM can recommend three types of media:

### 1. Movie
A single film from your library.

```json
{
  "media": {
    "type": "movie",
    "id": 45,
    "title": "The Matrix",
    "year": 1999,
    ...
  }
}
```

### 2. TV Episode
A specific episode (great for continuing a series).

```json
{
  "media": {
    "type": "tv_episode",
    "id": 890,
    "title": "Breaking Bad - S3E7: One Minute",
    "season_number": 3,
    "episode_number": 7,
    ...
  }
}
```

### 3. TV Show
An entire series (suggesting to start or binge it).

```json
{
  "media": {
    "type": "tv_show",
    "id": 123,
    "title": "Stranger Things",
    "number_of_seasons": 4,
    ...
  }
}
```

## How It Works

### 1. Profile Analysis
The LLM reads the profile description to understand:
- Taste preferences (genres, specific shows)
- Viewing patterns (time of day, weekly rhythms)
- Context (alone vs with family, background vs focused)
- Seasonal preferences

### 2. Contextual Reasoning
The LLM considers:
- **Current time** - Tuesday 10am vs Friday 11pm
- **Recent watches** - What they've been watching lately
- **Library availability** - What's actually ready to stream

### 3. Single Best Pick
Unlike showing a carousel of options, the LLM picks **ONE** thing that's perfect right now.

### 4. Contextual Caption
The caption explains *why now*:
- "Perfect Friday night comfort watch"
- "New episode of your favorite"
- "Getting into Halloween spirit 🎃"
- "Great for background while working"

## Example Workflow

### Client App Flow

```javascript
// On app open / profile select
async function loadHeroContent(profileId) {
  try {
    // Try to get existing pick
    const pick = await fetch(`/api/profiles/${profileId}/pick`);
    if (pick.ok) {
      return await pick.json();
    }
  } catch (e) {
    // No pick exists, generate one
  }
  
  // Generate new pick
  const newPick = await fetch(
    `/api/profiles/${profileId}/pick/generate`, 
    { method: 'POST' }
  );
  
  return await newPick.json();
}

// Display the pick as hero content
const hero = await loadHeroContent(profile.id);
displayHero({
  title: hero.media.title,
  caption: hero.caption,  // "Perfect Friday night comfort watch"
  backdrop: hero.media.backdrop_path,
  onPlay: () => playMedia(hero.media)
});
```

### Smart Refresh Strategy

```javascript
// Refresh pick intelligently
async function maybeRefreshPick(profileId) {
  const pick = await getCurrentPick(profileId);
  
  // Refresh if:
  // - Pick is older than 6 hours
  // - It's a new time context (morning -> evening)
  // - User explicitly requests refresh
  
  const age = Date.now() - new Date(pick.generated_at);
  if (age > 6 * 60 * 60 * 1000) {
    return generateNewPick(profileId);
  }
  
  return pick;
}
```

## Database Schema

```ruby
create_table :picks do |t|
  t.references :profile, null: false
  t.references :pickable, polymorphic: true, null: false
  t.string :caption
  t.jsonb :reasoning, default: {}
  t.jsonb :context_snapshot, default: {}
  t.datetime :generated_at
  t.datetime :expires_at
  t.timestamps
end
```

**Fields:**
- `profile_id` - Who this pick is for
- `pickable` - Polymorphic: Movie, TvEpisode, or TvShow
- `caption` - Contextual message (20-80 chars)
- `reasoning` - Full LLM response (for debugging/analytics)
- `context_snapshot` - What was considered (date, library size, etc)
- `generated_at` - When the LLM created this
- `expires_at` - When it was dismissed/replaced (null = current)

## Model Methods

```ruby
# Get current pick for a profile
Pick.current_for(profile)
# => #<Pick id: 123, caption: "Perfect Friday night...">

# Check if pick is still valid
pick.current?
# => true

# Expire a pick
pick.expire!

# Scopes
profile.picks.current  # Active picks
profile.picks.recent   # All picks, newest first
profile.picks.movies   # Movie picks only
```

## Future Enhancements

### Collection Picks
When collections are implemented:

```json
{
  "media": {
    "type": "collection",
    "id": 789,
    "name": "Spooky Season Favorites",
    "description": "Your October essentials"
  }
}
```

### Music Picks
Extend to albums/playlists:

```json
{
  "media": {
    "type": "album",
    "id": 456,
    "title": "Rumours",
    "artist": "Fleetwood Mac"
  },
  "caption": "Chill vibes for Sunday morning"
}
```

### Multi-Client Picks
Different pick types for different clients:
- TV client: movies, episodes
- Music client: albums, playlists
- Reading client: books, articles

## See Also

- [Recommendations API](RECOMMENDATIONS_API.md) - Simple "up next" logic
- [Watch Progress API](WATCH_PROGRESS_API.md) - Tracking what users watch
- [Workflows Guide](app/workflows/README.md) - How the LLM workflow works

