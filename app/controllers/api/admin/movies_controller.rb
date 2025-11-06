module Api
  module Admin
    class MoviesController < ApplicationController
      # GET /api/admin/movies
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
      
      # GET /api/admin/movies/:id
      def show
        @movie = Movie.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Movie not found" }, status: :not_found
      end
    end
  end
end


