module Api
  module Admin
    class ProfileTvShowsController < ApplicationController
      before_action :set_profile

      # GET /api/admin/profiles/:profile_id/tv_shows
      # Get all TV shows accessible by the profile
      def index
        @tv_shows = @profile.tv_shows.includes(:tv_seasons, :profile_tv_shows).order(:title)
      end

      # POST /api/admin/profiles/:profile_id/tv_shows
      # Grant profile access to a TV show
      # Body: { tv_show_id: 123 }
      def create
        @tv_show = TvShow.find(params[:tv_show_id])
        
        profile_tv_show = @profile.profile_tv_shows.find_or_initialize_by(tv_show: @tv_show)
        
        if profile_tv_show.persisted?
          @message = "Profile already has access to this TV show"
          render :create, status: :ok
        elsif profile_tv_show.save
          @message = "TV show access granted successfully"
          render :create, status: :created
        else
          render json: { 
            error: "Failed to grant access",
            details: profile_tv_show.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/admin/profiles/:profile_id/tv_shows/:tv_show_id
      # Revoke profile access to a TV show
      def destroy
        @tv_show = TvShow.find(params[:tv_show_id])
        profile_tv_show = @profile.profile_tv_shows.find_by(tv_show: @tv_show)
        
        if profile_tv_show.nil?
          render json: { 
            error: "Profile does not have access to this TV show"
          }, status: :not_found
        elsif profile_tv_show.destroy
          @message = "TV show access revoked successfully"
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
