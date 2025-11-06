json.album do
  json.extract! @album, :id, :title
end

json.artist do
  json.extract! @album.artist, :id, :name
end

json.songs do
  json.array! @songs do |song|
    json.partial! 'api/artists/song', song: song
  end
end

