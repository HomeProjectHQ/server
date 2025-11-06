class TvSeason < ApplicationRecord
  belongs_to :tv_show
  has_many :tv_episodes, dependent: :destroy
  
  validates :season_number, presence: true
  validates :tv_show_id, uniqueness: { scope: :season_number }
end
