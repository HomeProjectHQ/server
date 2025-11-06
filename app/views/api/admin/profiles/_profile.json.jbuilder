json.extract! profile, :id, :name, :email, :color, :created_at, :updated_at

if local_assigns[:with_stats]
  json.movies_count profile.movies.count
  json.tv_shows_count profile.tv_shows.count
  json.songs_count profile.songs.count
end

