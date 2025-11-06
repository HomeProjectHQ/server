# API Response Changes - TMDB Metadata Enhancement

## Overview

We've added comprehensive TMDB metadata to movies and TV shows. Client models need to be updated to handle new fields.

---

## Movies API Changes

### Endpoint: `GET /api/movies/:id`

#### **Added Fields:**

```typescript
interface Movie {
  // NEW - TMDB Identifiers
  imdb_id: string | null; // e.g. "tt0137523"

  // NEW - Titles
  original_title: string | null; // Original language title

  // NEW - Ratings & Popularity
  vote_average: number | null; // TMDB rating (0-10)
  vote_count: number | null; // Number of votes
  popularity: number | null; // TMDB popularity score

  // NEW - Detailed Info (in detailed view)
  tagline: string | null; // Movie tagline
  release_date: string | null; // ISO date "1999-10-15"
  homepage: string | null; // Official website
  original_language: string | null; // ISO 639-1 code e.g. "en"
  budget: number | null; // Production budget
  revenue: number | null; // Box office revenue
}
```

#### **Removed Fields:**

```typescript
// REMOVED - was JSONB, will be replaced with relational data later
genres: any; // Previously: [{id: 18, name: "Drama"}, ...]
```

#### **Before (Old Response):**

```json
{
  "type": "movie",
  "id": 1,
  "title": "Fight Club",
  "year": "1999-10-15",
  "runtime": 139,
  "tmdb_id": 550,
  "poster_url": "https://image.tmdb.org/t/p/w500/...",
  "backdrop_url": "https://image.tmdb.org/t/p/w1280/...",
  "genres": [{ "id": 18, "name": "Drama" }],
  "overview": "A ticking-time-bomb insomniac...",
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 8340,
    "stream_url": "/api/movies/1/stream"
  }
}
```

#### **After (New Response):**

```json
{
  "type": "movie",
  "id": 1,
  "title": "Fight Club",
  "original_title": "Fight Club",
  "year": "1999-10-15",
  "runtime": 139,
  "tmdb_id": 550,
  "imdb_id": "tt0137523",
  "poster_url": "https://image.tmdb.org/t/p/w500/...",
  "backdrop_url": "https://image.tmdb.org/t/p/w1280/...",
  "vote_average": 8.433,
  "vote_count": 26280,
  "popularity": 61.416,
  "overview": "A ticking-time-bomb insomniac...",
  "tagline": "Mischief. Mayhem. Soap.",
  "release_date": "1999-10-15",
  "homepage": "http://www.foxmovies.com/movies/fight-club",
  "original_language": "en",
  "budget": 63000000,
  "revenue": 100853753,
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 8340,
    "stream_url": "/api/movies/1/stream"
  }
}
```

---

## TV Shows API Changes

### Endpoint: `GET /api/tv_shows/:id`

#### **Added Fields:**

```typescript
interface TvShow {
  // NEW - Titles
  original_name: string | null; // Original language name

  // NEW - Ratings & Popularity
  vote_average: number | null; // TMDB rating (0-10)
  vote_count: number | null; // Number of votes
  popularity: number | null; // TMDB popularity score

  // NEW - Show Metadata
  number_of_seasons: number | null; // Total seasons per TMDB
  number_of_episodes: number | null; // Total episodes per TMDB
  in_production: boolean | null; // Still airing?

  // NEW - Detailed Info (in detailed view)
  tagline: string | null; // Show tagline
  homepage: string | null; // Official website
  type: string | null; // "Scripted", "Reality", etc.
  first_air_date: string | null; // ISO date "2011-04-17"
  last_air_date: string | null; // ISO date "2019-05-19"
  original_language: string | null; // ISO 639-1 code
}
```

#### **Removed Fields:**

```typescript
// REMOVED - was JSONB, will be replaced with relational data later
genres: any; // Previously: [{id: 18, name: "Drama"}, ...]

// REMOVED - not provided by TMDB
network: string;
```

#### **Before (Old Response):**

