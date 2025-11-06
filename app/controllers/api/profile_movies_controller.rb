module Api
  class ProfileMoviesController < ApplicationController
    before_action :set_profile
    
    # GET /api/profiles/:profile_id/movies
    def index
      @movies = @profile.movies.order(title: :asc)
      render 'api/movies/index'
    end
    
    # GET /api/profiles/:id/movies/:movie_id
    def show
      @movie = @profile.movies.find(params[:movie_id])
      render 'api/movies/show'
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Movie not found or not accessible by this profile" }, status: :not_found
    end
    
    private
    
    def set_profile
      @profile = Profile.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Profile not found" }, status: :not_found
    end
  end
end

