class Api::WatchProgressesController < ApplicationController
  before_action :set_profile
  before_action :set_watchable, only: [:show, :update]

  # GET /api/profiles/:id/watch_progresses
  # Returns all watch progress for a profile (continue watching)
  def index
    @watch_progresses = @profile.continue_watching(limit: params[:limit] || 20)
    render json: @watch_progresses.map { |wp| watch_progress_json(wp) }
  end

  # GET /api/profiles/:id/watch_progresses/:watchable_type/:watchable_id
  # Get progress for specific media
  def show
    @progress = @profile.progress_for(@watchable)
    render json: watch_progress_json(@progress)
  end

  # PUT/PATCH /api/profiles/:id/watch_progresses/:watchable_type/:watchable_id
  # Update watch progress
  def update
    @progress = @profile.progress_for(@watchable)
    
    if @progress.update_progress(
      progress_params[:position_seconds].to_i,
      progress_params[:duration_seconds].to_i
    )
      render json: watch_progress_json(@progress)
    else
      render json: { errors: @progress.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/profiles/:id/tv_shows/:tv_show_id/next_episode
  # Get the next episode to watch for a TV show
  def next_episode
    tv_show = TvShow.find(params[:tv_show_id])
    next_ep = @profile.next_episode_for(tv_show)
    
    if next_ep
      progress = @profile.progress_for(next_ep)
      render json: {
        episode: episode_json(next_ep),
        progress: watch_progress_json(progress)
      }
    else
      render json: { message: "No more episodes available" }, status: :not_found
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def set_watchable
    watchable_type = params[:watchable_type].classify
    watchable_id = params[:watchable_id]
    
    @watchable = watchable_type.constantize.find(watchable_id)
  rescue NameError
    render json: { error: "Invalid watchable type" }, status: :bad_request
  end

  def progress_params
    params.require(:watch_progress).permit(:position_seconds, :duration_seconds)
  end

  def watch_progress_json(progress)
    {
      id: progress.id,
      watchable_type: progress.watchable_type,
      watchable_id: progress.watchable_id,
      position_seconds: progress.position_seconds,
      duration_seconds: progress.duration_seconds,
      progress_percentage: progress.progress_percentage,
      completed: progress.completed,
      last_watched_at: progress.last_watched_at,
      watch_count: progress.watch_count,
      watchable: watchable_json(progress.watchable)
    }
  end

  def watchable_json(watchable)
    case watchable
    when Movie
      {
        type: 'movie',
        id: watchable.id,
        title: watchable.title,
        year: watchable.year,
        poster_url: watchable.poster_url,
        file_path: watchable.file_path
      }
    when TvEpisode
      {
        type: 'tv_episode',
        id: watchable.id,
        title: watchable.title,
        season_number: watchable.season_number,
        episode_number: watchable.episode_number,
        still_url: watchable.still_url,
        tv_show: {
          id: watchable.tv_show.id,
          title: watchable.tv_show.title,
          poster_url: watchable.tv_show.poster_url
        }
      }
    when Song
      {
        type: 'song',
        id: watchable.id,
        title: watchable.title,
        track_number: watchable.track_number,
        duration: watchable.duration,
        album: {
          id: watchable.album.id,
          title: watchable.album.title,
          cover_art_url: watchable.album.cover_art_url
        },
        artist: {
          id: watchable.artist.id,
          name: watchable.artist.name
        }
      }
    else
      { type: 'unknown', id: watchable&.id }
    end
  end

  def episode_json(episode)
    {
      id: episode.id,
      title: episode.title,
      season_number: episode.season_number,
      episode_number: episode.episode_number,
      overview: episode.overview,
      still_url: episode.still_url,
      file_path: episode.file_path,
      tv_show_id: episode.tv_show.id
    }
  end
end

