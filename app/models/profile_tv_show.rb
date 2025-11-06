class ProfileTvShow < ApplicationRecord
  belongs_to :profile
  belongs_to :tv_show
end
