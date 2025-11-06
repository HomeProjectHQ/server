module Api
  module Admin
    class TvShowsController < ApplicationController
      # GET /api/admin/tv_shows
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
      
      # GET /api/admin/tv_shows/:id
      def show
        @tv_show = TvShow.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "TV show not found" }, status: :not_found
      end
    end
  end
end