```json
{
  "id": 229,
  "title": "Bob's Burgers",
  "year": "2011-01-09",
  "status": "Returning Series",
  "genres": [{ "id": 16, "name": "Animation" }],
  "tmdb_id": 32726,
  "poster_url": "https://image.tmdb.org/t/p/w500/...",
  "available_seasons": [1, 2, 3],
  "total_episodes": 150,
  "overview": "Bob runs a burger restaurant..."
}
```

#### **After (New Response):**

```json
{
  "type": "tv_show",
  "id": 229,
  "title": "Bob's Burgers",
  "original_name": "Bob's Burgers",
  "year": "2011-01-09",
  "status": "Returning Series",
  "tmdb_id": 32726,
  "poster_url": "https://image.tmdb.org/t/p/w500/...",
  "backdrop_url": "https://image.tmdb.org/t/p/w1280/...",
  "vote_average": 7.8,
  "vote_count": 1234,
  "popularity": 234.567,
  "number_of_seasons": 15,
  "number_of_episodes": 300,
  "in_production": true,
  "available_seasons": [1, 2, 3],
  "total_episodes": 150,
  "overview": "Bob runs a burger restaurant...",
  "tagline": "The family that grills together, stays together",
  "homepage": "https://www.fox.com/bobs-burgers/",
  "type": "Scripted",
  "first_air_date": "2011-01-09",
  "last_air_date": "2024-05-19",
  "original_language": "en"
}
```

---

## TV Episodes API Changes

### Endpoint: `GET /api/tv_episodes/:id`

**No breaking changes** - All existing fields remain. Response structure unchanged.

---

## Recommendations API - No Changes

### Endpoint: `GET /api/profiles/:id/recommendations/up_next`

**No breaking changes** - All existing fields remain.

---

## Migration Guide for Client

### TypeScript/JavaScript Models

```typescript
// OLD Movie interface
interface Movie {
  id: number;
  title: string;
  year: string;
  runtime: number;
  tmdb_id: number;
  poster_url: string | null;
  backdrop_url: string | null;
  genres: Array<{ id: number; name: string }>; // REMOVED
  overview: string;
}

// NEW Movie interface
interface Movie {
  id: number;
  title: string;
  original_title: string | null; // NEW
  year: string;
  runtime: number;
  tmdb_id: number;
  imdb_id: string | null; // NEW
  poster_url: string | null;
  backdrop_url: string | null;
  vote_average: number | null; // NEW
  vote_count: number | null; // NEW
  popularity: number | null; // NEW
  overview: string;
  tagline?: string | null; // NEW (detailed view)
  release_date?: string | null; // NEW (detailed view)
  homepage?: string | null; // NEW (detailed view)
  original_language?: string | null; // NEW (detailed view)
  budget?: number | null; // NEW (detailed view)
  revenue?: number | null; // NEW (detailed view)
}

// OLD TvShow interface
interface TvShow {
  id: number;
  title: string;
  year: string;
  status: string;
  genres: Array<{ id: number; name: string }>; // REMOVED
  tmdb_id: number;
  poster_url: string | null;
  network: string; // REMOVED
  available_seasons: number[];
  total_episodes: number;
  overview: string;
}

// NEW TvShow interface
interface TvShow {
  id: number;
  title: string;
  original_name: string | null; // NEW
  year: string;
  status: string;
  tmdb_id: number;
  poster_url: string | null;
  backdrop_url: string | null;
  vote_average: number | null; // NEW
  vote_count: number | null; // NEW
  popularity: number | null; // NEW
  number_of_seasons: number | null; // NEW
  number_of_episodes: number | null; // NEW
  in_production: boolean | null; // NEW
  available_seasons: number[];
  total_episodes: number;
  overview: string;
  tagline?: string | null; // NEW (detailed view)
  homepage?: string | null; // NEW (detailed view)
  type?: string | null; // NEW (detailed view)
  first_air_date?: string | null; // NEW (detailed view)
  last_air_date?: string | null; // NEW (detailed view)
  original_language?: string | null; // NEW (detailed view)
}
```

### Swift Models

