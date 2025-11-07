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

json.stream do
  json.status episode.status
  json.available_qualities episode.stream_qualities&.split(',') || []
  json.duration episode.stream_duration
  json.stream_url episode.file_path.present? ? stream_api_tv_episode_path(episode) : nil
end

