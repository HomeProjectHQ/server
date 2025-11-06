json.extract! movie, :id, :title, :original_title, :year, :runtime, :tmdb_id, :imdb_id

json.poster_url movie.poster_url
json.backdrop_url movie.backdrop_url

# Ratings and popularity
json.vote_average movie.vote_average
json.vote_count movie.vote_count
json.popularity movie.popularity

if local_assigns[:detailed]
  json.extract! movie, :overview, :tagline, :release_date, :homepage
  json.extract! movie, :original_language, :budget, :revenue
  json.extract! movie, :file_path, :file_size, :rating
  json.extract! movie, :created_at, :updated_at
  
  # Genres (if loaded)
  json.genres movie.genres.pluck(:name) if movie.association(:genres).loaded?
end

