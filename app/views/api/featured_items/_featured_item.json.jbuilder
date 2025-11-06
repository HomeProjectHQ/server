json.extract! featured_item, :id, :caption, :placements, :generated_at, :expires_at

# Include the featurable media item
json.media do
  case featured_item.featurable_type
  when 'Movie'
    json.type 'movie'
    json.partial! 'api/movies/movie', movie: featured_item.featurable
  when 'TvEpisode'
    json.type 'tv_episode'
    json.partial! 'api/tv_shows/episode', episode: featured_item.featurable
  when 'TvShow'
    json.type 'tv_show'
    json.partial! 'api/tv_shows/tv_show', tv_show: featured_item.featurable
  end
end

# Optional: Include reasoning if available
if featured_item.reasoning.present?
  json.reasoning featured_item.reasoning
end

