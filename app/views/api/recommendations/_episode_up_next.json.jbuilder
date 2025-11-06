json.type 'tv_episode'
json.extract! episode, :id, :title, :overview, :air_date
json.season_number episode.season_number
json.episode_number episode.episode_number
json.still_url episode.still_url

json.tv_show do
  json.id episode.tv_show.id
  json.title episode.tv_show.title
  json.poster_url episode.tv_show.poster_url
end

json.hls do
  json.status episode.status
  json.available_qualities episode.hls_qualities&.split(',') || []
  json.duration episode.hls_duration
  json.stream_url episode.hls_path.present? ? stream_api_tv_episode_path(episode) : nil
end

