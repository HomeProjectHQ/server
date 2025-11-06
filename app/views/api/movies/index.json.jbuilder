json.movies do
  json.array! @movies do |movie|
    json.partial! 'api/movies/movie', movie: movie
  end
end

json.page @page
json.per_page @per_page
json.total @total

