class ApplicationController < ActionController::API
  # Force JSON format for all API requests
  before_action :set_default_format
  
  private
  
  def set_default_format
    request.format = :json
  end
end
