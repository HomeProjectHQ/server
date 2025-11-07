class SettingsController < ApplicationController
  before_action :set_setting
  
  def show
    # Show current settings
  end
  
  def edit
    # Form to edit settings
  end
  
  def update
    if @setting.update(setting_params)
      redirect_to settings_path, notice: 'Settings updated successfully.'
    else
      render :edit, status: :unprocessable_entity
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

