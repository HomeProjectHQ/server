json.type 'movie'
json.partial! 'movie', movie: @movie, detailed: true

# Add HLS streaming info
json.hls do
  json.status @movie.status
  json.available_qualities @movie.hls_qualities&.split(',') || []
  json.duration @movie.hls_duration
  json.stream_url @movie.hls_path.present? ? stream_api_movie_path(@movie) : nil
end
