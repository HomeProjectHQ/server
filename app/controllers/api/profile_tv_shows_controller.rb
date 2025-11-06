module Api
  class ProfileTvShowsController < ApplicationController
    before_action :set_profile
    
    # GET /api/profiles/:profile_id/tv_shows
    def index
      @tv_shows = @profile.tv_shows.order(title: :asc)
      render 'api/tv_shows/index'
    end
    
    # GET /api/profiles/:id/tv_shows/:tv_show_id
    def show
      @tv_show = @profile.tv_shows.find(params[:tv_show_id])
      render 'api/tv_shows/show'
    rescue ActiveRecord::RecordNotFound
      render json: { error: "TV show not found or not accessible by this profile" }, status: :not_found
    end
    
    # GET /api/profiles/:id/tv_shows/:tv_show_id/seasons
    def seasons
      @tv_show = @profile.tv_shows.find(params[:tv_show_id])
      render 'api/tv_shows/seasons'
    rescue ActiveRecord::RecordNotFound
      render json: { error: "TV show not found or not accessible by this profile" }, status: :not_found
    end
    
    # GET /api/profiles/:id/tv_shows/:tv_show_id/seasons/:season_number/episodes
    def episodes
      @tv_show = @profile.tv_shows.find(params[:tv_show_id])
      @season = @tv_show.tv_seasons.find_by!(season_number: params[:season_number])
      @episodes = @season.tv_episodes.order(episode_number: :asc)
      render 'api/tv_shows/episodes'
    rescue ActiveRecord::RecordNotFound
      render json: { error: "TV show or season not found" }, status: :not_found
    end
    
    private
    
    def set_profile
      @profile = Profile.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Profile not found" }, status: :not_found
    end
  end
end

