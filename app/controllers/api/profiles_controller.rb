module Api
  class ProfilesController < ApplicationController
    # GET /api/profiles
    def index
      @profiles = Profile.all.order(created_at: :asc)
    end
  end
end


