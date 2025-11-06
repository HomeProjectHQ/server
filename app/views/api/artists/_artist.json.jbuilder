json.extract! artist, :id, :name, :image_url

json.album_count artist.albums.count
json.song_count artist.songs.count

if local_assigns[:detailed]
  json.extract! artist, :bio, :country
  
  json.albums do
    json.array! artist.albums.order(year: :desc) do |album|
      json.partial! 'api/artists/album', album: album
    end
  end
end

