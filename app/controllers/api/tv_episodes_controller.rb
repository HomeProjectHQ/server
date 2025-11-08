class Api::TvEpisodesController < ApplicationController
  include StreamableController
  
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
      stream: {
        status: @episode.status,
        available_qualities: @episode.stream_qualities&.split(',') || [],
        duration: @episode.stream_duration,
        stream_url: @episode.file_path.present? ? stream_api_tv_episode_path(@episode) : nil
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Episode not found" }, status: :not_found
  end
  
  # Streaming actions inherited from StreamableController:
  # GET /api/tv_episodes/:id/stream
  # GET /api/tv_episodes/:id/stream/*segment_path
  
  private
  
  def set_streamable_record
    @streamable = TvEpisode.find(params[:id])
    
    unless @streamable.file_path.present?
      render json: { 
        error: "Episode not yet processed", 
        status: @streamable.status || "pending" 
      }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Episode not found" }, status: :not_found
  end
end

