json.extract! tv_show, :id, :title, :original_name, :year, :status, :tmdb_id

json.poster_url tv_show.poster_url
json.backdrop_url tv_show.backdrop_url

# Ratings and popularity
json.vote_average tv_show.vote_average
json.vote_count tv_show.vote_count
json.popularity tv_show.popularity

# Show metadata
json.number_of_seasons tv_show.number_of_seasons
json.number_of_episodes tv_show.number_of_episodes
json.in_production tv_show.in_production

# Available seasons and episodes from actual data
json.available_seasons tv_show.tv_seasons.order(season_number: :asc).pluck(:season_number)
json.total_episodes tv_show.tv_episodes.count

if local_assigns[:detailed]
  json.extract! tv_show, :overview, :tagline, :homepage, :type
  json.extract! tv_show, :first_air_date, :last_air_date, :original_language
  
  # Genres (if loaded)
  json.genres tv_show.genres.pluck(:name) if tv_show.association(:genres).loaded?
  
  json.seasons do
    json.array! tv_show.tv_seasons.order(season_number: :asc) do |season|
      json.partial! 'api/tv_shows/season', season: season
    end
  end
end

