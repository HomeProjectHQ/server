module Api
  module Admin
    class ProfileMoviesController < ApplicationController
      before_action :set_profile

      # GET /api/admin/profiles/:profile_id/movies
      # Get all movies accessible by the profile
      def index
        @movies = @profile.movies.includes(:profile_movies).order(:title)
      end

      # POST /api/admin/profiles/:profile_id/movies
      # Grant profile access to a movie
      # Body: { movie_id: 123 }
      def create
        @movie = Movie.find(params[:movie_id])
        
        profile_movie = @profile.profile_movies.find_or_initialize_by(movie: @movie)
        
        if profile_movie.persisted?
          @message = "Profile already has access to this movie"
          render :create, status: :ok
        elsif profile_movie.save
          @message = "Movie access granted successfully"
          render :create, status: :created
        else
          render json: { 
            error: "Failed to grant access",
            details: profile_movie.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/admin/profiles/:profile_id/movies/:movie_id
      # Revoke profile access to a movie
      def destroy
        @movie = Movie.find(params[:movie_id])
        profile_movie = @profile.profile_movies.find_by(movie: @movie)
        
        if profile_movie.nil?
          render json: { 
            error: "Profile does not have access to this movie"
          }, status: :not_found
        elsif profile_movie.destroy
          @message = "Movie access revoked successfully"
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
