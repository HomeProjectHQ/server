json.profile do
  json.extract! @profile, :id, :name, :email, :color
end

json.songs do
  json.array! @songs do |song|
    json.extract! song, :id, :title, :track_number, :duration, :file_path, :file_size
    
    json.album do
      json.extract! song.album, :id, :title, :year, :cover_url
    end
    
    json.artist do
      json.extract! song.artist, :id, :name, :image_url
    end
  end
end

json.total @songs.count
