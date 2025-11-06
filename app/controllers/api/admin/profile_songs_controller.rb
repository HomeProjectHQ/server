module Api
  module Admin
    class ProfileSongsController < ApplicationController
      before_action :set_profile

      # GET /api/admin/profiles/:profile_id/songs
      # Get all songs accessible by the profile
      def index
        @songs = @profile.songs.includes(:album, :artist, :profile_songs).order('albums.title, songs.track_number')
      end

      # POST /api/admin/profiles/:profile_id/songs
      # Grant profile access to a song
      # Body: { song_id: 123 }
      def create
        @song = Song.find(params[:song_id])
        
        profile_song = @profile.profile_songs.find_or_initialize_by(song: @song)
        
        if profile_song.persisted?
          @message = "Profile already has access to this song"
          render :create, status: :ok
        elsif profile_song.save
          @message = "Song access granted successfully"
          render :create, status: :created
        else
          render json: { 
            error: "Failed to grant access",
            details: profile_song.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/admin/profiles/:profile_id/songs/:song_id
      # Revoke profile access to a song
      def destroy
        @song = Song.find(params[:song_id])
        profile_song = @profile.profile_songs.find_by(song: @song)
        
        if profile_song.nil?
          render json: { 
            error: "Profile does not have access to this song"
          }, status: :not_found
        elsif profile_song.destroy
          @message = "Song access revoked successfully"
          render :destroy, status: :ok
        else
          render json: { 
            error: "Failed to revoke access"
          }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        @profile = Profile.find(params[:profile_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Profile not found" }, status: :not_found
      end
    end
  end
end
