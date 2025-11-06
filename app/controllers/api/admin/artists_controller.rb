module Api
  module Admin
    class ArtistsController < ApplicationController
      # GET /api/admin/artists
      def index
        @artists = Artist.all.order(name: :asc)
        
        # Optional search
        @artists = @artists.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
        
        # Pagination
        @page = params[:page]&.to_i || 1
        @per_page = params[:per_page]&.to_i || 50
        @total = Artist.count
        @artists = @artists.limit(@per_page).offset((@page - 1) * @per_page)
      end
      
      # GET /api/admin/artists/:id
      def show
        @artist = Artist.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Artist not found" }, status: :not_found
      end
      
      # GET /api/admin/artists/:id/albums
      def albums
        @artist = Artist.find(params[:id])
        @albums = @artist.albums.order(year: :desc, title: :asc)
      end
    end
  end
end


