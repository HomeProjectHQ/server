class Api::MoviesController < ApplicationController
  include StreamableController
  
  # GET /api/movies
  def index
    @movies = Movie.all.order(created_at: :desc)
    
    # Optional filtering
    @movies = @movies.by_year(params[:year]) if params[:year].present?
    @movies = @movies.where("title ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    
    # Pagination
    @page = params[:page]&.to_i || 1
    @per_page = params[:per_page]&.to_i || 50
    @total = Movie.count
    @movies = @movies.limit(@per_page).offset((@page - 1) * @per_page)
  end
  
  # GET /api/movies/:id
  def show
    @movie = Movie.includes(:genres).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Movie not found" }, status: :not_found
  end
  
  # Streaming actions inherited from StreamableController:
  # GET /api/movies/:id/stream
  # GET /api/movies/:id/stream/*segment_path
  
  private
  
  def set_streamable_record
    @streamable = Movie.find(params[:id])
    
    unless @streamable.file_path.present?
      render json: { 
        error: "Movie not yet processed", 
        status: @streamable.status || "pending" 
      }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Movie not found" }, status: :not_found
  end
end
