# Admin API Documentation

## User Media Access Management

Admin endpoints for managing which movies, TV shows, and songs users have access to.

---

## Movies

### Get User's Movies

Get all movies accessible by a specific user.

```http
GET /api/admin/users/:user_id/movies
```

**Response:**

```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "movies": [
    {
      "id": 1,
      "title": "The Matrix",
      "year": 1999,
      "overview": "A computer hacker learns...",
      "poster_path": "/poster.jpg",
      "backdrop_path": "/backdrop.jpg",
      "runtime": 136,
      "rating": 8.7,
      "genres": ["Action", "Sci-Fi"],
      "poster_url": "https://image.tmdb.org/t/p/w500/poster.jpg",
      "backdrop_url": "https://image.tmdb.org/t/p/w1280/backdrop.jpg"
    }
  ],
  "total": 1
}
```

### Grant Movie Access

Give a user access to a specific movie.

```http
POST /api/admin/users/:user_id/movies
Content-Type: application/json

{
  "movie_id": 123
}
```

**Response (201 Created):**

```json
{
  "message": "Movie access granted successfully",
  "movie": { ... }
}
```

**Response (200 OK) - If already exists:**

```json
{
  "message": "User already has access to this movie",
  "movie": { ... }
}
```

### Revoke Movie Access

Remove a user's access to a specific movie.

```http
DELETE /api/admin/users/:user_id/movies/:movie_id
```

**Response (200 OK):**

```json
{
  "message": "Movie access revoked successfully",
  "movie": { ... }
}
```

**Response (404 Not Found):**

```json
{
  "error": "User does not have access to this movie"
}
```

---

## TV Shows

### Get User's TV Shows

Get all TV shows accessible by a specific user.

```http
GET /api/admin/users/:user_id/tv_shows
```

**Response:**

```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "tv_shows": [
    {
      "id": 1,
      "title": "Breaking Bad",
      "year": 2008,
      "overview": "A high school chemistry teacher...",
      "poster_path": "/poster.jpg",
      "backdrop_path": "/backdrop.jpg",
      "status": "Ended",
      "network": "AMC",
      "genres": ["Drama", "Crime"],
      "poster_url": "https://image.tmdb.org/t/p/w500/poster.jpg",
      "seasons_count": 5,
      "episodes_count": 62
    }
  ],
  "total": 1
}
```

### Grant TV Show Access

Give a user access to a specific TV show (includes all seasons/episodes).

```http
POST /api/admin/users/:user_id/tv_shows
Content-Type: application/json

{
  "tv_show_id": 123
}
```

**Response (201 Created):**

```json
{
  "message": "TV show access granted successfully",
  "tv_show": { ... }
}
```

### Revoke TV Show Access

Remove a user's access to a specific TV show.

```http
DELETE /api/admin/users/:user_id/tv_shows/:tv_show_id
```

**Response (200 OK):**

```json
{
  "message": "TV show access revoked successfully",
  "tv_show": { ... }
}
```

---

## Songs

### Get User's Songs

Get all songs accessible by a specific user.

```http
GET /api/admin/users/:user_id/songs
```

**Response:**

```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "songs": [
    {
      "id": 1,
      "title": "Come Together",
      "track_number": 1,
      "duration": 259,
      "file_path": "/path/to/song.mp3",
      "file_size": 4567890,
      "album": {
        "id": 1,
        "title": "Abbey Road",
        "year": 1969,
        "cover_url": "https://..."
      },
      "artist": {
        "id": 1,
        "name": "The Beatles",
        "image_url": "https://..."
      }
    }
  ],
  "total": 1
}
```

### Grant Song Access

Give a user access to a specific song.

```http
POST /api/admin/users/:user_id/songs
Content-Type: application/json

{
  "song_id": 123
}
```

**Response (201 Created):**

```json
{
  "message": "Song access granted successfully",
  "song": { ... }
}
```

### Revoke Song Access

Remove a user's access to a specific song.

```http
DELETE /api/admin/users/:user_id/songs/:song_id
```

**Response (200 OK):**

```json
{
  "message": "Song access revoked successfully",
  "song": { ... }
}
```

---

## Error Responses

### User Not Found (404)

```json
{
  "error": "User not found"
}
```

### Movie/Show/Song Not Found (404)

```json
{
  "error": "Couldn't find Movie with 'id'=123"
}
```

### Validation Error (422)

```json
{
  "error": "Failed to grant access",
  "details": ["Validation error messages"]
}
```

---

## Examples with cURL

### Grant movie access to user

```bash
curl -X POST http://localhost:3000/api/admin/users/1/movies \
  -H "Content-Type: application/json" \
  -d '{"movie_id": 5}'
```

### Get all TV shows for user

```bash
curl http://localhost:3000/api/admin/users/1/tv_shows
```

### Revoke song access from user

```bash
curl -X DELETE http://localhost:3000/api/admin/users/1/songs/42
```

---

## Notes

- All endpoints require `:user_id` path parameter
- DELETE endpoints accept the media ID as a path parameter (`:movie_id`, `:tv_show_id`, `:song_id`)
- POST endpoints accept the media ID in the request body
- Granting access that already exists returns 200 (not an error)
- Revoking non-existent access returns 404
