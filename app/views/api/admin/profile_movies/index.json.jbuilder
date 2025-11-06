json.profile do
  json.extract! @profile, :id, :name, :email, :color
end

json.movies do
  json.array! @movies do |movie|
    json.partial! 'api/movies/movie', movie: movie
  end
end

json.total @movies.count
