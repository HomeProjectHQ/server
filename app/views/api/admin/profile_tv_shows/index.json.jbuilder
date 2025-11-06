json.profile do
  json.extract! @profile, :id, :name, :email, :color
end

json.tv_shows do
  json.array! @tv_shows do |tv_show|
    json.partial! 'api/tv_shows/tv_show', tv_show: tv_show
    json.seasons_count tv_show.tv_seasons.count
    json.episodes_count tv_show.tv_episodes.count
  end
end

json.total @tv_shows.count
