# 📚 Media Library Scanner - Setup Guide

## Overview

Your Rails app now includes a comprehensive media library scanner that:

- ✅ Scans `/Volume/media` for Movies, TV Shows, and Music
- ✅ Fetches metadata from TMDB (The Movie Database)
- ✅ Creates database records with full metadata
- ✅ Supports multi-user library with associations
- ✅ Leaves media unassigned to users (for now)

---

## 🗂️ Directory Structure Expected

```
/Volume/media/
├── Movies/
│   ├── The Matrix (1999).mkv
│   ├── Inception (2010).mp4
│   └── ...
├── TV/
│   ├── Breaking Bad/
│   │   ├── Season 01/
│   │   │   ├── Breaking Bad - S01E01 - Pilot.mkv
│   │   │   ├── Breaking Bad - S01E02 - Cat's in the Bag.mkv
│   │   │   └── ...
│   │   └── ...
│   └── The Office (US)/
│       ├── The Office (US) - S01E01.mkv
│       └── ...
└── Music/
    ├── Pink Floyd/
    │   ├── Dark Side of the Moon/
    │   │   ├── 01 - Speak to Me.mp3
    │   │   ├── 02 - Breathe.mp3
    │   │   └── ...
    │   └── ...
    └── ...
```

---

## 🔧 Setup

### 1. Get TMDB API Key (FREE!)

1. Go to https://www.themoviedb.org/settings/api
2. Sign up for a free account
3. Request an API key (free, instant approval)
4. Copy your API key

### 2. Set Environment Variable

```bash
# Add to your shell profile (~/.zshrc or ~/.bash_profile)
export TMDB_API_KEY="your_api_key_here"

# Or set temporarily
export TMDB_API_KEY="your_api_key_here"
```

### 3. Make Sure Solid Queue is Running

```bash
bin/jobs
```

---

## 🚀 Usage

### Scan Your Media Library

```bash
# Scan default location (/Volume/media)
bin/rails media:scan

# Scan custom location
bin/rails media:scan MEDIA_ROOT=/path/to/your/media
```

### View Statistics

```bash
bin/rails media:stats
```

Output:

```
============================================================
Media Library Statistics
============================================================

Movies:      42
TV Shows:    15
  Seasons:   87
  Episodes:  1,234
Artists:     50
Albums:      200
Songs:       2,500

Users:       0
============================================================
```

### Clear Library (keeps files intact)

```bash
bin/rails media:clear
```

---

## 📊 Database Models

### Movies

```ruby
Movie.all                    # All movies
Movie.by_year(2020)          # Movies from 2020
Movie.recent                 # Recently added

movie = Movie.first
movie.title                  # "The Matrix"
movie.year                   # 1999
movie.poster_url             # Full TMDB poster URL
movie.backdrop_url           # Full TMDB backdrop URL
movie.users                  # Users who have access (empty for now)
```

### TV Shows

```ruby
TvShow.all                   # All TV shows

show = TvShow.first
show.tv_seasons              # All seasons
show.tv_episodes             # All episodes across seasons
show.users                   # Users who have access

episode = TvEpisode.first
episode.title                # "Pilot"
episode.tv_season            # Season 1
episode.tv_show              # Breaking Bad
episode.still_url            # Episode thumbnail
```

### Music

```ruby
Artist.all                   # All artists
Album.all                    # All albums
Song.all                     # All songs

artist = Artist.first
artist.albums                # All albums by artist
artist.songs                 # All songs by artist

song = Song.first
song.title                   # "Speak to Me"
song.album                   # Dark Side of the Moon
song.artist                  # Pink Floyd
song.users                   # Users who have access
```

---

## 👥 User Associations (Multi-User Library)

### Assign Media to Users

