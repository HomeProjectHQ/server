json.type 'movie'
json.extract! movie, :id, :title, :year, :overview, :runtime

json.poster_url movie.poster_url
json.backdrop_url movie.backdrop_url

json.stream do
  json.status movie.status
  json.available_qualities movie.stream_qualities&.split(',') || []
  json.duration movie.stream_duration
  json.stream_url stream_api_movie_path(movie)
end

