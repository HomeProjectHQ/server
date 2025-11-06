class ProfileSong < ApplicationRecord
  belongs_to :profile
  belongs_to :song
end
