module Api
  module Admin
    class ProfilesController < ApplicationController
      before_action :set_profile, only: [:show, :update, :destroy]

      # GET /api/admin/profiles
      def index
        @profiles = Profile.all.order(created_at: :desc)
        
        # Optional search
        if params[:search].present?
          @profiles = @profiles.where("name ILIKE ? OR email ILIKE ?", 
                                "%#{params[:search]}%", 
                                "%#{params[:search]}%")
        end
        
        # Pagination
        @page = params[:page]&.to_i || 1
        @per_page = params[:per_page]&.to_i || 50
        @total = @profiles.count
        @profiles = @profiles.limit(@per_page).offset((@page - 1) * @per_page)
      end

      # GET /api/admin/profiles/:id
      def show
        # @profile set by before_action
      end

      # POST /api/admin/profiles
      def create
        @profile = Profile.new(profile_params)

        if @profile.save
          render :show, status: :created
        else
          render json: { 
            error: "Failed to create profile",
            details: @profile.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/admin/profiles/:id
      def update
        if @profile.update(profile_params)
          render :show
        else
          render json: { 
            error: "Failed to update profile",
            details: @profile.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/admin/profiles/:id
      def destroy
        if @profile.destroy
          head :no_content
        else
          render json: { 
            error: "Failed to delete profile",
            details: @profile.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        @profile = Profile.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Profile not found" }, status: :not_found
      end

      def profile_params
        params.require(:profile).permit(:name, :email, :color)
      end
    end
  end
end
