# JBuilder Views Guide

## What Changed

All JSON responses have been migrated from inline controller rendering to JBuilder view templates.

### Before (Inline JSON):

```ruby
# app/controllers/api/movies_controller.rb
def index
  @movies = Movie.all
  render json: {
    movies: @movies.map { |m| movie_json(m) },
    page: page,
    total: total
  }
end

private

def movie_json(movie)
  {
    id: movie.id,
    title: movie.title,
    # ... more fields
  }
end
```

### After (JBuilder):

```ruby
# app/controllers/api/movies_controller.rb
def index
  @movies = Movie.all
  @page = 1
  @total = Movie.count
  # Rails automatically renders app/views/api/movies/index.json.jbuilder
end
```

```ruby
# app/views/api/movies/index.json.jbuilder
json.movies do
  json.array! @movies do |movie|
    json.partial! 'api/movies/movie', movie: movie
  end
end

json.page @page
json.total @total
```

---

## View Structure

All JBuilder views are in `app/views/api/`:

```
app/views/api/
├── movies/
│   ├── _movie.json.jbuilder        # Partial for movie data
│   ├── index.json.jbuilder         # GET /api/movies
│   └── show.json.jbuilder          # GET /api/movies/:id
├── tv_shows/
│   ├── _tv_show.json.jbuilder      # Partial for TV show data
│   ├── _season.json.jbuilder       # Partial for season data
│   ├── _episode.json.jbuilder      # Partial for episode data
│   ├── index.json.jbuilder         # GET /api/tv_shows
│   ├── show.json.jbuilder          # GET /api/tv_shows/:id
│   ├── seasons.json.jbuilder       # GET /api/tv_shows/:id/seasons
│   └── episodes.json.jbuilder      # GET /api/tv_shows/:id/seasons/:season_number/episodes
├── artists/
│   ├── _artist.json.jbuilder       # Partial for artist data
│   ├── _album.json.jbuilder        # Partial for album data
│   ├── _song.json.jbuilder         # Partial for song data
│   ├── index.json.jbuilder         # GET /api/artists
│   ├── show.json.jbuilder          # GET /api/artists/:id
│   ├── albums.json.jbuilder        # GET /api/artists/:id/albums
│   └── album_songs.json.jbuilder   # GET /api/albums/:id/songs
├── media/
│   ├── _media.json.jbuilder        # Partial for media data
│   ├── index.json.jbuilder         # GET /api/media
│   ├── show.json.jbuilder          # GET /api/media/:id
│   ├── create.json.jbuilder        # POST /api/media
│   └── update.json.jbuilder        # PATCH /api/media/:id
└── admin/
    ├── user_movies/
    │   ├── index.json.jbuilder     # GET /api/admin/users/:user_id/movies
    │   ├── create.json.jbuilder    # POST /api/admin/users/:user_id/movies
    │   └── destroy.json.jbuilder   # DELETE /api/admin/users/:user_id/movies/:movie_id
    ├── user_tv_shows/
    │   ├── index.json.jbuilder
    │   ├── create.json.jbuilder
    │   └── destroy.json.jbuilder
    └── user_songs/
        ├── index.json.jbuilder
        ├── create.json.jbuilder
        └── destroy.json.jbuilder
```

---

## JBuilder Syntax Examples

### 1. Extract Specific Fields

```ruby
json.extract! movie, :id, :title, :year, :rating
# => { id: 1, title: "The Matrix", year: 1999, rating: 8.7 }
```

### 2. Custom Fields

```ruby
json.poster_url movie.poster_url
json.custom_field "custom value"
# => { poster_url: "https://...", custom_field: "custom value" }
```

### 3. Arrays

```ruby
json.movies do
  json.array! @movies do |movie|
    json.id movie.id
    json.title movie.title
  end
end
# => { movies: [{ id: 1, title: "..." }, { id: 2, title: "..." }] }
```

### 4. Partials (Reusable Components)

```ruby
# In _movie.json.jbuilder
json.extract! movie, :id, :title

# In index.json.jbuilder
json.partial! 'api/movies/movie', movie: @movie
```

### 5. Nested Objects

```ruby
json.song do
  json.extract! song, :id, :title

  json.album do
    json.extract! song.album, :id, :title
  end
end
# => { song: { id: 1, title: "...", album: { id: 1, title: "..." } } }
```

### 6. Conditional Fields

```ruby
if local_assigns[:detailed]
  json.overview movie.overview
  json.created_at movie.created_at
end
```

---

## Creating New Endpoints

When adding a new API endpoint:

1. **Create the controller action** (set instance variables, no `render json:`)

   ```ruby
   def index
     @items = Item.all
     # No render needed - Rails auto-renders index.json.jbuilder
   end
   ```

2. **Create the view file** `app/views/api/controller_name/action.json.jbuilder`

   ```ruby
   json.items do
     json.array! @items do |item|
       json.extract! item, :id, :name
     end
   end
   ```

3. **Create partials for reusable data** (optional but recommended)

   ```ruby
   # _item.json.jbuilder
   json.extract! item, :id, :name, :description

   # index.json.jbuilder
   json.array! @items do |item|
     json.partial! 'api/items/item', item: item
   end
   ```

---

## Benefits of JBuilder

### ✅ Separation of Concerns

- Controllers handle business logic
- Views handle presentation
- JSON structure is visible at a glance

### ✅ Reusable Partials

- Define movie structure once in `_movie.json.jbuilder`
- Reuse in index, show, admin views, etc.
- Change structure in one place

### ✅ Maintainability

- Easy to find where JSON is generated
- No helper methods cluttering controllers
- Clear file structure

### ✅ Flexibility

- Conditional fields based on parameters
- Easy nesting and complex structures
- Fragment caching support

### ✅ Testing

- Can test views independently
- Easier to mock and stub

---

## Common Patterns

### Pattern 1: List with Pagination

```ruby
# Controller
def index
  @items = Item.all
  @page = params[:page] || 1
  @per_page = 50
  @total = Item.count
end

# View
json.items do
  json.array! @items do |item|
    json.partial! 'item', item: item
  end
end
json.page @page
json.per_page @per_page
json.total @total
```

### Pattern 2: Show with Nested Resources

```ruby
# View
json.partial! 'tv_show', tv_show: @tv_show

json.seasons do
  json.array! @tv_show.tv_seasons do |season|
    json.partial! 'season', season: season
  end
end
```

### Pattern 3: Create/Update with Message

```ruby
# View
json.message @message
json.item do
  json.partial! 'item', item: @item
end
```

---

## Migration Complete! 🎉

All existing endpoints have been migrated to JBuilder:

- ✅ Movies API
- ✅ TV Shows API
- ✅ Artists/Albums/Songs API
- ✅ Media API
- ✅ Admin APIs (User permissions)

The API responses remain **identical** - only the implementation changed.
