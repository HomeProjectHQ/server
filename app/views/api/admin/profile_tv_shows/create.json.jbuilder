json.message @message

json.tv_show do
  json.partial! 'api/tv_shows/tv_show', tv_show: @tv_show
  json.seasons_count @tv_show.tv_seasons.count
  json.episodes_count @tv_show.tv_episodes.count
end
