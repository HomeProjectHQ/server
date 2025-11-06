class Api::TvEpisodesController < ApplicationController
  # GET /api/tv_episodes/:id
  def show
    @episode = TvEpisode.find(params[:id])
    
    render json: {
      type: 'tv_episode',
      id: @episode.id,
      title: @episode.title,
      season_number: @episode.season_number,
      episode_number: @episode.episode_number,
      overview: @episode.overview,
      still_url: @episode.still_url,
      air_date: @episode.air_date,
      tv_show: {
        id: @episode.tv_show.id,
        title: @episode.tv_show.title,
        poster_url: @episode.tv_show.poster_url,
        backdrop_url: @episode.tv_show.backdrop_url
      },
      tv_season: {
        id: @episode.tv_season.id,
        season_number: @episode.tv_season.season_number,
        name: @episode.tv_season.name
      },
      hls: {
        status: @episode.status,
        available_qualities: @episode.hls_qualities&.split(',') || [],
        duration: @episode.hls_duration,
        stream_url: @episode.hls_path.present? ? stream_api_tv_episode_path(@episode) : nil
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Episode not found" }, status: :not_found
  end
end

