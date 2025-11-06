json.extract! pick, :id, :caption, :generated_at, :expires_at

# Include the pickable media item
json.media do
  case pick.pickable_type
  when 'Movie'
    json.type 'movie'
    json.partial! 'api/movies/movie', movie: pick.pickable
  when 'TvEpisode'
    json.type 'tv_episode'
    json.partial! 'api/tv_shows/episode', episode: pick.pickable
  when 'TvShow'
    json.type 'tv_show'
    json.partial! 'api/tv_shows/tv_show', tv_show: pick.pickable
  end
end

# Optional: Include reasoning if available
if pick.reasoning.present?
  json.reasoning pick.reasoning
end

