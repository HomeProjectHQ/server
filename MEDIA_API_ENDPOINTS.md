# 📡 Media Library API Endpoints

## 🎬 Movies

### List all movies

```bash
GET /api/movies

# With pagination
GET /api/movies?page=1&per_page=20

# Search by title
GET /api/movies?search=matrix

# Filter by year
GET /api/movies?year=1999
```

**Response:**

```json
{
  "movies": [
    {
      "id": 1,
      "title": "The Matrix",
      "year": 1999,
      "rating": 8.7,
      "runtime": 136,
      "genres": "Action, Science Fiction",
      "poster_url": "https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
      "backdrop_url": "https://image.tmdb.org/t/p/w1280/...",
      "file_path": "/Users/Shared/nfs/media/Movies/The Matrix (1999).mkv",
      "file_size": 2147483648,
      "tmdb_id": 603
    }
  ],
  "page": 1,
  "per_page": 50,
  "total": 42
}
```

### Get movie details

```bash
GET /api/movies/:id
```

**Response:**

```json
{
  "id": 1,
  "title": "The Matrix",
  "year": 1999,
  "rating": 8.7,
  "runtime": 136,
  "genres": "Action, Science Fiction",
  "overview": "Set in the 22nd century...",
  "poster_url": "https://image.tmdb.org/t/p/w500/...",
  "backdrop_url": "https://image.tmdb.org/t/p/w1280/...",
  "file_path": "/Users/Shared/nfs/media/Movies/The Matrix (1999).mkv",
  "file_size": 2147483648,
  "tmdb_id": 603,
  "created_at": "2025-10-21T17:30:00.000Z",
  "updated_at": "2025-10-21T17:30:00.000Z"
}
```

---

## 📺 TV Shows

### List all TV shows

```bash
GET /api/tv_shows

# With search
GET /api/tv_shows?search=breaking

# With pagination
GET /api/tv_shows?page=1&per_page=20
```

**Response:**

```json
{
  "tv_shows": [
    {
      "id": 1,
      "title": "Breaking Bad",
      "year": 2008,
      "poster_url": "https://image.tmdb.org/t/p/w500/...",
      "status": "Ended",
      "genres": "Drama, Crime",
      "tmdb_id": 1396,
      "season_count": 5,
      "episode_count": 62
    }
  ],
  "page": 1,
  "per_page": 50,
  "total": 15
}
```

### Get TV show details

```bash
GET /api/tv_shows/:id
```

**Response:**

```json
{
  "id": 1,
  "title": "Breaking Bad",
  "year": 2008,
  "poster_url": "https://image.tmdb.org/t/p/w500/...",
  "status": "Ended",
  "genres": "Drama, Crime",
  "tmdb_id": 1396,
  "season_count": 5,
  "episode_count": 62,
  "overview": "A high school chemistry teacher...",
  "network": "AMC",
  "backdrop_url": "https://image.tmdb.org/t/p/w1280/...",
  "seasons": [
    {
      "id": 1,
      "season_number": 1,
      "name": "Season 1",
      "episode_count": 7,
      "poster_url": "https://image.tmdb.org/t/p/w500/...",
      "air_date": "2008-01-20"
    }
  ]
}
```

### Get seasons for a TV show

```bash
GET /api/tv_shows/:id/seasons
```

**Response:**

```json
{
  "tv_show": {
    "id": 1,
    "title": "Breaking Bad"
  },
  "seasons": [
    {
      "id": 1,
      "season_number": 1,
      "name": "Season 1",
      "episode_count": 7,
      "poster_url": "https://image.tmdb.org/t/p/w500/...",
      "air_date": "2008-01-20"
    }
  ]
}
```

### Get episodes for a season

```bash
GET /api/tv_shows/:id/seasons/:season_number/episodes

# Example
GET /api/tv_shows/1/seasons/1/episodes
```

**Response:**