```swift
// Movie model updates
struct Movie: Codable {
    let id: Int
    let title: String
    let originalTitle: String?        // NEW
    let year: String
    let runtime: Int
    let tmdbId: Int
    let imdbId: String?               // NEW
    let posterUrl: String?
    let backdropUrl: String?
    let voteAverage: Double?          // NEW
    let voteCount: Int?               // NEW
    let popularity: Double?           // NEW
    let overview: String
    let tagline: String?              // NEW
    let releaseDate: String?          // NEW
    let homepage: String?             // NEW
    let originalLanguage: String?     // NEW
    let budget: Int?                  // NEW
    let revenue: Int?                 // NEW

    enum CodingKeys: String, CodingKey {
        case id, title, year, runtime, overview
        case originalTitle = "original_title"
        case tmdbId = "tmdb_id"
        case imdbId = "imdb_id"
        case posterUrl = "poster_url"
        case backdropUrl = "backdrop_url"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case tagline
        case releaseDate = "release_date"
        case homepage
        case originalLanguage = "original_language"
        case budget, revenue
    }
}

// TvShow model updates
struct TvShow: Codable {
    let id: Int
    let title: String
    let originalName: String?         // NEW
    let year: String
    let status: String
    let tmdbId: Int
    let posterUrl: String?
    let backdropUrl: String?
    let voteAverage: Double?          // NEW
    let voteCount: Int?               // NEW
    let popularity: Double?           // NEW
    let numberOfSeasons: Int?         // NEW
    let numberOfEpisodes: Int?        // NEW
    let inProduction: Bool?           // NEW
    let availableSeasons: [Int]
    let totalEpisodes: Int
    let overview: String
    let tagline: String?              // NEW
    let homepage: String?             // NEW
    let type: String?                 // NEW
    let firstAirDate: String?         // NEW
    let lastAirDate: String?          // NEW
    let originalLanguage: String?     // NEW

    enum CodingKeys: String, CodingKey {
        case id, title, year, status, overview
        case originalName = "original_name"
        case tmdbId = "tmdb_id"
        case posterUrl = "poster_url"
        case backdropUrl = "backdrop_url"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case inProduction = "in_production"
        case availableSeasons = "available_seasons"
        case totalEpisodes = "total_episodes"
        case tagline, homepage, type
        case firstAirDate = "first_air_date"
        case lastAirDate = "last_air_date"
        case originalLanguage = "original_language"
    }
}
```

---

## Key Changes Summary

### Breaking Changes:

1. ❌ **`genres` field removed** from movies and TV shows (was JSONB array)
2. ❌ **`network` field removed** from TV shows (not in TMDB data)

### New Features:

1. ✅ **IMDB ID** for movies (enables deep linking)
2. ✅ **TMDB ratings** (vote_average, vote_count)
3. ✅ **Popularity scores** (for sorting/recommendations)
4. ✅ **Original titles** (for international content)
5. ✅ **Box office data** (budget/revenue for movies)
6. ✅ **Production status** (in_production for TV shows)
7. ✅ **Air dates** (first/last for TV shows)
8. ✅ **Show type** (Scripted, Reality, etc.)

---

## Recommended Client Updates

### 1. Update Models (Required)

- Add new nullable fields to Movie and TvShow models
- Remove `genres` and `network` fields

### 2. UI Enhancements (Optional)

- Display TMDB ratings with star icons
- Show "Currently Airing" badge when `in_production === true`
- Link to IMDB using `imdb_id` (format: `https://www.imdb.com/title/{imdb_id}`)
- Display taglines on detail screens
- Show budget/revenue on movie details
- Sort by popularity for "Trending" sections

### 3. Backward Compatibility

All new fields are **nullable**, so:

- Old data will have `null` for new fields
- Client can gracefully handle missing data
- No crashes if fields don't exist

---

## Rollout Schedule

1. **Phase 1 (Now)**: API updated, new fields available
2. **Phase 2 (Next)**: Run media scan to populate new fields
3. **Phase 3 (Future)**: Add genre relationships back (relational, not JSONB)

---

## Questions?

Refer to:

- Main API docs: `CLIENT_API_SPEC.md`
- Recommendations API: `RECOMMENDATIONS_API.md`
- Watch Progress API: `WATCH_PROGRESS_API.md`
