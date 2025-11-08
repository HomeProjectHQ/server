# API Migration Guide - Streaming Fields Refactor

**Date:** November 7, 2025  
**Impact:** Breaking changes to JSON API responses

## Overview

We've renamed HLS-specific fields to be format-agnostic, allowing for future streaming format flexibility. This affects all media streaming endpoints.

## Breaking Changes

### 1. Response Object Renamed: `hls` → `stream`

All streaming-related data is now nested under `stream` instead of `hls`.

**Affected Endpoints:**
- `GET /api/profiles/:profile_id/movies/:movie_id`
- `GET /api/profiles/:profile_id/tv_shows/:tv_show_id/seasons/:season_number/episodes/:episode_number`
- `GET /api/profiles/:profile_id/recommendations` (movie and episode objects)

### 2. Field Renames

| Old Field Name | New Field Name | Description |
|---------------|----------------|-------------|
| `hls_duration` | `stream_duration` | Duration of the transcoded stream in seconds |
| `hls_qualities` | `stream_qualities` | Array of available quality variants |

---

## Migration Examples

### Movies Response

#### ❌ Old Response
```json
{
  "type": "movie",
  "id": 123,
  "title": "Example Movie",
  "year": 2024,
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 7200,
    "stream_url": "/api/movies/123/stream"
  }
}
```

#### ✅ New Response
```json
{
  "type": "movie",
  "id": 123,
  "title": "Example Movie",
  "year": 2024,
  "stream": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 7200,
    "stream_url": "/api/movies/123/stream"
  }
}
```

### TV Episode Response

#### ❌ Old Response
```json
{
  "type": "tv_episode",
  "id": 456,
  "title": "Pilot",
  "episode_number": 1,
  "hls": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 2700,
    "stream_url": "/api/tv_episodes/456/stream"
  }
}
```

#### ✅ New Response
```json
{
  "type": "tv_episode",
  "id": 456,
  "title": "Pilot",
  "episode_number": 1,
  "stream": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 2700,
    "stream_url": "/api/tv_episodes/456/stream"
  }
}
```

### Recommendations Response

Both `movie_up_next` and `episode_up_next` objects now use `stream` instead of `hls`.

---

## Client Code Updates

### JavaScript/TypeScript

#### Before
```typescript
// Old code
const movie = await fetchMovie(movieId);
const duration = movie.hls.duration;
const qualities = movie.hls.available_qualities;
const streamUrl = movie.hls.stream_url;

if (movie.hls.status === 'ready') {
  playVideo(streamUrl);
}
```

#### After
```typescript
// New code
const movie = await fetchMovie(movieId);
const duration = movie.stream.duration;
const qualities = movie.stream.available_qualities;
const streamUrl = movie.stream.stream_url;

if (movie.stream.status === 'ready') {
  playVideo(streamUrl);
}
```

### Swift

#### Before
```swift
// Old code
struct MovieResponse: Codable {
    let id: Int
    let title: String
    let hls: HLSInfo
}

struct HLSInfo: Codable {
    let status: String
    let availableQualities: [String]
    let duration: Int
    let streamUrl: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case availableQualities = "available_qualities"
        case duration
        case streamUrl = "stream_url"
    }
}
```

#### After
```swift
// New code
struct MovieResponse: Codable {
    let id: Int
    let title: String
    let stream: StreamInfo  // Renamed from hls to stream
}

struct StreamInfo: Codable {  // Renamed from HLSInfo
    let status: String
    let availableQualities: [String]
    let duration: Int
    let streamUrl: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case availableQualities = "available_qualities"
        case duration
        case streamUrl = "stream_url"
    }
}
```

---

## What Hasn't Changed

### ✅ These remain the same:
- **Stream URLs**: `/api/movies/:id/stream` and `/api/tv_episodes/:id/stream` (no change to URL structure)
- HLS playlist format and structure
- Quality variant naming (`1080p`, `720p`, etc.)
- Status values (`pending`, `processing`, `ready`, `failed`)
- Authentication and authorization
- HTTP methods and status codes

**Note:** While the URLs haven't changed, streaming is now handled directly by the `movies` and `tv_episodes` controllers instead of a separate `streaming` controller. This is an internal refactor and shouldn't affect clients.

---

## Timeline

- **Effective Date:** After migration on November 7, 2025
- **Deprecation Period:** None - this is an immediate breaking change
- **Support:** Old field names are no longer supported

---

## Testing Checklist

Before deploying your client updates:

- [ ] Update all references to `.hls` to `.stream`
- [ ] Update type definitions/models
- [ ] Test movie playback
- [ ] Test TV episode playback
- [ ] Test recommendations flow
- [ ] Verify error handling for `status !== 'ready'`
- [ ] Test quality switching

---

## Support

If you encounter issues or have questions:
- Check this migration guide
- Review your client's API request/response logs
- Contact the API team

---

## Example cURL Requests

### Get Movie Details
```bash
curl -X GET "https://api.example.com/api/profiles/1/movies/123" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response includes `stream` object:**
```json
{
  "id": 123,
  "title": "Example Movie",
  "stream": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 7200,
    "stream_url": "/api/movies/123/stream"
  }
}
```

### Get Episode Details
```bash
curl -X GET "https://api.example.com/api/profiles/1/tv_shows/45/seasons/1/episodes/1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response includes `stream` object:**
```json
{
  "id": 789,
  "title": "Pilot",
  "episode_number": 1,
  "stream": {
    "status": "ready",
    "available_qualities": ["1080p", "720p"],
    "duration": 2700,
    "stream_url": "/api/tv_episodes/789/stream"
  }
}
```

