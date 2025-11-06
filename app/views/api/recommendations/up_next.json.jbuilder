if @media_type == 'movie'
  json.partial! 'movie_up_next', movie: @recommendation
elsif @media_type == 'tv_episode'
  json.partial! 'episode_up_next', episode: @recommendation
end