```ruby
# Create users
joe = User.create!(name: "Joe", email: "joe@example.com")
kate = User.create!(name: "Kate", email: "kate@example.com")
kids = User.create!(name: "Kids Profile", email: "kids@example.com")

# Assign movies
matrix = Movie.find_by(title: "The Matrix")
matrix.users << joe
matrix.users << kate
matrix.users << kids

# Assign TV shows
breaking_bad = TvShow.find_by(title: "Breaking Bad")
breaking_bad.users << joe  # Only Joe can watch

# Assign songs
song = Song.find_by(title: "Speak to Me")
song.users << joe
song.users << kate

# Query user's library
joe.movies                   # All movies Joe can watch
joe.tv_shows                 # All TV shows Joe can watch
joe.songs                    # All songs Joe can listen to
```

---

## 🎯 File Name Patterns Recognized

### Movies

- `The Matrix (1999).mp4`
- `Inception.2010.1080p.BluRay.mkv`
- `Movie Name 2020.mkv`

### TV Shows

- `Breaking Bad - S01E01 - Pilot.mkv`
- `The Office (US) - S01E03 - Health Care.mkv`
- `Game.of.Thrones.S08E06.720p.mkv`
- `Show Name 1x01.mp4`

### Music

- `01 - Song Title.mp3`
- `Artist - Album - 03 - Track Name.flac`

Directory structure: `Music/Artist Name/Album Name/track.mp3`

---

## 🔍 What Gets Stored

### From TMDB (Movies & TV)

- Title
- Year
- Overview/Description
- Poster image URL
- Backdrop image URL
- Runtime
- Rating
- Genres
- Episode stills (thumbnails)
- Air dates

### From File System

- File path
- File size
- Parsed metadata from filename

---

## 🎬 Example Workflow

```bash
# 1. Set up TMDB API key
export TMDB_API_KEY="abc123..."

# 2. Start job processor
bin/jobs

# 3. Run scan (in another terminal)
bin/rails media:scan

# 4. Monitor progress
tail -f log/development.log

# Output:
# Scanning movies in /Volume/media/Movies
# Found 42 movie files
# Processing movie: The Matrix (1999)
# Created movie: The Matrix (603)
# Processing movie: Inception (2010)
# Created movie: Inception (27205)
# ...

# 5. Check stats
bin/rails media:stats

# 6. Use in Rails console
bin/rails console
> Movie.count
# => 42
> Movie.first.title
# => "The Matrix"
> Movie.first.poster_url
# => "https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg"
```

---

## 📝 Notes

### Metadata Quality

- **Movies**: Excellent (TMDB has comprehensive data)
- **TV Shows**: Excellent (TMDB has episode-level data)
- **Music**: Basic (file system only, no API integration yet)

### Performance

- Scans run as background jobs (Solid Queue)
- Concurrent processing of multiple files
- Respects TMDB API rate limits
- Large libraries (1000+ files) may take 10-30 minutes

### Re-scanning

- Files are checked by path - won't create duplicates
- Safe to run multiple times
- Only new files are processed

### User Assignment

- Media is initially unassigned (accessible to no one)
- Use Rails console or build an admin UI to assign media to users
- Many-to-many: Same movie can be assigned to multiple users

---

## 🆘 Troubleshooting

### "TMDB_API_KEY not set"

```bash
export TMDB_API_KEY="your_key_here"
```

### "Job processor not running"

```bash
bin/jobs
```

### "Media not found"

Check directory structure matches expected format (see above)

### "Movies created without metadata"

- Check TMDB API key is set
- Check internet connection
- TMDB may not have the movie (obscure/foreign films)

---

## 🔮 Future Enhancements

Potential additions:

- [ ] MusicBrainz API integration for music metadata
- [ ] Web UI for assigning media to users
- [ ] Watch history tracking
- [ ] Continue watching / resume playback
- [ ] Recommendations based on user preferences
- [ ] Metadata refresh/update command
- [ ] Duplicate detection
- [ ] Missing episode detection

---

Happy streaming! 🎬🎵📺
