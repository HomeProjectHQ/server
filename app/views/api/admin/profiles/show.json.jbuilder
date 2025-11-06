json.partial! 'api/admin/profiles/profile', profile: @profile, with_stats: true

# Include detailed media access information
json.media_access do
  json.movies do
    json.array! @profile.movies.limit(5).order(title: :asc) do |movie|
      json.extract! movie, :id, :title, :year
    end
  end
  
  json.tv_shows do
    json.array! @profile.tv_shows.limit(5).order(title: :asc) do |show|
      json.extract! show, :id, :title, :year
    end
  end
  
  json.songs do
    json.array! @profile.songs.limit(5).order(title: :asc) do |song|
      json.extract! song, :id, :title
      json.artist_name song.artist.name
    end
  end
end
