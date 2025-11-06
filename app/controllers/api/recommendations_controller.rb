class Api::RecommendationsController < ApplicationController
  before_action :set_profile
  
  # GET /api/profiles/:profile_id/recommendations/up_next?movie_id=123
  # GET /api/profiles/:profile_id/recommendations/up_next?tv_episode_id=456
  def up_next
    if params[:movie_id].present?
      movie_up_next
    elsif params[:tv_episode_id].present?
      episode_up_next
    else
      render json: { error: "Must provide movie_id or tv_episode_id parameter" }, status: :bad_request
    end
  end
  
  private
  
  def set_profile
    # Route uses :id because it's inside resources :profiles member block
    @profile = Profile.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Profile not found" }, status: :not_found
  end
  
  def movie_up_next
    current_movie = Movie.find(params[:movie_id])
    @recommendation = current_movie.recommended_movie
    
    if @recommendation
      @media_type = 'movie'
      render :up_next
    else
      render json: { message: "No recommendations available" }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Movie not found" }, status: :not_found
  end
  
  def episode_up_next
    current_episode = TvEpisode.find(params[:tv_episode_id])
    @recommendation = current_episode.next_episode
    
    if @recommendation
      @media_type = 'tv_episode'
      render :up_next
    else
      render json: { message: "No more episodes available" }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Episode not found" }, status: :not_found
  end
end

