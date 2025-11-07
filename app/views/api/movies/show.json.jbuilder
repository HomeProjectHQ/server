json.type 'movie'
json.partial! 'movie', movie: @movie, detailed: true

# Add streaming info
json.stream do
  json.status @movie.status
  json.available_qualities @movie.stream_qualities&.split(',') || []
  json.duration @movie.stream_duration
  json.stream_url @movie.file_path.present? ? stream_api_movie_path(@movie) : nil
end
