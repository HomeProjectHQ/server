json.message @message

json.movie do
  json.partial! 'api/movies/movie', movie: @movie
end
