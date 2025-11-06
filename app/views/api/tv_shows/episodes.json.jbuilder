json.tv_show do
  json.extract! @tv_show, :id, :title
  json.backdrop_url @tv_show.backdrop_url
end

json.season do
  json.extract! @season, :id, :season_number
end

json.episodes do
  json.array! @episodes do |episode|
    json.partial! 'api/tv_shows/episode', episode: episode
  end
end

