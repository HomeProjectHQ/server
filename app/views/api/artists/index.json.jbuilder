json.artists do
  json.array! @artists do |artist|
    json.partial! 'api/artists/artist', artist: artist
  end
end

json.page @page
json.per_page @per_page
json.total @total

