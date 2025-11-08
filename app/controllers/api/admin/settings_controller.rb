module Api
  module Admin
    class SettingsController < ApplicationController
      before_action :set_setting

      # GET /api/admin/settings
      def show
        # @setting set by before_action
      end

      # PATCH/PUT /api/admin/settings
      def update
        if @setting.update(setting_params)
          render :show
        else
          render json: { 
            error: "Failed to update settings",
            details: @setting.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      private

      def set_setting
        @setting = Setting.instance
      end

      def setting_params
        params.require(:setting).permit(
          :root_path,
          :max_transcode_quality,
          :transcode_codec,
          :enable_auto_scan,
          :scan_interval_minutes,
          :enable_transcoding,
          :enable_artwork_downloads
        )
      end
    end
  end
end

