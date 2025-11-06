json.extract! album, :id, :title, :year, :cover_url, :artist_id

json.artist_name album.artist.name
json.song_count album.songs.count

