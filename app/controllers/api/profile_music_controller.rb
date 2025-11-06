module Api
  class ProfileMusicController < ApplicationController
    before_action :set_profile
    
    # GET /api/profiles/:profile_id/music/artists
    def artists
      # Get all artists that have songs accessible by this profile
      song_ids = @profile.songs.pluck(:id)
      @artists = Artist.joins(:songs).where(songs: { id: song_ids }).distinct.order(name: :asc)
      render 'api/artists/index'
    end
    
    # GET /api/profiles/:id/music/artists/:artist_id
    def artist
      # Get artist if they have at least one song accessible by this profile
      song_ids = @profile.songs.pluck(:id)
      @artist = Artist.joins(:songs).where(songs: { id: song_ids }).distinct.find(params[:artist_id])
      render 'api/artists/show'
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Artist not found or has no accessible songs" }, status: :not_found
    end
    
    # GET /api/profiles/:id/music/artists/:artist_id/albums
    def albums
      song_ids = @profile.songs.pluck(:id)
      @artist = Artist.joins(:songs).where(songs: { id: song_ids }).distinct.find(params[:artist_id])
      # Only return albums that have accessible songs
      @albums = @artist.albums.joins(:songs).where(songs: { id: song_ids }).distinct.order(year: :desc)
      render 'api/artists/albums'
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Artist not found" }, status: :not_found
    end
    
    # GET /api/profiles/:id/music/albums/:album_id/songs
    def album_songs
      song_ids = @profile.songs.pluck(:id)
      @album = Album.joins(:songs).where(songs: { id: song_ids }).distinct.find(params[:album_id])
      @songs = @album.songs.where(id: song_ids).order(track_number: :asc)
      render 'api/artists/album_songs'
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Album not found or has no accessible songs" }, status: :not_found
    end
    
    # GET /api/profiles/:profile_id/music/songs
    def songs
      @songs = @profile.songs.order(title: :asc)
      render json: @songs.map { |song|
        {
          id: song.id,
          title: song.title,
          track_number: song.track_number,
          duration: song.duration,
          file_path: song.file_path,
          artist_id: song.artist_id,
          album_id: song.album_id,
          artist_name: song.artist&.name,
          album_title: song.album&.title
        }
      }
    end
    
    private
    
    def set_profile
      @profile = Profile.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Profile not found" }, status: :not_found
    end
  end
end

