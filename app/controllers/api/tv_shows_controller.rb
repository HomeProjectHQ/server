class Api::TvShowsController < ApplicationController
  # GET /api/tv_shows
  def index
    @tv_shows = TvShow.all.order(title: :asc)
    
    # Optional search
    @tv_shows = @tv_shows.where("title ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    
    # Pagination
    @page = params[:page]&.to_i || 1
    @per_page = params[:per_page]&.to_i || 50
    @total = TvShow.count
    @tv_shows = @tv_shows.limit(@per_page).offset((@page - 1) * @per_page)
  end
  
  # GET /api/tv_shows/:id
  def show
    @tv_show = TvShow.includes(:genres, :tv_seasons, :tv_episodes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "TV show not found" }, status: :not_found
  end
  
  # GET /api/tv_shows/:id/seasons
  def seasons
    @tv_show = TvShow.find(params[:id])
    @seasons = @tv_show.tv_seasons.order(season_number: :asc)
  end
  
  # GET /api/tv_shows/:id/seasons/:season_number/episodes
  def episodes
    @tv_show = TvShow.find(params[:id])
    @season = @tv_show.tv_seasons.find_by!(season_number: params[:season_number])
    @episodes = @season.tv_episodes.order(episode_number: :asc)
  end
end
