module Api
  module Admin
    class MediaFoldersController < ApplicationController
      before_action :set_media_folder, only: [:show, :update, :destroy]
      
      # GET /api/admin/media_folders
      def index
        @media_folders = MediaFolder.all.order(created_at: :asc)
        
        render json: @media_folders.map { |media_folder|
          {
            id: media_folder.id,
            name: media_folder.name,
            path: media_folder.path,
            enabled: media_folder.enabled,
            exists: media_folder.exists?,
            available_media_types: media_folder.exists? ? media_folder.available_media_types : [],
            created_at: media_folder.created_at,
            updated_at: media_folder.updated_at
          }
        }
      end
      
      # GET /api/admin/media_folders/:id
      def show
        render json: {
          id: @media_folder.id,
          name: @media_folder.name,
          path: @media_folder.path,
          enabled: @media_folder.enabled,
          exists: @media_folder.exists?,
          available_media_types: @media_folder.exists? ? @media_folder.available_media_types : [],
          media_paths: @media_folder.exists? ? {
            tv: @media_folder.has_media_type?("TV") ? @media_folder.media_path("TV") : nil,
            movies: @media_folder.has_media_type?("Movies") ? @media_folder.media_path("Movies") : nil,
            music: @media_folder.has_media_type?("Music") ? @media_folder.media_path("Music") : nil
          } : {},
          created_at: @media_folder.created_at,
          updated_at: @media_folder.updated_at
        }
      end
      
      # POST /api/admin/media_folders
      def create
        @media_folder = MediaFolder.new(media_folder_params)
        
        if @media_folder.save
          render json: {
            id: @media_folder.id,
            name: @media_folder.name,
            path: @media_folder.path,
            enabled: @media_folder.enabled,
            exists: @media_folder.exists?,
            available_media_types: @media_folder.exists? ? @media_folder.available_media_types : [],
            created_at: @media_folder.created_at,
            updated_at: @media_folder.updated_at
          }, status: :created
        else
          render json: {
            errors: @media_folder.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/admin/media_folders/:id
      def update
        if @media_folder.update(media_folder_params)
          render json: {
            id: @media_folder.id,
            name: @media_folder.name,
            path: @media_folder.path,
            enabled: @media_folder.enabled,
            exists: @media_folder.exists?,
            available_media_types: @media_folder.exists? ? @media_folder.available_media_types : [],
            updated_at: @media_folder.updated_at
          }
        else
          render json: {
            errors: @media_folder.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/admin/media_folders/:id
      def destroy
        @media_folder.destroy
        head :no_content
      end
      
      # GET /api/admin/media_folders/media_paths
      # Get all media paths across all enabled folders
      def media_paths
        render json: {
          tv: MediaFolder.tv_paths,
          movies: MediaFolder.movie_paths,
          music: MediaFolder.music_paths
        }
      end
      
      private
      
      def set_media_folder
        @media_folder = MediaFolder.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Media folder not found" }, status: :not_found
      end
      
      def media_folder_params
        params.require(:media_folder).permit(:name, :path, :enabled)
      end
    end
  end
end

