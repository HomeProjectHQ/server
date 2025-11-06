json.artist do
  json.extract! @artist, :id, :name
end

json.albums do
  json.array! @albums do |album|
    json.partial! 'api/artists/album', album: album
  end
end