```json
{
  "tv_show": {
    "id": 1,
    "title": "Breaking Bad"
  },
  "season": {
    "id": 1,
    "season_number": 1
  },
  "episodes": [
    {
      "id": 1,
      "episode_number": 1,
      "title": "Pilot",
      "overview": "When an unassuming high school chemistry teacher...",
      "air_date": "2008-01-20",
      "runtime": 58,
      "still_url": "https://image.tmdb.org/t/p/w300/...",
      "file_path": "/Users/Shared/nfs/media/TV/Breaking Bad - S01E01.mkv",
      "file_size": 1073741824
    }
  ]
}
```

---

## 🎵 Music

### List all artists

```bash
GET /api/artists

# With search
GET /api/artists?search=floyd

# With pagination
GET /api/artists?page=1&per_page=50
```

**Response:**

```json
{
  "artists": [
    {
      "id": 1,
      "name": "Pink Floyd",
      "image_url": null,
      "album_count": 15,
      "song_count": 150
    }
  ],
  "page": 1,
  "per_page": 50,
  "total": 50
}
```

### Get artist details

```bash
GET /api/artists/:id
```

**Response:**

```json
{
  "id": 1,
  "name": "Pink Floyd",
  "image_url": null,
  "album_count": 15,
  "song_count": 150,
  "bio": null,
  "country": null,
  "albums": [
    {
      "id": 1,
      "title": "The Dark Side of the Moon",
      "year": 1973,
      "cover_url": null,
      "artist_id": 1,
      "artist_name": "Pink Floyd",
      "song_count": 10
    }
  ]
}
```

### Get albums by artist

```bash
GET /api/artists/:id/albums
```

**Response:**

```json
{
  "artist": {
    "id": 1,
    "name": "Pink Floyd"
  },
  "albums": [
    {
      "id": 1,
      "title": "The Dark Side of the Moon",
      "year": 1973,
      "cover_url": null,
      "artist_id": 1,
      "artist_name": "Pink Floyd",
      "song_count": 10
    }
  ]
}
```

### Get songs in an album

```bash
GET /api/albums/:id/songs
```

**Response:**

```json
{
  "album": {
    "id": 1,
    "title": "The Dark Side of the Moon"
  },
  "artist": {
    "id": 1,
    "name": "Pink Floyd"
  },
  "songs": [
    {
      "id": 1,
      "title": "Speak to Me",
      "track_number": 1,
      "duration": null,
      "file_path": "/Users/Shared/nfs/media/Music/Pink Floyd/Dark Side of the Moon/01 - Speak to Me.mp3",
      "file_size": 5242880,
      "album_id": 1
    }
  ]
}
```

---

## 🎥 HLS Video Streaming (Original Media Model)

These endpoints are for the HLS video streaming feature (separate from the library scanner):

### List streaming media

```bash
GET /api/media
```

### Get streaming media details

```bash
GET /api/media/:id
```

### Stream video (HLS)

```bash
GET /api/media/:id/stream
```

### Get video segments

```bash
GET /api/media/:id/stream/720p/segment_001.ts
```

---

## 📊 Example Usage

### Search for a movie

```bash
curl http://localhost:3000/api/movies?search=matrix
```

### Get Breaking Bad episodes

```bash
# 1. Find the show
curl http://localhost:3000/api/tv_shows?search=breaking

# 2. Get season 1 episodes
curl http://localhost:3000/api/tv_shows/1/seasons/1/episodes
```

### Browse music

```bash
# 1. List artists
curl http://localhost:3000/api/artists

# 2. Get artist details with albums
curl http://localhost:3000/api/artists/1

# 3. Get songs in an album
curl http://localhost:3000/api/albums/1/songs
```

---

## 🔐 Future: User-Specific Libraries

Once you assign media to users, you can add authentication and filter results:

```ruby
# In controllers
@movies = current_user.movies  # Only movies assigned to user
@tv_shows = current_user.tv_shows
@songs = current_user.songs
```

---

## 📝 Notes

- All endpoints return JSON
- Pagination defaults: `page=1`, `per_page=50`
- TMDB image URLs use CDN (fast!)
- File paths are absolute on the server
- Search is case-insensitive (ILIKE)
- No authentication required yet (all media public)

---

Happy browsing! 🎬📺🎵
